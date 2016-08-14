-- Client file for accounts (GUI)

local scrW, scrH = guiGetScreenSize()
local loginWindow = nil
local registerWindow = nil
local createCharWindow = nil

addEvent("client:updateLoginUI", true)

function showStartUI()
	Camera.fade(true, 5)
	local startX, startY, startZ = 500, 2580, 78
	local lookAtX, lookAtY, lookAtZ = 300, 2450, 17
	Camera.setMatrix(startX, startY, startZ, lookAtX, lookAtY, lookAtZ)
	setPlayerHudComponentVisible("all", false)
	setPlayerHudComponentVisible("all", false)
	showCursor(true)
	guiSetInputEnabled(true)
end

function updateLoginUI()
	if not localPlayer:getData("userModel") then
		showStartUI()
		if not guiGetVisible(registerWindow.wdw) then
			showWindow(loginWindow.wdw)
		end
	elseif not localPlayer:getData("charModel") then
		showStartUI()
		showWindow(createCharWindow.wdw)
	else
		showWindow(nil)
	end
end
addEventHandler("client:updateLoginUI", getRootElement(), updateLoginUI)

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
	aTable.wdw = guiCreateWindow(x, y, width, height, "Login Window v0.01", false)

	x = 20
	y = 40
	width = 260
	height = 20
	guiCreateLabel(x, y, width, height, "Username:", false, aTable.wdw)

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
	addEventHandler("onClientGUIClick", aTable.btnLogin, clientButtonClick, false)

	x = 20
	aTable.btnRegister = guiCreateButton(x, y, width, height, "Register", false, aTable.wdw)
	addEventHandler("onClientGUIClick", aTable.btnRegister, clientButtonClick, false)

	-- делаем окно невидимым
	guiSetVisible(aTable.wdw, false)
	return aTable
end

function createRegisterWindow()
	local x = 0.5 * scrW - 150
	local y = 0.5 * scrH - 130
	local width = 300
	local height = 260
	local aTable = {}
	aTable.wdw = guiCreateWindow(x, y, width, height, "Register Window v0.01", false)

	x = 20
	y = 40
	width = 260
	height = 20
	guiCreateLabel(x, y, width, height, "Username:", false, aTable.wdw)

	y = 100
	guiCreateLabel(x, y, width, height, "Password:", false, aTable.wdw)

	y = 160
	guiCreateLabel(x, y, width, height, "Repeat password:", false, aTable.wdw)

	y = 60
	height = 30
	aTable.edtUser = guiCreateEdit(x, y, width, height, "", false, aTable.wdw)
	y = 120
	aTable.edtPass = guiCreateEdit(x, y, width, height, "", false, aTable.wdw)
	y = 180
	aTable.edtRepeatPass = guiCreateEdit(x, y, width, height, "", false, aTable.wdw)
 
	guiEditSetMaxLength(aTable.edtUser, 32)
	guiEditSetMaxLength(aTable.edtPass, 32)
	guiEditSetMaxLength(aTable.edtRepeatPass, 32)
	guiEditSetMasked(aTable.edtPass, true)
	guiEditSetMasked(aTable.edtRepeatPass, true)
 
	x = 160
	y = 220
	width = 120
	height = 30
	aTable.btnRegister = guiCreateButton(x, y, width, height, "Register", false, aTable.wdw)
	addEventHandler("onClientGUIClick", aTable.btnRegister, clientButtonClick, false)

	x = 20
	aTable.btnBack = guiCreateButton(x, y, width, height, "Back", false, aTable.wdw)
	addEventHandler("onClientGUIClick", aTable.btnBack, clientButtonClick, false)

	guiSetVisible(aTable.wdw, false)
	return aTable
end

function createCreateCharWindow()
	local x = 0.5 * scrW - 150
	local y = 0.5 * scrH - 100
	local width = 300
	local height = 200
	local aTable = {}
	aTable.wdw = guiCreateWindow(x, y, width, height, "Create Character Window v0.01", false)

	guiSetVisible(aTable.wdw, false)
	return aTable
end

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()),	function ( res )
	if res.name == "lw_accounts" then
		loginWindow = createLoginWindow()
		registerWindow = createRegisterWindow()
		createCharWindow = createCreateCharWindow()

		updateLoginUI()
	end
end)

-- Button Click
function clientButtonClick(button,state)
	-- if our login button was clicked with the left mouse button, and the state of the mouse button is up
	if button == "left" and state == "up" then
		if source == loginWindow.btnLogin then -- login button on login window
			local username = loginWindow.edtUser.text
			local pass = loginWindow.edtPass.text
			if username and pass then
				triggerServerEvent("server:login", getRootElement(), username, pass)
			end
		elseif source == loginWindow.btnRegister then -- register button on login window
			showWindow(registerWindow.wdw)
		elseif source == registerWindow.btnBack then -- back button on register window
			showWindow(loginWindow.wdw)
		elseif source == registerWindow.btnRegister then -- register button on register window
			local username = registerWindow.edtUser.text
			local pass = registerWindow.edtPass.text
			local repeatPass = registerWindow.edtRepeatPass.text
			if username and pass and repeatPass then
				outputDebugString("Start register "..username.." "..tostring(pass == repeatPass))
				if pass == repeatPass then
					triggerServerEvent("server:register", getRootElement(), username, pass)
				else
					outputChatBox("Введенные пароли не совпадают.")
				end
			end
		end
	end
end