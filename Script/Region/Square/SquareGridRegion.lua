-- ALittle Generate Lua And Do Not Edit This Line!
do
if _G.ALittle == nil then _G.ALittle = {} end
local ALittle = ALittle
local Lua = Lua
local ___rawset = rawset
local ___pairs = pairs
local ___ipairs = ipairs


ALittle.SquareGridRegion = Lua.Class(nil, "ALittle.SquareGridRegion")

function ALittle.SquareGridRegion:Ctor(side)
	___rawset(self, "_side", 1)
	___rawset(self, "_side", side)
	if self._side <= 0 then
		___rawset(self, "_side", 1)
	end
end

end