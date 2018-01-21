local FileLibrary = {}
	local ExistingFileConnections = {}
local NetLibrary = {}
local CoreLibrary = {}
local Logs = {}

local VerKey = "" 

local function SecureConnection(Key)
	if (VerKey ~= "") and (Key == VerKey) then
		return true 
	else
		return "Permission denied"
	end
end

function CoreLibrary:Secure(Key, Toolbar)
	if VerKey == "" then
		VerKey = Key 
	else 
		return false 
	end
end

function CoreLibrary:WriteLog(...)
	local Str = ""
	for _,DataPoint in ipairs({...}) do
		Str = Str .. " " .. DataPoint
	end
	table.insert(Logs, Str, 1) 
end

function FileLibrary:AttachWatchHandler(Object)
	-- First we're going to check if it exists already
	if not Object then return end 
	
	for _,Handler in ipairs(ExistingFileConnections) do 
		local PotentialObject = Handler[1]
		if PotentialObject == Object then 
			print("Killing duplicate object")
			return -- This will kill the function 
		end
	end
	
	-- If we're this far, it means it doesn't exist already

	local NewConnection = Object.ChildAdded:Connect(function(Child)
		--CoreLibrary:WriteLog("New child detected...",Child.Name,"in",Object.Name)
		FileLibrary:ScanDirectory(Child)
		if Child.ClassName == "Script" then 
			CoreLibrary:WriteLog("SCRIPT DETECTED",Child.Name,Object.Name)
		end
	end)
	table.insert(ExistingFileConnections,{Object.Name, NewConnection})
end

function FileLibrary:ScanDirectory(Dir,Gui)
	-- Create recursive searching function
	local function Recur(SubDir)
		for Index,Directory in ipairs(SubDir:GetChildren()) do
			pcall(function() -- Will stop the thread from being killed from context permission issues. #ThanksRoblox
				if (Index % 100) == 0 then -- Only throttle every 50th index. Stops memory from being overflowed and crashing SutdiStudio
					wait()
				end
				-- Hook up the handler
				FileLibrary:AttachWatchHandler(Directory)
				
				-- Move onto the next directory. Everything in Lua is TECHNICALLY a directory 
				Recur(Directory)

				-- Update GUI 
				if Gui then 
					Gui.Text = "Securing game file:"..Directory.Name
				end
			end)
		end
	end
	
	Recur(Dir)
	return ExistingFileConnections
end

return {FileShield=FileLibrary;NetworkShield=NetLibrary;Core=CoreLibrary}
