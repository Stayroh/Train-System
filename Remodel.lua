local Args = table.pack(select(1, ...))

local AssetPlace = remodel.readPlaceAsset("14743863242")

local DefaultSettings = true
local InduvidualSettings = {
	["lighting"] = false,
	["terrain"] = false,
	["map"] = false,
	["materials"] = false,
	["trains"] = false,
}

for _, Argument in ipairs(Args) do
	Argument = string.lower(Argument)
	if InduvidualSettings[Argument] ~= nil then
		DefaultSettings = false
		InduvidualSettings[Argument] = true
	end
end

local function FillDir(Instance, Directory)
	local DoubleFolders = {}
	local DoubleInstances = {}
	for i, v in pairs(Instance:GetChildren()) do
		if v.ClassName == "Folder" then
			if DoubleFolders[v.Name] then
				local Count = DoubleFolders[v.Name] + 1
				DoubleFolders[v.Name] = Count
				local NewDir = string.format("%s/%s(%s)", Directory, v.Name, Count)

				remodel.createDirAll(NewDir)

				FillDir(v, NewDir)
			else
				DoubleFolders[v.Name] = 1
				local NewDir = string.format("%s/%s", Directory, v.Name)
				remodel.createDirAll(NewDir)
				FillDir(v, NewDir)
			end
		else
			if DoubleInstances[v.Name] then
				local Count = DoubleInstances[v.Name] + 1
				DoubleInstances[v.Name] = Count
				local Path = string.format("%s/%s(%s)", Directory, v.Name, tostring(Count))
				remodel.writeModelFile(Path .. ".rbxm", v)
			else
				DoubleInstances[v.Name] = 1
				remodel.writeModelFile(string.format("%s/%s.rbxm", Directory, v.Name), v)
			end
		end
	end
end

local function AntiOverride(Name, DoubleCount)
	if DoubleCount[Name] then
		local Count = DoubleCount[Name] + 1
		DoubleCount[Name] = Count
		return string.format("%s(%s)", Name, tostring(Count))
	else
		DoubleCount[Name] = 1
		return Name
	end
end

local function CheckSetting(Key)
	if DefaultSettings or InduvidualSettings[Key] then
		return true
	else
		return false
	end
end

local function UnnistFolder(Folder)
	local Children = {}
	for _, v in pairs(Folder:GetChildren()) do
		if v.ClassName == "Folder" then
			local SubFolderChildren = UnnistFolder(v)
			for _, SubElement in pairs(SubFolderChildren) do
				Children[#Children + 1] = SubElement
			end
		else
			Children[#Children + 1] = v
		end
	end
	return Children
end

--Lighting
if CheckSetting("lighting") then
	local Lighting = AssetPlace:GetService("Lighting")
	remodel.writeModelFile("assets/Lighting.rbxm", Lighting)
end

--Terrain
if CheckSetting("terrain") then
	local Terrain = AssetPlace:GetService("Workspace").Terrain
	remodel.writeModelFile("assets/Terrain.rbxm", Terrain)
end

--Map
if CheckSetting("map") then
	local Dir = "assets/Map"
	remodel.removeDir(Dir)
	remodel.createDirAll(Dir)
	local Map = AssetPlace:GetService("Workspace").Map
	FillDir(Map, Dir)
end

--MaterialService
if CheckSetting("materials") then
	local MaterialService = AssetPlace:GetService("MaterialService")
	remodel.writeModelFile("assets/MaterialService.rbxm", MaterialService)
end

--Trains
if CheckSetting("trains") then
	local Dir = "assets/Trains"
	remodel.removeDir(Dir)
	remodel.createDirAll(Dir)
	local Trains = AssetPlace:GetService("Workspace").Trains
	FillDir(Trains, Dir)
end
