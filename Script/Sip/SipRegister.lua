-- ALittle Generate Lua And Do Not Edit This Line!
do
if _G.ALittle == nil then _G.ALittle = {} end
local ALittle = ALittle
local Lua = Lua
local ___rawset = rawset
local ___pairs = pairs
local ___ipairs = ipairs

ALittle.RegStruct(-1329691084, "ALittle.RegisterInfo", {
name = "ALittle.RegisterInfo", ns_name = "ALittle", rl_name = "RegisterInfo", hash_code = -1329691084,
name_list = {"account","auth_account","auth_password","last_resgiter_time","check_register_time","status"},
type_list = {"string","string","string","int","int","string"},
option_map = {}
})

ALittle.SipRegister = Lua.Class(nil, "ALittle.SipRegister")

function ALittle.SipRegister:Ctor()
	___rawset(self, "_expires", 3600)
	___rawset(self, "_max_per_second", 0)
	___rawset(self, "_failed_delay", 60)
	___rawset(self, "_register_map", {})
	___rawset(self, "_register_patch", {})
	___rawset(self, "_register_patch_count", 0)
	___rawset(self, "_check_map", {})
end

function ALittle.SipRegister:Setup(sip_system, expires, max_per_second)
	self._sip_system = sip_system
	self._expires = expires
	self._max_per_second = max_per_second
	self._register_timer = A_LoopSystem:AddTimer(1000, Lua.Bind(self.HandleRegisterTimer, self), 0, 1000)
	self._check_timer = A_LoopSystem:AddTimer(1000, Lua.Bind(self.HandleCheckTimer, self), 0, 1000)
end

function ALittle.SipRegister:Shutdown()
	if self._check_timer ~= nil then
		A_LoopSystem:RemoveTimer(self._check_timer)
		self._check_timer = nil
	end
	if self._register_timer ~= nil then
		A_LoopSystem:RemoveTimer(self._register_timer)
		self._register_timer = nil
	end
end

function ALittle.SipRegister:GetSipRegisterStatistics()
	local account_count = 0
	for account, info in ___pairs(self._register_map) do
		account_count = account_count + (1)
	end
	local cur_time = ALittle.Time_GetCurTime()
	local register_count = 0
	local timeout_count = 0
	for account, info in ___pairs(self._check_map) do
		register_count = register_count + (1)
		if info.check_register_time < cur_time then
			timeout_count = timeout_count + (1)
		end
	end
	local result_map = {}
	for account, info in ___pairs(self._register_map) do
		local status = info.status
		if status == nil then
			status = ""
		end
		local count = result_map[status]
		if count == nil then
			count = 1
		else
			count = count + (1)
		end
		result_map[status] = count
	end
	local log = "账号总数:" .. account_count .. " 等待下次注册:" .. self._register_patch_count .. " 正在注册:" .. register_count .. " 注册超时:" .. timeout_count
	for result, count in ___pairs(result_map) do
		log = log .. "\n" .. count .. ":" .. result
	end
	return log
end

function ALittle.SipRegister:GetExpires()
	return self._expires
end

function ALittle.SipRegister:GetRegisterInfo(account)
	local info = self._register_map[account]
	if info == nil then
		return nil
	end
	return info
end

function ALittle.SipRegister:HandleRegisterSucceed(account)
	self._check_map[account] = nil
	local info = self._register_map[account]
	if info ~= nil then
		info.status = "注册成功"
	end
end

function ALittle.SipRegister:HandleRegisterFailed(account, error)
	local info = self._register_map[account]
	if info ~= nil then
		info.status = error
	end
end

function ALittle.SipRegister:ReloadRegister(account_map_info)
	local remove_map = {}
	for account, value in ___pairs(self._register_map) do
		remove_map[account] = value
	end
	for account, detail in ___pairs(account_map_info) do
		local info = self._register_map[account]
		if info == nil then
			info = {}
			info.last_resgiter_time = 0
			info.check_register_time = 0
			info.account = account
			info.auth_account = detail.auth_account
			info.auth_password = detail.auth_password
			self._register_map[account] = info
		else
			if info.account ~= account or info.auth_account ~= detail.auth_account or info.auth_password ~= detail.auth_password then
				info.account = account
				info.auth_account = detail.auth_account
				info.auth_password = detail.auth_password
				info.last_resgiter_time = 0
				info.check_register_time = 0
				info.status = "等待注册"
			end
		end
		remove_map[account] = nil
	end
	for account, value in ___pairs(remove_map) do
		self._register_map[account] = nil
	end
	self._check_map = {}
	self:BuildRegisterPatch()
end

function ALittle.SipRegister:BuildRegisterPatch()
	self._register_patch = {}
	self._register_patch_count = 0
	for key, value in ___pairs(self._register_map) do
		self._register_patch_count = self._register_patch_count + (1)
		self._register_patch[self._register_patch_count] = value
	end
	ALittle.List_Sort(self._register_patch, ALittle.SipRegister.BuildRegisterPatchSort)
end

function ALittle.SipRegister.BuildRegisterPatchSort(a, b)
	return a.last_resgiter_time > b.last_resgiter_time
end

function ALittle.SipRegister:HandleRegisterTimer()
	local cur_time = ALittle.Time_GetCurTime()
	if self._register_patch_count <= 0 then
		self:BuildRegisterPatch()
	end
	local handle_count = 0
	while self._register_patch_count > 0 do
		local info = self._register_patch[self._register_patch_count]
		if info.last_resgiter_time ~= 0 and info.last_resgiter_time + self._expires / 2 > cur_time then
			break
		end
		info.last_resgiter_time = cur_time
		info.check_register_time = info.last_resgiter_time + self._failed_delay
		info.status = "正在注册"
		self._sip_system:RegisterAccount(info.account)
		handle_count = handle_count + (1)
		self._register_patch[self._register_patch_count] = nil
		self._register_patch_count = self._register_patch_count - (1)
		self._check_map[info.account] = info
		if self._max_per_second > 0 and handle_count >= self._max_per_second then
			break
		end
	end
end

function ALittle.SipRegister:HandleCheckTimer()
	local cur_time = ALittle.Time_GetCurTime()
	for account, info in ___pairs(self._check_map) do
		if info.check_register_time < cur_time then
			info.last_resgiter_time = cur_time
			info.check_register_time = info.last_resgiter_time + self._failed_delay
			self._sip_system:RegisterAccount(info.account)
		end
	end
end

end