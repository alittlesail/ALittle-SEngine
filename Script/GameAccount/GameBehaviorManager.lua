-- ALittle Generate Lua And Do Not Edit This Line!
do
if _G.ALittle == nil then _G.ALittle = {} end
local ALittle = ALittle
local Lua = Lua
local ___rawset = rawset
local ___pairs = pairs
local ___ipairs = ipairs


ALittle.GameBehaviorManager = Lua.Class(nil, "ALittle.GameBehaviorManager")

function ALittle.GameBehaviorManager:Ctor()
	___rawset(self, "_file_map", {})
end

function ALittle.GameBehaviorManager:Setup(base_path)
	ALittle.File_MakeDeepDir(base_path)
	self._base_path = ALittle.File_PathEndWithSplit(base_path)
	ALittle.File_MakeDeepDir(self._base_path)
end

function ALittle.GameBehaviorManager:Log(T, tag, value)
	local file = self._file_map[tag]
	if file == nil then
		file = io.open(self._base_path .. tag .. ".txt", "a")
		if file == nil then
			ALittle.Error("behavior file open failed! path:" .. self._base_path .. tag, ALittle.String_JsonEncode(value))
			return
		end
		self._file_map[tag] = file
	end
	file:write(ALittle.String_JsonEncode(value))
	file:write("\n")
end

function ALittle.GameBehaviorManager:Shutdown()
	for key, file in ___pairs(self._file_map) do
		file:close()
	end
	self._file_map = {}
end

_G.A_GameBehaviorManager = ALittle.GameBehaviorManager()
end