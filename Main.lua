-- Dylan / dCarr2
-- 1/21/2018

local Host = script.Parent 
	local Assets = Host:WaitForChild("Assets")

local Base = {}
local Library 
	local FileShield
	local NetworkShield  
	local Core 

local Debug = true 
local KeyVerificationLength = 16
local LocalStoragePairString = "DylsSecuritySuiteData [DO NOT REMOVE]"
local RuntimeName = "D's  Security Suite Server-Side"

-- Plugins don't like dictionaries so we're doing a bit of converting magic:
local DefaultFileData = {
	Installed = tick();
	LastOpened = tick();
	AllowedHosts = {};
}

function Base:print(kill, ...)
	if not Debug then return end
	local Str 
	
	if kill == 1 then 
		Str = Host.Name.." FATAL:"
	else
		Str = Host.Name..":"
	end
	
	for _,Data in ipairs({...}) do
		Str = Str .. " " .. Data 
	end
	
	warn(Str)
	
	if kill == 1 then script.Disabled = true end 
end

Base:print(0, "Starting Dylan's Security Suite...")

function Base:AttemptHttp()
	local Attempt = pcall(function()
		game.HttpService:GetAsync("http://GitHub.com")
	end)

	return Attempt
end

function Base:GenKey(SkipSave)
	local PoteKey = "ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789!@#$%^&*()_+;'.,/"
	
	local function RandPlacement()
		local Number = math.random(1, string.len(PoteKey))
		return string.sub(PoteKey, Number, Number)
	end
	
	local KeyGen = ""
	
	local function CreateWholeKey()		
		for i = 1, KeyVerificationLength do
			KeyGen = KeyGen.. RandPlacement()
		end
	
		-- Don't run if a bool is passed 
		if (not SkipSave) then
			local LatestValues = plugin:GetSetting("InstallationIDs")
			if LatestValues then
				for _,KeyId in ipairs(LatestValues) do 
					if KeyId == KeyGen then
						-- Back to tower!
						return CreateWholeKey()
					end
				end
			end
		end
	end
	
	CreateWholeKey()
	
	return KeyGen 
end

function Base:LoadAsset(name) 
	local PossibleMatch = Assets:WaitForChild(name, 1)

	if not PossibleMatch then 
		Base:print(0, "ERROR: Did not find",name,"in assets!")
	end
	
	return PossibleMatch:Clone()
end


function Base:Initialize()
	-- Let's see if we need to put up the splash screen
	
	-- This ugly stuff is JUST for the UI... :( ----------------------
	local Container = (game.CoreGui:FindFirstChild("DylsSecurityGui") or Instance.new("ScreenGui")) -- Create or find ScreenGui 
		Container.Parent = game.CoreGui
		Container.Name = "DylsSecurityGui" -- Clever, I know. Heh. 
		
	local LoadingScreen = Base:LoadAsset("Initialization") -- Get loading screen
	if not LoadingScreen then Base:print(0, "Could not locate setup screen... modded source?") end -- Non-fatal error if UI is missing
	LoadingScreen.Parent = Container -- Put it in the CoreGUI ScreenGui Obj
	game.StarterGui.ShowDevelopmentGui = false 	-- Hide user GUI
	
	-- Keep the shaders in records so we can quickly remove them 
	local Tmp = {}
	for _,Shader in ipairs(LoadingScreen:GetChildren()) do
		if Shader.Name=="Splash" then 
			Shader.Parent = game.Lighting
			table.insert(Tmp, Shader) 
		end
	end
			
	-- Animate it! 
	spawn(function()
		while LoadingScreen.Visible == true do wait()
			LoadingScreen.Spinner.Rotation = LoadingScreen.Spinner.Rotation + 10
		end
	end)
		
	-- For when we need to get rid of the UI
	local function ForceLoaderToClose()
		LoadingScreen.Progress.Text = "Closing loading UI..."
			
		-- Delete shaders
		for _,Shader in ipairs(Tmp) do
			Shader:Destroy() 
		end
		
		-- Remove UI 
		LoadingScreen.Visible = false wait() -- :( 
		game.StarterGui.ShowDevelopmentGui = true 
		LoadingScreen:Destroy()
	end
	---------------------------------------

	local NewKey
	local PossibleMatch = game.ServerStorage:FindFirstChild(LocalStoragePairString)
	if PossibleMatch then 
		LoadingScreen.Progress.Text = "Previous installation found... Verifying save integrity"
		Base:print(0,"Place has been loaded with plugin before... continuing")
		NewKey = PossibleMatch.Value 

		-- Quick check to make sure we're on the same page here!
		local CheckPluginMemory = plugin:GetSetting(NewKey.. "_Installed")
		-- uh oh! 
		if not CheckPluginMemory then Base:print(1, "Corrupted file installation? Things are not matching up in the plugin settings. Try reinstalling") PossibleMatch:Destroy() end 

	else
		Base:print(0,"New file! Let's setup!")
	
		LoadingScreen.Progress.Text = "Performing first time setup.. Creating installation files"
		
		NewKey = Base:GenKey()
		if not NewKey then Base:print(1, "ERROR generating new key reference for new file... plugin must stop") end 

		-- We need to store the ID somewhere inside the file so we can match it up with the plugin's memory later
		local LocalFile = Instance.new("StringValue")
			LocalFile.Name = LocalStoragePairString
			LocalFile.Parent = game.ServerStorage
			LocalFile.Value = NewKey 

		-- Let's see if there is any installations already :) 
		local ExistingData = plugin:GetSetting("InstallationIDs") or {}
		table.insert(ExistingData, NewKey)
		plugin:SetSetting("InstallationIDs", ExistingData) -- Upload! 
		
		-- Here we are going to update the table from up there with the "new" information. 
		-- Plugins don't like dictionaries so this isn't the most pleasent way to do this. Works though.
		LoadingScreen.Progress.Text = "Reading data from memory..."
		for Key, Value in pairs(DefaultFileData) do			
			plugin:SetSetting(NewKey.."_"..Key, Value)
		end 
			
		
	end

	LoadingScreen.Progress.Text = "Reading data from memory..."
	for Key, Value in pairs(DefaultFileData) do			
		local NewValue = (plugin:GetSetting(NewKey.."_"..Key) or Value)
		Key = NewValue
	end

	LoadingScreen.Progress.Text = "Installing server runtime..."
	if (not game.ServerScriptService:FindFirstChild(RuntimeName)) then
		local Runtime = game:GetService("InsertService"):LoadAsset(1347744157)
		Runtime[RuntimeName].Parent = game.ServerScriptService
		Runtime:Destroy()
	end
	
	-- Let's see if we can download the latest version from GitHub real quick
	LoadingScreen.Progress.Text = "Installing latest library from GitHub..." 

	local HttpEnabled = Base:AttemptHttp()

	if HttpEnabled then 

		local NewLibCode = game.HttpService:GetAsync("https://raw.githubusercontent.com/realdylancarr/securitysuite/master/Library.lua", true)
		if string.len(NewLibCode) > 50 then
			script.Parent.Library.Source = NewLibCode
			Base:print(0, "Sucessfully downloaded new source from GitHub Repo.")
		else
			Base:print(0, "Autoupdating error... malformed request response")
		end 
	else
		Base:print(0,"HTTPService is not enabled. Autoupdating has been disabled.")
	end
		
	-- Set up latest API 
	Library = require(script.Parent:WaitForChild("Library"))
		FileShield = Library.FileShield 
		NetworkShield = Library.NetworkShield 
		Core = Library.Core

	LoadingScreen.Progress.Text = "Generating UI..."
	local toolbar = plugin:CreateToolbar(script.Parent.Name)

	local DashBtn = toolbar:CreateButton(
		"Open Dashboard",
		"Click To Open The Security Dashboard",
		"http://www.roblox.com/asset/?id=1347729492"
	)
	local QuickScanBtn = toolbar:CreateButton(
		"Hyper Scan",
		"Secure your game with 1 click",
		"http://www.roblox.com/asset/?id=1347761802"
	)
	local OptimizeBtn = toolbar:CreateButton(
		"Optimize Game",
		"Optimize your game with 1 click",
		"http://www.roblox.com/asset/?id=1347777987"
	)
	local NetStatBtn = toolbar:CreateButton( 
		"Network Leak Test",
		"Provides all available network info",
		"http://www.roblox.com/asset/?id=1347778068"
	)
	local SettingsBtn = toolbar:CreateButton( 
		"Quick Settings",
		"Quick access to settings",
		"http://www.roblox.com/asset/?id=1347783696"
	)

	LoadingScreen.Progress.Text = "Establishing a secure connection..."
	local LibraryKey = Base:GenKey(true)
	local Status = Core:Secure(LibraryKey, toolbar)

	if (not Status) then 
		Base:print(1, "Error establishing secure connection to plugin library.")
		Base:print(1, "This is what the library returned: ", Status)
		return nil
	end
	
	LoadingScreen.Progress.Text = "Enabling file shield..."
	
	local Connections = FileShield:ScanDirectory(LibraryKey, game, LoadingScreen.Progress)
	
	if (type(Connections) == "table") and (#Connections > 1) then
		Base:print(0, "Successfully secured",#Connections,"directories.")
	else
		Base:print(1, "Directory firewall failed to start. Modded source maybe?")
	end

	ForceLoaderToClose()
	Base:print(0, "Done initialization!")
end


Base:Initialize()
