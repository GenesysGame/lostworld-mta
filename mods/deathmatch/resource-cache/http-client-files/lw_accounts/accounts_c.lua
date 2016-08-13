-- Client file for accounts (GUI)

local scrW, scrH = guiGetScreenSize()
local loginWindow = nil
local registerWindow = nil
local createCharWindow = nil

addEvent("onClientShowLoginWindow", false)
addEvent("onClientShowRegisterWindow", false)
addEvent("onClientShowCreateCharWindow", false)
addEvent("client:updateLoginUI", true)

function updateLoginUI()
	outputDebugString("TEST ")
	if not localPlayer:getData("userModel") then
		triggerEvent("onClientShowLoginWindow", localPlayer)
	elseif not localPlayer:getData("charModel") then
		triggerEvent("onClientShowCreateCharWindow", localPlayer)
	else
		showWindow(nil)
	end
end
addEventHandler("client:updateLoginUI", getRootElement(), updateLoginUI)

function showLoginWindow()
	showWindow(loginWindow.wdw)
	setPlayerHudComponentVisible("all", false)
	-- активируем курсор игрока (чтобы он мог выбирать компонентф и кликать по ним)
    showCursor(true)
    -- отдаем контроль над клавиатурой GUI, позволяя игрокам (например) нажимать 'T', не открывая при этом одновременно чат
    guiSetInputEnabled(true)
end
addEventHandler("onClientShowLoginWindow", getRootElement(), showLoginWindow)

function showRegisterWindow()
	showWindow(registerWindow.wdw)
	setPlayerHudComponentVisible("all", false)
	-- активируем курсор игрока (чтобы он мог выбирать компонентф и кликать по ним)
    showCursor(true)
    -- отдаем контроль над клавиатурой GUI, позволяя игрокам (например) нажимать 'T', не открывая при этом одновременно чат
    guiSetInputEnabled(true)
end
addEventHandler("onClientShowRegisterWindow", getRootElement(), showLoginWindow)

function showCreateCharWindow()
	showWindow(createCharWindow.wdw)
	setPlayerHudComponentVisible("all", false)
	-- активируем курсор игрока (чтобы он мог выбирать компонентф и кликать по ним)
    showCursor(true)
    -- отдаем контроль над клавиатурой GUI, позволяя игрокам (например) нажимать 'T', не открывая при этом одновременно чат
    guiSetInputEnabled(true)
end
addEventHandler("onClientShowCreateCharWindow", getRootElement(), showLoginWindow)

function showWindow( wdw )
	guiSetVisible(loginWindow.wdw, wdw == loginWindow.wdw)
	guiSetVisible(registerWindow.wdw, wdw == registerWindow.wdw)
	guiSetVisible(createCharWindow.wdw, wdw == createCharWindow.wdw)

	if wdw == nil then
		guiSetInputEnabled(wdw ~= nil)
		showCursor(wdw ~= nil)
	end
end

function createLoginWindow()
	local x = 0.5 * scrW - 150
	local y = 0.5 * scrH - 100
	local width = 300
	local height = 200
	local aTable = {}
	aTable.wdw = guiCreateWindow(x, y, width, height, "Login Window 0.01", false)

	x = 20
	y = 40
	width = 260
	height = 20
	guiCreateLabel(x, y, width, height, "Login:", false, aTable.wdw)

	y = 100
	guiCreateLabel(x, y, width, height, "Password:", false, aTable.wdw)

	y = 60
	height = 30
	aTable.edtUser = guiCreateEdit(x, y, width, height, "", false, aTable.wdw)
	y = 120
	aTable.edtPass = guiCreateEdit(x, y, width, height, "", false, aTable.wdw)
 
	guiEditSetMaxLength(aTable.edtUser, 32)
	guiEditSetMaxLength(aTable.edtPass, 32)
	guiEditSetMasked(aTable.edtPass, true)
 
	x = 160
	y = 160
	width = 120
	height = 30
	aTable.btnLogin = guiCreateButton(x, y, width, height, "Log In", false, aTable.wdw)
	addEventHandler("onClientGUIClick", aTable.btnLogin, clientSubmitLogin, false)
 
	-- делаем окно невидимым
	guiSetVisible(aTable.wdw, false)
	return aTable
end

function createRegisterWindow()
	local x = 0.5 * scrW - 150
	local y = 0.5 * scrH - 100
	local width = 300
	local height = 200
	local aTable = {}
	aTable.wdw = guiCreateWindow(x, y, width, height, "Register Window 0.01", false)

	guiSetVisible(aTable.wdw, false)
	return aTable
end

function createCreateCharWindow()
	local x = 0.5 * scrW - 150
	local y = 0.5 * scrH - 100
	local width = 300
	local height = 200
	local aTable = {}
	aTable.wdw = guiCreateWindow(x, y, width, height, "Create Character Window 0.01", false)

	guiSetVisible(aTable.wdw, false)
	return aTable
end

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()),	function ()
	loginWindow = createLoginWindow()
	registerWindow = createRegisterWindow()
	createCharWindow = createCreateCharWindow()
end)

-- Button Click

function clientSubmitLogin(button,state)
	-- if our login button was clicked with the left mouse button, and the state of the mouse button is up
	if button == "left" and state == "up" then
		local username = loginWindow.edtUser.text
		local pass = loginWindow.edtPass.text
		if username and pass then
			triggerServerEvent("server:login", getRootElement(), username, pass)
		end
		-- -- move the input focus back onto the game (allowing players to move around, open the chatbox, etc)
		-- guiSetInputEnabled(false)
		-- -- hide the window and all the components
		-- guiSetVisible(wdwLogin, false)
		-- -- hide the mouse cursor
		-- showCursor(false)
	end
end