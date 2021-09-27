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
name_list = {"account","auth_account","auth_password"},
type_list = {"string","string","string"},
option_map = {}
})

ALittle.RegisterObject = Lua.Class(nil, "ALittle.RegisterObject")

function ALittle.RegisterObject:Ctor(info, sip_register)
	___rawset(self, "_info", info)
	___rawset(self, "_sip_register", sip_register)
end

function ALittle.RegisterObject:IsChecking()
	return self._check_timer ~= nil
end

function ALittle.RegisterObject:IsRegistering()
	return self._register_timer ~= nil
end

function ALittle.RegisterObject:GetLastStatus()
	return self._last_status
end

function ALittle.RegisterObject:IsSame(info)
	if self._info.account ~= info.account then
		return false
	end
	if self._info.auth_account ~= info.auth_account then
		return false
	end
	if self._info.auth_password ~= info.auth_password then
		return false
	end
	return true
end

function ALittle.RegisterObject:GetInfo()
	return self._info
end

function ALittle.RegisterObject:StopCheckTimer()
	if self._check_timer == nil then
		return
	end
	A_LoopSystem:RemoveTimer(self._check_timer)
	self._check_timer = nil
end

function ALittle.RegisterObject:StopRegisterTimer()
	if self._register_timer == nil then
		return
	end
	A_LoopSystem:RemoveTimer(self._register_timer)
	self._register_timer = nil
end

function ALittle.RegisterObject:StartRegisterTimer(delay_ms)
	self:StopRegisterTimer()
	self._register_timer = A_LoopSystem:AddTimer(delay_ms, Lua.Bind(self.HandleRegisterTimer, self))
end

function ALittle.RegisterObject:HandleRegisterTimer()
	self._register_timer = nil
	self._last_status = "正在注册"
	self._sip_register:RegisterAccount(self._info.account)
	self:StartCheckTimer()
end

function ALittle.RegisterObject:StartCheckTimer()
	local delay_ms = 60 * 1000
	self:StopCheckTimer()
	self._check_timer = A_LoopSystem:AddTimer(delay_ms, Lua.Bind(self.HandleCheckTimer, self))
end

function ALittle.RegisterObject:HandleCheckTimer()
	self._check_timer = nil
	self._last_status = "注册超时"
	self._sip_register:RegisterAccount(self._info.account)
	self:StartCheckTimer()
end

function ALittle.RegisterObject:HandleSucceed()
	self._last_status = "注册成功"
	self:StopCheckTimer()
	self:StartRegisterTimer(ALittle.Math_Floor(self._sip_register:GetExpires() / 2) * 1000)
end

function ALittle.RegisterObject:HandleFailed(error)
	self._last_status = error
	if self._last_status == nil then
		self._last_status = "注册失败"
	end
	self:StopCheckTimer()
	self:StartRegisterTimer(60 * 1000)
end

ALittle.SipRegister = Lua.Class(nil, "ALittle.SipRegister")

function ALittle.SipRegister:Ctor()
	___rawset(self, "_expires", 3600)
	___rawset(self, "_max_per_second", 0)
	___rawset(self, "_register_map", {})
end

function ALittle.SipRegister:Setup(sip_system, expires, max_per_second)
	self._sip_system = sip_system
	self._expires = expires
	self._max_per_second = max_per_second
end

function ALittle.SipRegister:Shutdown()
	for key, info in ___pairs(self._register_map) do
		info:StopRegisterTimer()
		info:StopCheckTimer()
	end
	self._register_map = {}
end

function ALittle.SipRegister:RegisterAccount(account)
	self._sip_system:RegisterAccount(account)
end

function ALittle.SipRegister:GetSipRegisterStatistics()
	local account_count = 0
	local check_count = 0
	local register_count = 0
	local error_map = {}
	for account, info in ___pairs(self._register_map) do
		account_count = account_count + (1)
		if info:IsChecking() then
			check_count = check_count + (1)
		end
		if info:IsRegistering() then
			register_count = register_count + (1)
		end
		local last_status = info:GetLastStatus()
		if last_status ~= nil then
			local list = error_map[last_status]
			if list == nil then
				list = {}
				error_map[last_status] = list
			end
			ALittle.List_Push(list, account)
		end
	end
	local log = "账号总数:" .. account_count .. " 正在注册:" .. check_count .. " 等待下次注册:" .. register_count
	for error, list in ___pairs(error_map) do
		local count = ALittle.List_Len(list)
		log = log .. "\n" .. count .. ":" .. error
		if error ~= "注册成功" then
			log = log .. "\n" .. ALittle.String_Join(list, ",")
		end
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
	return info:GetInfo()
end

function ALittle.SipRegister:HandleRegisterSucceed(account)
	local info = self._register_map[account]
	if info == nil then
		return
	end
	info:HandleSucceed()
end

function ALittle.SipRegister:HandleRegisterFailed(account, error)
	local info = self._register_map[account]
	if info == nil then
		return
	end
	info:HandleFailed(error)
end

function ALittle.SipRegister:ReloadRegister(account_map_info)
	local remove_map = {}
	for account, info in ___pairs(self._register_map) do
		remove_map[account] = info
	end
	for account, detail in ___pairs(account_map_info) do
		local info = self._register_map[account]
		if info ~= nil and not info:IsSame(detail) then
			info:StopCheckTimer()
			info:StopRegisterTimer()
			info = nil
			self._register_map[account] = nil
		end
		if info == nil then
			info = ALittle.RegisterObject(detail, self)
			self._register_map[account] = info
		end
		remove_map[account] = nil
	end
	for account, info in ___pairs(remove_map) do
		info:StopCheckTimer()
		info:StopRegisterTimer()
		self._register_map[account] = nil
	end
	local delay_ms = 1000
	local cur_count = 0
	for account, info in ___pairs(self._register_map) do
		if not info:IsChecking() then
			info:StartRegisterTimer(delay_ms)
			cur_count = cur_count + (1)
			if self._max_per_second > 0 and cur_count >= self._max_per_second then
				cur_count = 0
				delay_ms = 1000
			end
		end
	end
end

end