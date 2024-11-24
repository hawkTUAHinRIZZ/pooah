local StarterGui = game:GetService("StarterGui")

--[[
local table_ = {}

function getgenv()
	return table_
end

function writefile(name, contents)
	print(name, contents)
end

wait(5)
]]

xpcall(function()
	StarterGui:SetCore("SendNotification", {
		["Title"] = "DOWNLOADING SHARED LIBRARY";
		["Text"] = "This could take a while";
		["Duration"] = 5;
	})
	
	local Shared = loadstring(game:HttpGet("https://raw.githubusercontent.com/withohiogyattirizz/shared/refs/heads/main/skibidi.lua", true))
	
	StarterGui:SetCore("SendNotification", {
		["Title"] = "DOWNLOADING CONVERTER LIBRARY";
		["Text"] = "This could take a while";
		["Duration"] = 5;
	})
	
	local Converter = loadstring(game:HttpGet("https://raw.githubusercontent.com/withohiogyattirizz/tester/refs/heads/main/test.lua", true))
	
	local ChatDB = false
	
	local HTTPService = game:GetService("HttpService")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Lighting = game:GetService("Lighting")
	local Players = game:GetService("Players")
	local UIS = game:GetService("UserInputService")
	local MaterialService = game:GetService("MaterialService")
	local TextChatService = game:GetService("TextChatService")
	local StarterGui = game:GetService("StarterGui")
	
	local Player = Players.LocalPlayer

	local IgnorableObjects = {"WindTrail", "NewDirt", "WaterImpact", "Footprint", "Part"}
	local UnnededClasses = {"SpecialMesh", "CylinderMesh", "UnionOperation"}
	local GlobalIgnorableNames = {"Chat", "BubbleChat", "Freecam"}
	
	local MobNames = {
		".bountyhunter", 
		".golem", 
		".megalodaunt", 
		".pirate_black", 
		".mudskipper", 
		".bandit", 
		".banditleader", 
		".deepknight", 
		".dukecultist", 
		".brainsuckerduke", 
		".thief",
		".hive_scout",
		".summer_thug",
		".special_thug",
		".gremor_nomad_leader",
		".fighter_union",
		".brainsucker"
	}

	local CloneDetectionClasses = {
		["Sound"] = {
			"SoundId";
		};

		["Part"] = {
			"Name";
			"Size";
			"Color";
			"Material";
			"Transparency";
		};

		["Highlight"] = {
			"FillColor";
			"OutlineColor";
			"FillTransparency";
			"OutlineTransparency";
			"DepthMode";
		};

		["MeshPart"] = {
			"Name";
			"MeshId";
			"Size";
		};

		["Weld"] = {
			"Part1";
			"Part0";
			"C0";
			"C1";
		};

		["Motor6D"] = {
			"Part1";
			"Part0";
			"C0";
			"C1";
		};

		["ValueBase"] = {
			"Name";
			"Value";
		};
	}

	local function SaveObjectToFile(Object, Name)
		local Data; 

		xpcall(function()
			Shared:Notify("CONVERTING DATA", "Refrain from doing any action.", 5)

			local Data = tostring(Converter:ConvertToSaveable(Object, true))

			xpcall(function()
				Shared:Notify("DATA CONVERTED", "Refrain from doing any action.", 5)

				writefile(`{Name}.txt`, Data)

				Shared:Notify("FILE SAVED", `You can find the save at "workspace/{Name}", you can resume now.`, 5)
			end, function(err)
				Shared:Notify("FAILED TO SAVE OBJECT", tostring(err), 5)
			end)
		end, function(err)
			Shared:Notify("FAILED TO CONVERT OBJECT", tostring(err), 5)
		end)
	end

	Shared:Notify("API INITIALIZED", "Beginning next step", 2)

	getgenv()["SessionId"] = getgenv()["SessionId"] or HTTPService:GenerateGUID(false)
	getgenv()["AddYield"] = getgenv()["AddYield"] or 0.2

	if getgenv()["Connections"] then
		for ConnectionName, Connection in getgenv()["Connections"] do
			Connection:Disconnect()
		end
	end

	getgenv()["Connections"] = {}
	getgenv()["SaveCount"] = getgenv()["SaveCount"] or 0
	getgenv()["CharacterSaves"] = getgenv()["CharacterSaves"] or 0
	getgenv()["UISaves"] = getgenv()["UISaves"] or 0
	getgenv()["StarterUISaves"] = getgenv()["StarterUISaves"] or 0
	
	if getgenv()["Folder"] then
		getgenv().Folder:Destroy()
	end

	local function Disconnect(ConnectionName)
		if getgenv().Connections[ConnectionName] then
			getgenv().Connections[ConnectionName]:Disconnect()
			getgenv().Connections[ConnectionName] = nil
		end
	end

	local function Connect(ConnectionName, Traceback)
		getgenv().Connections[ConnectionName] = Traceback
	end

	local Folder = Instance.new("Folder", MaterialService)
	Folder.Name = `Instance_{getgenv()["SessionId"]}`

	local GlobalStorage = Instance.new("Folder", Folder)
	GlobalStorage.Name = "Global"

	local ReplicatedStorageStorage = Instance.new("Folder", GlobalStorage)
	ReplicatedStorageStorage.Name = "ReplicatedStorage"

	local WorkspaceStorage = Instance.new("Folder", GlobalStorage)
	WorkspaceStorage.Name = "Workspace"

	local ThrownStorage = Instance.new("Folder", Folder)
	ThrownStorage.Name = "Thrown"

	local PlayerSpecificStorage = Instance.new("Folder", Folder)
	PlayerSpecificStorage.Name = "PlayerSpecific"
	
	local TemporaryStorage = Instance.new("Folder", Folder)
	TemporaryStorage.Name = "Temporary"

	getgenv()["Folder"] = Folder

	local TargettingPlayerFolder, AnimationsFolder, CharacterFolder;
	local TargettingCharacter;

	local CharacterSearchEnabled, ThrownSearchEnabled = true, true;
	local DupeRemovalEnabled, MobRemovalEnabled = true, true;

	local function SaveAnimations(Target)
		xpcall(function()
			local AnimationHandler = Target:FindFirstChildOfClass("Humanoid") or Target:FindFirstChildOfClass("AnimationController") or Target:FindFirstChildOfClass("Animator")

			if AnimationsFolder and Target ~= nil and AnimationHandler then
				for _, Track in next, AnimationHandler:GetPlayingAnimationTracks() do 
					local Id = Track.Animation.AnimationId

					if AnimationsFolder:FindFirstChild(Id) then continue end

					local Value = Instance.new("StringValue", AnimationsFolder)
					Value.Name = Id
					Value.Value = Id
				end
			end
		end, function(err)
			warn(`RANDOM ANIMATON SAVING ERROR: {err}`)
		end)
	end

	local function AnyObjectWithPropertysLike(Class, SecondaryObject, PropertiesToCheck, Location)
		local Result = false

		xpcall(function()
			for _, Object in Location:GetDescendants() do
				if Object:IsA(Class) then
					local SameOnes = 0

					for _, PropertyName in PropertiesToCheck do
						if Object[PropertyName] == SecondaryObject[PropertyName] then
							SameOnes += 1
						end
					end

					if SameOnes >= #PropertiesToCheck then
						Result = true

						break
					end
				end
			end

			return Result
		end, function(err)
			warn(`FAILED TO CHECK IF DUPLICATE OBJECT "{SecondaryObject}:{Class}": {err}`)
		end)

		return Result
	end

	local function StoreObject(Object, Location)
		xpcall(function()
			if Object == nil or (Object ~= nil and Object.Parent == nil) then return end

			if table.find(IgnorableObjects, Object.Name) or table.find(UnnededClasses, Object.ClassName) then return end
			if table.find(GlobalIgnorableNames, Object.Name) then return end
			
			local OriginalParent = Object.Parent

			task.wait(getgenv()["AddYield"])

			if Object == nil or (Object ~= nil and Object.Parent ~= nil and Object.Parent ~= OriginalParent) then return end
			if Object.ClassName == "Model" then 
				if #Object:GetChildren() <= 0 then return end

				if MobRemovalEnabled then
					local IsAMob = false

					for _, MobName in MobNames do
						local FindOperation = string.find(Object.Name, MobName)

						if FindOperation ~= nil and tonumber(FindOperation) ~= nil and (FindOperation <= 1 or FindOperation == string.len(MobName)) then
							IsAMob = true
							break
						end
					end

					if IsAMob then return end
				end
				
				local AnimationHandler = Object:FindFirstChildOfClass("Humanoid") or Object:FindFirstChildOfClass("AnimationController") or Object:FindFirstChildOfClass("Animator")
				
				if AnimationHandler then
					SaveAnimations(Object)
					
					for _, Track in next, AnimationHandler:GetPlayingAnimationTracks() do
						pcall(function()
							Track:Stop(0)
						end)
					end

					task.wait(0.05)
				end
			end

			if DupeRemovalEnabled then
				local Proceed = true

				for Class, CloneData in CloneDetectionClasses do
					if Object:IsA(Class) then
						if AnyObjectWithPropertysLike(Class, Object, CloneData, Location) then
							Proceed = false
							break
						end
					end
				end

				if not Proceed then
					warn(`PREVENTED DUPLICATE INSTANCE: "{Object.Name}:{Object.ClassName}"`)
					return
				end
			end

			if Object.ClassName == "Attachment" then
				local Part = Instance.new("Part", Location)
				Part.Name = `{Object.Name}`
				Part.Anchored = true
				Part.CFrame = Object.WorldCFrame
				Part.Transparency = 1
				Part.CanCollide = false
				Part.CanTouch = false
				Part.CanQuery = false
				Part.Size = Vector3.new(1, 1, 1)

				local Attachment = Object:Clone()
				Attachment.Parent = Part
				Attachment.CFrame = CFrame.new()
			elseif Object.ClassName == "Sound" then
				local Sound = Object:Clone()
				Sound.Parent = Location
				Sound:Stop()
			else
				Object:Clone().Parent = Location
			end

			print(`ADDED INSTANCE {Object.Name}:{Object.ClassName}`)
		end, function(err)
			warn(`ERROR SAVING INSTANCE "{(Object and Object.Name) or nil}": "{err}"`)
		end)
	end

	local function CreatePlayerFolder(Player)
		Disconnect("CharacterAdded")
		Disconnect("CharacterDescendantAdded")

		if Player == nil then 
			TargettingCharacter = nil 

			Shared:Notify("UNBOUND ALL CHARACTERS", `Character data grabber wont grab anymore.`)

			return 
		end

		TargettingPlayerFolder = PlayerSpecificStorage:FindFirstChild(Player.Name) or Instance.new("Folder", PlayerSpecificStorage)
		TargettingPlayerFolder.Name = Player.Name

		AnimationsFolder = TargettingPlayerFolder:FindFirstChild("Animations") or Instance.new("Folder", TargettingPlayerFolder)
		AnimationsFolder.Name = "Animations"

		CharacterFolder = TargettingPlayerFolder:FindFirstChild("Character") or Instance.new("Folder", TargettingPlayerFolder)
		CharacterFolder.Name = "Character"

		local function ConnectMainStuff(Character)
			Disconnect("CharacterDescendantAdded")

			if Character == nil then 
				TargettingCharacter = nil
				return
			end

			TargettingCharacter = Character

			Connect("CharacterDescendantAdded", Character.DescendantAdded:Connect(function(Object)
				if not CharacterSearchEnabled then return end

				StoreObject(Object, CharacterFolder)
			end))
		end

		Connect("CharacterAdded", Player.CharacterAdded:Connect(function(Character)
			ConnectMainStuff(Character)
		end))

		ConnectMainStuff(Player.Character)

		Shared:Notify("INITIALIZED CHARACTER", `Initialized the grabber data grabber to "{Player.Name}"`)
	end

	local function GetPlayersByText(Name)
		if typeof(Name) ~= "string" then return {} end

		local List = {}

		for _, Plr in Players:GetPlayers() do
			local SamePlayer = string.lower(Name) == string.lower(Plr.Name)

			if string.find(string.lower(Plr.Name), string.lower(Name)) or SamePlayer then
				local Score = SamePlayer and 100 or math.abs(string.len(Plr.Name) - string.len(Name))

				table.insert(List, {Plr, Score})
			end
		end

		table.sort(List, function(a, b)
			return (a[2] < b[2])
		end)

		local PlayerList = {}

		for I, Part in pairs(List) do
			table.insert(PlayerList, Part[1])
		end

		return PlayerList
	end

	CreatePlayerFolder(Player)

	local Commands = {
		["target"] = function(args)
			if #args < 1 then return end

			if args[1] == "none" then
				CreatePlayerFolder(nil)
			end

			local PlayerList = GetPlayersByText(args[1])

			if #PlayerList < 1 then return end

			CreatePlayerFolder(PlayerList[1])
		end;

		["yieldtime"] = function(args)
			if #args < 1 then return end
			if tonumber(args[1]) == nil then return end

			getgenv()["AddYield"] = tonumber(args[1])

			Shared:Notify("SET YIELD", `Yield time has been set to {getgenv()["AddYield"]}`)
		end,

		["storechar"] = function(args)
			Shared:Notify("SAVING...", `Storing target character this could take a while. DONT DO ANY OTHER ACTIONS.`)

			if TargettingCharacter then
				if TargettingCharacter:FindFirstChildOfClass("Humanoid") then
					for _, Track in TargettingCharacter:FindFirstChildOfClass("Humanoid"):GetPlayingAnimationTracks() do
						pcall(function()
							Track:Stop(0)
						end)
					end
				end

				TargettingCharacter.Archivable = true

				for _, Object in TargettingCharacter:GetDescendants() do
					Object.Archivable = true
				end

				task.wait(0.1)

				SaveObjectToFile(TargettingCharacter, `CHARSAVE_{TargettingCharacter.Name}_{getgenv()["CharacterSaves"]}`)

				getgenv()["CharacterSaves"] = getgenv()["CharacterSaves"] + 1
			end

			Shared:Notify("STORED", `Successfully stored target character!`)
		end;
		
		["storestartergui"] = function(args)
			Shared:Notify("SAVING...", `Storing StaterGui could take a while. DONT DO ANY OTHER ACTIONS.`)
			
			getgenv()["StarterUISaves"] = getgenv()["StarterUISaves"] + 1
			
			SaveObjectToFile(StarterGui, `STARTERGUISAVE_{getgenv()["StarterUISaves"]}`)
			
			Shared:Notify("STORED", `Successfully stored StarterGui.`)
		end;
		
		["storegui"] = function(args)
			Shared:Notify("SAVING...", `Storing PlayerGui could take a while. DONT DO ANY OTHER ACTIONS.`)

			getgenv()["UISaves"] = getgenv()["UISaves"] + 1
			
			SaveObjectToFile(Player.PlayerGui, `PLAYERGUISAVE_{getgenv()["UISaves"]}`)

			Shared:Notify("STORED", `Successfully stored PlayerGui.`)
		end;

		["storerep"] = function(args)
			Shared:Notify("STORING...", `Storing ReplicatedStorage this could take a while. DONT DO ANY OTHER ACTIONS.`)

			ReplicatedStorageStorage:ClearAllChildren()

			for _, Object in ReplicatedStorage:GetChildren() do
				StoreObject(Object, ReplicatedStorageStorage)
			end

			Shared:Notify("STORED", `Successfully stored ReplicatedStorage!`)
		end,

		["storemap"] = function(args)
			Shared:Notify("STORING...", `Storing the map this could take a while. DONT DO ANY OTHER ACTIONS.`)

			WorkspaceStorage:ClearAllChildren()

			for _, Object in workspace:GetChildren() do
				if Object.Name ~= "Living" and Object.Name ~= "Thrown" then
					StoreObject(Object, WorkspaceStorage)
				end
			end

			Shared:Notify("STORED", `Successfully stored the map!`)
		end;

		["dupetoggle"] = function(args)
			DupeRemovalEnabled = not DupeRemovalEnabled

			Shared:Notify("DUPE FILTERING TOGGLED", `State: {DupeRemovalEnabled}`)
		end;

		["mobtoggle"] = function(args)
			MobRemovalEnabled = not MobRemovalEnabled

			Shared:Notify("DUPE FILTERING TOGGLED", `State: {DupeRemovalEnabled}`)
		end;

		["chartoggle"] = function(args)
			CharacterSearchEnabled = not CharacterSearchEnabled

			Shared:Notify("CHARACTER SEARCH TOGGLED", `State: {CharacterSearchEnabled}`)
		end;

		["throwntoggle"] = function(args)
			ThrownSearchEnabled = not ThrownSearchEnabled

			Shared:Notify("THROWN SEARCH TOGGLED", `State: {ThrownSearchEnabled}`)
		end;
	}

	Connect("UISConnectionBegan", UIS.InputBegan:Connect(function(IO, Focusing)
		if Focusing then return end

		if IO.KeyCode == Enum.KeyCode.P then
			Shared:Notify("CLEARED CHARACTER ASSETS", "Clearing character specific assets for current target")

			if CharacterFolder ~= nil then
				for _, Object in CharacterFolder:GetChildren() do
					Object:Destroy()
				end
			end
		elseif IO.KeyCode == Enum.KeyCode.L then
			Shared:Notify("CLEARED THROWN", "Clearing stored object data")

			for _, Object in ThrownStorage:GetChildren() do
				Object:Destroy()
			end
		elseif IO.UserInputType == Enum.UserInputType.MouseButton3 then
			Shared:Notify("STORED ANIMATIONS", "Stored any new animations playing on target")

			SaveAnimations(TargettingCharacter)
		elseif IO.KeyCode == Enum.KeyCode.M then
			Shared:Notify("SAVING INSTANCE", "This could take a while depending on what your saving, refrain from doing any actions.", 5)

			xpcall(function()
				SaveObjectToFile(Folder, `SAVE_{getgenv()["SaveCount"]}`)


				getgenv()["SaveCount"] = getgenv()["SaveCount"] + 1
			end, function(err)
				warn(`FAILED TO SAVE: {err}`)

				Shared:Notify("FAILED TO SAVE INSTANCE", `{err}`, 10)
			end)
		end
	end))

	local function ChattedConnection(Message)
		xpcall(function()
			local Split = string.split(Message, " ")
			local CommandName = Split[1]
			local ArgsStartIndex = 2

			if CommandName then
				if CommandName == "/e" then
					CommandName = Split[2]
					ArgsStartIndex = 3
				end

				if CommandName and Commands[CommandName] then
					local Args = {}

					for i = ArgsStartIndex, #Split, 1 do
						if Split[i] then
							table.insert(Args, Split[i])
						end
					end

					xpcall(function()
						Commands[CommandName](Args)
						--Shared:Notify("RAN COMMAND", `Ran command "{CommandName}" with no errors`)
					end, function(err)
						Shared:Notify("ERROR IN RAN COMMAND", `Ran command "{CommandName}" erroed with: {err}`)
						warn(`ERROR IN RUNNING COMMAND "{CommandName}": {err}`)
					end)
				end
			end
		end, function(err)
			Shared:Notify("ERROR IN STRING CONCAT", `{err}`)
			warn(`ERROR IN STRING CONCAT: {err}`)
		end)
	end

	Connect("ThrownCheck", workspace:WaitForChild("Thrown").ChildAdded:Connect(function(Child)
		if not ThrownSearchEnabled then return end

		StoreObject(Child, ThrownStorage)
	end))
	
	local ChatCounter = 0
	
	Connect("CommandDetectionOldChat", Player.Chatted:Connect(function(Msg, Recipient)
		if Recipient then return end
		if ChatDB then return end
		
		ChatCounter += 1
		
		if ChatCounter % 2 ~= 0 then return end
		
		ChatDB = true
		
		delay(0.1, function()
			ChatDB = false
		end)
		
		ChattedConnection(Msg)
	end))

	Shared:Notify("INITIALIZED ALL", "The asset grabber was initialized successfully")
	warn("LOADED DEEPWOKEN ASSET GRABBER SUCCESSFULLY")
end, function(err)
	StarterGui:SetCore("SendNotification", {
		["Title"] = "FAILED TO INITIALIZE ALL";
		["Text"] = "An error occured during initialization, show me the warning in F9";
		["Duration"] = 5;
	})
	
	warn(`ERROR IN MAIN INITIALIZATION OF SCRIPT: {err}`)
end)
