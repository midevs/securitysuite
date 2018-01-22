local FileLibrary = {}
	local ExistingFileConnections = {}
local NetLibrary = {}
local CoreLibrary = {}
local Logs = {}

local VerKey = "" 

-- Function to check if the keys match up 
local function SecureConnection(Key)
	if (VerKey ~= "") and (Key == VerKey) then
		return true 
	else
		return "Permission denied"
	end
end

-- This allows the host plugin to write a new key that the library will require. This is hardcoded to only be ran ONCE! 
function CoreLibrary:Secure(Key, Toolbar)
	if VerKey == "" then
		VerKey = Key 
		return true
	else 
		return false 
	end
end

-- Writes all input to a log that will be accessable in the UI (waiting for the new plugin UI upgrade)
function CoreLibrary:WriteLog(Key, ...)
	-- This small tool is to make sure it's the host process reaching us and not an imposter
	local Verify = SecureConnection(Key)
	if not (Verify == true) then print(Verify) return Verify end 

	local Str = ""
	for _,DataPoint in ipairs({...}) do
		Str = Str .. " " .. DataPoint
	end
	table.insert(Logs, 1, Str) 
end

-- This will 
function FileLibrary:AttachWatchHandler(Key, Object)
	-- This small tool is to make sure it's the host process reaching us and not an imposter
	local Verify = SecureConnection(Key)
	if not (Verify == true) then print(Verify) return Verify end 

	-- First we're going to check if it exists already
	if not Object then return end 
	
	for _,Handler in ipairs(ExistingFileConnections) do 
		local PotentialObject = Handler[1] --got string value, Object.Name
		if PotentialObject == Object.Name then  --got instance, Object, attempt to compare Object with a string, will always be false.
			print("Killing duplicate object") -- DEBUG: NEVER GET THIS PRINT
			return -- This will kill the function 
		end
	end
	
	-- If we're this far, it means it doesn't exist already
	local NewConnection = Object.ChildAdded:Connect(function(Child)
		CoreLibrary:WriteLog(Key, "New child detected...",Child.Name,"in",Object.Name)
		FileLibrary:ScanDirectory(Key, Child)
	end)
	table.insert(ExistingFileConnections,{Object.Name, NewConnection})
end

function FileLibrary:ScanDirectory(Key, Dir,Gui)

	-- This small tool is to make sure it's the host process reaching us and not an imposter
	local Verify = SecureConnection(Key)
	if not (Verify == true) then print(Verify) return Verify end 

	-- Create recursive searching function
	local function Recur(SubDir)
		for Index,Directory in ipairs(SubDir:GetChildren()) do
			pcall(function() -- Will stop the thread from being killed from context permission issues. #ThanksRoblox
				if (Index % 100) == 0 then -- Only throttle every 50th index. Stops memory from being overflowed and crashing SutdiStudio
					wait()
				end
				-- Hook up the handler
				FileLibrary:AttachWatchHandler(Key, Directory)
				
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

	-- Back to tower!
	return ExistingFileConnections
end

-- Ugly:
return {FileShield=FileLibrary;NetworkShield=NetLibrary;Core=CoreLibrary}
