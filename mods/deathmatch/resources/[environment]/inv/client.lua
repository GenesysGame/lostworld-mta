addEventHandler("onClientResourceStart",resourceRoot,
	function()
		window = guiCreateWindow(436, 322, 396, 435, "Inv", false)
        guiWindowSetSizable(window, false)

        grib = guiCreateGridList(9, 29, 377, 396, false, window)
        guiGridListAddColumn(grib, "Inventory", 0.9)
        guiSetVisible(window,false)
        setElementData ( localPlayer, "ves", 0)
        setElementData ( localPlayer, "objem", 0)
	end
)

addCommandHandler("add",
	function()
                table.insert(inv, "Предмет - "..table.maxn(inv)+1)
                for i,v in ipairs(inv) do
				    outputDebugString(inv[i])
			    end
                for i,v in ipairs(getElementChildren(scrollpane)) do
				    destroyElement(v)
			    end
			    for i,v in ipairs(inv) do
                    guiCreateLabel(5,i*20,90,20,inv[i],false,scrollpane)
			    end
	end
)

addCommandHandler("delete",
	function()
		if scrollpane then
			table.remove(inv, table.maxn(inv))
                for i,v in ipairs(inv) do
				    outputDebugString(inv[i])
			    end
                for i,v in ipairs(getElementChildren(scrollpane)) do
				    destroyElement(v)
			    end
			    for i,v in ipairs(inv) do
                    guiCreateLabel(5,i*20,90,20,inv[i],false,scrollpane)
			    end
		end
	end
)

function onLoad ( table )
	local character = localPlayer:getData("charModel")
	showCursor( not guiGetVisible(window))
	guiSetVisible(window, not guiGetVisible(window))
	guiGridListClear ( grib )
	if(guiGetVisible(window)) then
		for i, object in ipairs(table) do
					outputDebugString("OBJECT: "..i)
					if(object["charId"] == character.id) then 
						local row = guiGridListAddRow ( grib )
						guiGridListSetItemText ( grib, row, 1, "Название: "..object["name"].." | Вес: "..object["volume"].." | Объём: "..object["weight"].." | ID: "..object["id"], false, false )                                          
						outputDebugString(object["id"].." Добавлен")
					end
				-- end
				end
	end
			
end
addEvent( "onLoad", true )
addEventHandler( "onLoad", localPlayer, onLoad )
