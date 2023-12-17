sExp = " Exp."
sLuc = " Luc"
sLevelUp = " LEVEL UP!"
sLevelNew = " Reaches Lv. {0}!"
sLeft = " Left"

lastexp = {-1,-1,-1}
newexp = {0,0,0}
nextlv = {-1,-1,-1}
lvup = {"","",""}
strexp = {"","",""}
lastluc = -1
strluc = "0"
duration1 = 0
duration2 = 0
opacity = 0

menu_x = 10
menu_y = 160

tbl={}
tbl[0x81]="a"
tbl[0x82]="b"
tbl[0x83]="c"
tbl[0x84]="d"
tbl[0x85]="e"
tbl[0x86]="f"
tbl[0x87]="g"
tbl[0x88]="h"
tbl[0x89]="i"
tbl[0x8A]="j"
tbl[0x8B]="k"
tbl[0x8C]="l"
tbl[0x8D]="m"
tbl[0x8E]="n"
tbl[0x8F]="o"
tbl[0x90]="p"
tbl[0x91]="q"
tbl[0x92]="r"
tbl[0x93]="s"
tbl[0x94]="t"
tbl[0x95]="u"
tbl[0x96]="v"
tbl[0x97]="w"
tbl[0x98]="x"
tbl[0x99]="y"
tbl[0x9A]="z"
tbl[0x9B]="A"
tbl[0x9C]="B"
tbl[0x9D]="C"
tbl[0x9E]="D"
tbl[0x9F]="E"
tbl[0xA0]="F"
tbl[0xA1]="G"
tbl[0xA2]="H"
tbl[0xA3]="I"
tbl[0xA4]="J"
tbl[0xA5]="K"
tbl[0xA6]="L"
tbl[0xA7]="M"
tbl[0xA8]="N"
tbl[0xA9]="O"
tbl[0xAA]="P"
tbl[0xAB]="Q"
tbl[0xAC]="R"
tbl[0xAD]="S"
tbl[0xAE]="T"
tbl[0xAF]="U"
tbl[0xB0]="V"
tbl[0xB1]="W"
tbl[0xB2]="X"
tbl[0xB3]="Y"
tbl[0xB4]="Z"

function ValInTable(val)
  return val >= 0x81 and val <= 0xB4
end

function ReadString(address, size)
  result = ""
  for i=0,size-1 do
    val = emu.read(address + i,emu.memType.snesWorkRam)
    if ValInTable(val) then
      result = result .. tbl[val]
    elseif val ~= 0 then
      result = result .. "?"
    end
  end
  return result
end

function drawText(x,y,str,front,border,back,opacity)
  alpha = (255 - opacity) << 0x18
  emu.drawString(x, y - 1,str,alpha + border,back)
  emu.drawString(x + 1, y - 1,str,alpha + border,back)
  emu.drawString(x + 1, y,str,alpha + border,back)
  emu.drawString(x + 1, y + 1,str,alpha + border,back)
  emu.drawString(x, y + 1,str,alpha + border,back)
  emu.drawString(x - 1, y + 1,str,alpha + border,back)
  emu.drawString(x - 1, y,str,alpha + border,back)
  emu.drawString(x - 1, y - 1,str,alpha + border,back)
  emu.drawString(x, y,str,alpha + front,back)
end

function initialize()
    duration1 = 0
    duration2 = 0
    opacity = 0
    for i = 0,2 do
      lastexp[i+1] = -1
      nextlv[i+1] = -1
    end
    lastluc = -1
end

function printExpGain()
  ingame = emu.read(0x0100,emu.memType.snesWorkRam) == 0x5C
  if not ingame then
    initialize()
    return
  end

  if duration1 > 0 then
     duration1 = duration1 - 1
  elseif duration2 > 0 then
     duration2 = duration2 - 1
  elseif opacity > 0 then
     if opacity >= 10 then
       opacity = opacity - 10
       menu_x = menu_x - 4
     else
       opacity = 0
     end
  end
  
  local cnt = 0
  
  -- EXPERIENCE
  for i = 0,2 do
      name = ReadString(0xCC00 + (i*0xC),6)
  	val = emu.readWord(0xE18D + (i*0x200),emu.memType.snesWorkRam) + (emu.read(0xE18F + (i*0x200),emu.memType.snesWorkRam) << 0x10)
  	val2 = emu.readWord(0xE17D + (i*0x200),emu.memType.snesWorkRam) + (emu.read(0xE17F + (i*0x200),emu.memType.snesWorkRam) << 0x10)

  	if lastexp[i+1] == -1 or nextlv[i+1] == -1 then
  	  lastexp[i+1] = val
  	  nextlv[i+1] = val2
  	  lvup[i+1] = false
  	  newexp[i+1] = 0
  	  goto continue
  	end

  	if lastexp[i+1] ~= val and lastexp[i+1] > 0 then
  	  newexp[i+1] = val - lastexp[i+1] 
        if newexp[i+1] > 0 then
          lvup[i+1] = val >= nextlv[i+1]
          menu_x = 10
          duration1 = 100
          duration2 = 100
          opacity = 255
          strexp[i+1] = "+" .. newexp[i+1] .. sExp
          lastexp[i+1]=val
        else
          lvup[i+1] = false
          strexp[i+1] = ""
          goto continue
        end
      elseif duration1 == 0 then
        if newexp[i+1] > 0 then
 		 strexp[i+1] = nextlv[i+1] - lastexp[i+1] .. sLeft
          lastexp[i+1] = val
        end
  	end
      if opacity <= 0 then
        lvup[i+1] = false
        strexp[i+1] = ""
        newexp[i+1] = 0
        goto continue
      end
      if strexp[i+1] ~= "" then
        text = name .. " " ..  strexp[i+1]
        if lvup[i+1] then
          nextlv[i+1] = val2
          if duration1 > 0 then
            text = text .. sLevelUp
          end
        end
  	  drawText(menu_x,menu_y + (cnt * 10),text,0xFFFFFF,0x000000,0xFF000000,opacity)
  	  cnt = cnt + 1
  	end
    ::continue::
  end
  
  -- LUC
  val = emu.readWord(0xCC6A,emu.memType.snesWorkRam) + (emu.read(0xCC6C,emu.memType.snesWorkRam) << 0x10)
	newluc = 0

	if lastluc == -1 then
	  lastluc = val
	  strluc = val
	elseif lastluc ~= val and lastluc > 0 then
    newluc = val - lastluc
    if val > lastluc then
      duration1 = 100
      duration2 = 100
      opacity = 255
      strluc = "+" .. newluc
    else
      duration1 = 0
      duration2 = 0
      opacity = 0
      strluc = val
      lastluc = val
      return
    end
    lastluc = val
  elseif duration1 == 0 then
    strluc = lastluc
    lastluc = val
    duration1 = 0
  else
    lastluc = val
	end
  
  if lastluc > 0 then
	  drawText(menu_x,menu_y + (cnt * 10),strluc .. sLuc,0xFFFFFF,0x000000,0xFF000000,opacity)
	  cnt = cnt + 1
	end
end

--Callbacks
emu.addEventCallback(initialize, emu.eventType.stateLoaded);
emu.addEventCallback(printExpGain, emu.eventType.endFrame);

--Startup message
emu.displayMessage("Script", "Battle results")