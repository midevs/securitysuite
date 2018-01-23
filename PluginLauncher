--[[
	   ___                               .___                                     .   
	 .'   `. , __   `   __.  , __        /   \ .___    __.      .    ___    ___  _/_  
	 |     | |'  `. | .'   \ |'  `.      |,_-' /   \ .'   \     \  .'   ` .'   `  |   
	 |     | |    | | |    | |    |      |     |   ' |    |     |  |----' |       |   
	  `.__.' /    | /  `._.' /    |      /     /      `._.' /`  |  `.___,  `._.'  \__/
	                                                        \___/`                   
		// Onion Security Suite // 
		Started on January 18th, 2018 
	
		Main Contributors: 
			- JupiterGuy2/dCarr2  
		
		Managed & Published by Millennium Interactive
		
		------------
		
		// What the h*ck is this script for? //
		Onion Security works by creating multiple layers within a Studio instance
		so it can monitor all the nooks and krammies for malicious activity.
		
		This plugin will do the following:
			* Establish the plugin environment
			* Download latest Roblox-repo source of Onion Security 
			* Install 
--]]

---------------------------------------------------------------------------------------------------------------------
local AssetSource   = 1347744157 -- This is the Roblox repo for Onion's security code 
local LibLinkSource = "https://github.com/dylancdev/securitysuite/blob/master/Library.lua" -- todo: fix -------------
---------------------------------------------------------------------------------------------------------------------
local InsertServ	= game:GetService("InsertService")
local HttpServ		= game:GetService("HttpService")
local ServScr		= game:GetService("ServerScriptService")
local ServStg		= game:GetService("ServerStorage")
local IdentStr 		= "Onion Security Suite"
---------------------------------------------------------------------------------------------------------------------
local Host 			= script.Parent
---------------------------------------------------------------------------------------------------------------------
local RepoModel 	= InsertServ:LoadAsset(AssetSource)


if not (game.ServerScriptService:FindFirstChild(IdentStr)) and not (game.ServerStorage:FindFirstChild(IdentStr)) then
	if RepoModel then -- If it downloaded correctly

		-- First, cache the instances under a variable for future reference
		local DwnldScriptService = RepoModel[IdentStr].ScriptService
		local DwnldStorage = RepoModel[IdentStr].Storage

		-- Extract them to their proper locations
		DwnldScriptService.Parent = ServScr
		DwnldStorage.Parent = ServStg

		-- Rename them (they were only named like that before so knew where to install them)
		DwnldScriptService.Name = IdentStr
		DwnldStorage.Name = IdentStr
		
		-- Install the server code to our plugin, allowing us to access a higher security clearance 
		-- Strange way to do this. Only way I can get the source to execute though 
		Host.Base.Source = "return (function(plugin) "..DwnldScriptService.Base.Source.. "end)"
		-- Execute it under a module so it will properly run under the plugin 
		require(Host.Base)(plugin) -- Send the plugin API to the new script

		-- Enable the server script for usage when the game is running
		DwnldScriptService.Base.Disabled = false 
	else
		-- It didn't download properly. Is Roblox down? 
		warn(IdentStr..": Fatal error: could not download model")
	end
else -- We found something! Let's verify.

end
