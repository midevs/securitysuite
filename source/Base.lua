--[[
   ___                               .___                                     .   
 .'   `. , __   `   __.  , __        /   \ .___    __.      .    ___    ___  _/_  
 |     | |'  `. | .'   \ |'  `.      |,_-' /   \ .'   \     \  .'   ` .'   `  |   
 |     | |    | | |    | |    |      |     |   ' |    |     |  |----' |       |   
  `.__.' /    | /  `._.' /    |      /     /      `._.' /`  |  `.___,  `._.'  \__/
                                                        \___/`                   
	Onion Security Suite
	Started on January 18th, 2018 

	Main Contributors: 
		- JupiterGuy2/dCarr2  
	
	Managed & Published by Millennium Interactive
]]--

-- // Environment setup // --

local Host 								= script.Parent -- Less annoying way of typing "script.Parent" every 5 seconds
local Base 		  	 					= {} -- This will hold some internal functions
local LocalCache    					= {} -- This holds a small amount of memory for quick internal usage 
local SecurityKey						= nil -- Later, this will be set to a 16bit key later that will ensure very secure communication between modules
local Library 							= nil -- Later, this will be set to our external module library
local RunService 						= game:GetService("RunService") -- We need this service to figure out what the h*ck we're doing
local LogService						= game:GetService("LogService") -- We need to use this to detect the environment.. unfortunately 
local HttpService						= game:GetService("HttpService") -- We need this to access the sweet 'ol cloud
local API  			 					= { -- This is a set of functions/data that can be utilized by the runtime/module libraries

	ShowNotification 					= (function(NotifData) -- Lets external services utilize the GUI notifications 
	end)
}

---------------------------------------------------------------------------------------------

-- // Adding functionality to our local environment // -- 

LocalCache.RuntimeName = "Onion Security Suite" -- This is an identifiable string so people don't remove our precious files in ServerSettings

print("IsClient:",RunService:IsClient(),"IsStudio:",RunService:IsStudio(),"IsServer:",RunService:IsServer())

function Base:print(...) -- This function is designed to handle place branding/add logging functionality to the internal Lua print function
	if (LocalCache.DisableOutput) then return end -- If the DisableOutput bool is enabled, don't run this function 

	local Str = "[ "..Host.Name.." ]: " -- Create the prefix for our cool new string

	for _,PassedPar in ipairs({...}) do -- Create loop to go through all the passed parameters and add them together
		Str = Str .. " " .. tostring(PassedPar) -- Append a forced-string version of the parameter to the existing string 
	end

	warn(Str) -- Send it to the output with fancy orange text 
end

-- This will get around the invalid security level to access HTTPEnabled.
-- We want to:
--	* Check if a last tick cache existed, if it does... Only proceed if it's < 60 seconds. Unless the "force" parameter is passed as true
--  * Pcall a function sending a ping to a versatile web host
--  * If Pcall returns that it failed, we know that HttpEnabled is set to FALSE.
function Base:CheckHttpAvailability(force)
	local LastHttpAttempt = (LocalCache.LastHttpAttempt or 0) -- See if the last Http attempt is recorded, if not then set to 0 so it can be overwritten

	if not (((tick() - LastHttpAttempt) < 60) or (force)) then -- If it's been at least 60 seconds  
		return (LocalCache.LastHttpTestResult or false) -- Kill the function, return value 
	end

	local Attempt = pcall(function() game:GetService("HttpService"):GetAsync("https//google.ca") end) 
end 

-- Roblox's API to do this is broken and terrible so we're gonna have to do something hacky 
function Base:FigureOutEnv()
	local PluginTest = pcall(function() plugin:GetSetting(math.random()) end) -- We're gonna try to load a fake setting under a pcall to see if it's running under the plugin security level
	if PluginTest == true then -- If true, we know it's a plugin
		return "eplugin" -- can't say "plugin" or Lua will have a hissy fit 
	else
		return "server" -- Not a plugin 
	end
end

local ExecutionInstructions = {
	eplugin = function()
		Base:print("Plugin mode")
	end;
	server = function() 
		Base:print("Server mode")
	end;
}

ExecutionInstructions[Base:FigureOutEnv()]()
