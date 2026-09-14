local addonName, ns = ...

local Grid2RightClick = {};
local Grid2Ace = LibStub("AceAddon-3.0"):GetAddon("Grid2")


local MAX_ACCOUNT_MACROS =  MAX_ACCOUNT_MACROS or Constants.MacroConsts.MAX_ACCOUNT_MACROS 
local MAX_CHARACTER_MACROS = MAX_CHARACTER_MACROS or Constants.MacroConsts.MAX_CHARACTER_MACROS


local addonl = CreateFrame("Frame")
addonl:RegisterEvent("PLAYER_LOGIN")
addonl:SetScript("OnEvent", function(event, name)
	if type(Grid2Frame.db.profile.macroRightClickMacro) == "number" then return end
	Grid2Frame.db.profile.macroRightClickMacroName = Grid2Frame.db.profile.macroRightClickMacro
	Grid2Frame.db.profile.macroRightClickMacro = ns.getMacroidbyName(Grid2Frame.db.profile.macroRightClickMacro)
end)


Grid2Ace:RegisterEvent("ADDON_LOADED", function(event, addonName)
	if (addonName == "Grid2Options") then
		Grid2Options:AddThemeOptions("Grid2RightClick", "Grid2RightClick", ns.Options)
	end
end)

Grid2Ace:RegisterMessage("Grid_UnitUpdated", function()
	Grid2RightClick:setAction()
end)

ns.oldidx = nil
ns.newidx = nil

function ns.getMacroidbyName(name)
	local max = MAX_CHARACTER_MACROS + MAX_ACCOUNT_MACROS
	for i = 1, max, 1 do
		if name == GetMacroInfo(i) then return i end
	end
	return 1
end

local width = 0.867

ns.Options  = {
	group1 = {
		type = "group",
		inline = false,
		order = 1,
		name = "Right click Macro",
		desc = "Right click Macro",
		args = {
			enableToggle = {
				type = "toggle",
				name = "Enable",
				desc = "Use Macro on right clicking on a frame.",
				order = 10,
				width = width,
				get = function() return Grid2Options.editedTheme.frame.macroRightClick end,
				set = function(_, v)
					Grid2Options.editedTheme.frame.macroRightClick = not Grid2Options.editedTheme.frame.macroRightClick
					Grid2Layout:RefreshLayout()
				end,
			},
			selectMacro = {
				type = "select",
				name = "Select Macro",
				desc = "Select used Macro",
				order = 30,
				width = width,
				get = function()
					return ns.getIdx(Grid2Options.editedTheme.frame.macroRightClickMacro, 0)
				end,
				set = function(_, v)
					local name                                              = GetMacroInfo(v)

					Grid2Options.editedTheme.frame.macroRightClickMacroName = name or nil
					Grid2Options.editedTheme.frame.macroRightClickMacro     = v or nil
					Grid2Layout:RefreshLayout()
				end,
				values = function() return ns.getMacroData(MAX_ACCOUNT_MACROS, 0) end,
			},
			selectCharMacro = {
				type = "select",
				name = "Select Character Macro",
				desc = "Select used Macro",
				order = 40,
				width = width,
				get = function()
					return ns.getIdx(Grid2Options.editedTheme.frame.macroRightClickMacro, MAX_ACCOUNT_MACROS)
				end,
				set = function(_, v)
					v = MAX_ACCOUNT_MACROS + v
					local name = GetMacroInfo(v)

					Grid2Options.editedTheme.frame.macroRightClickMacroName = name or nil
					Grid2Options.editedTheme.frame.macroRightClickMacro = v or nil
					Grid2Layout:RefreshLayout()
				end,
				values = function() return ns.getMacroData(MAX_CHARACTER_MACROS, MAX_ACCOUNT_MACROS) end,
			}
		}
	}
}



function ns.checkMacro(idx, name)
	local cname = GetMacroInfo(idx)
	if name == cname then
		return true
	end
	return false
end

function ns.getIdx(idx, base)
	idx = idx or ns.oldidx or 1
	return idx - base
end

function ns.getMacroData(max, base)
	local values = {}
	for i = 1, max, 1 do
		local name = GetMacroInfo(base + i)
		if name ~= nil then
			table.insert(values, name)
		end
	end
	return values
end

local addon = CreateFrame("Frame")
addon:RegisterEvent("UPDATE_MACROS")
addon:SetScript("OnEvent", function(event, name)
	-- check if char macros are loaded
	local cname = GetMacroInfo(MAX_ACCOUNT_MACROS + 1)
	if not cname then return end


	if not Grid2Frame.db.profile.macroRightClickMacro then return end
	if not Grid2Frame.db.profile.macroRightClickMacroName then return end

	ns.oldidx = Grid2Frame.db.profile.macroRightClickMacro

	-- get aLL macros
	local check = ns.checkMacro(Grid2Frame.db.profile.macroRightClickMacro,
		Grid2Frame.db.profile.macroRightClickMacroName)
	if check then return end


	local function searchMacro()
		for i = 1, MAX_ACCOUNT_MACROS + MAX_CHARACTER_MACROS, 1 do
			local name = GetMacroInfo(i)
			if name ~= nil then
				if name == Grid2Frame.db.profile.macroRightClickMacroName then
					return i
				end
			end
		end
		return nil
	end

	ns.newidx = searchMacro() or ns.oldidx
	Grid2Frame.db.profile.macroRightClickMacro = ns.newidx
	Grid2RightClick:setAction()
end)




function Grid2RightClick:setAction()
	local rc = Grid2Frame.db.profile.macroRightClickMacro and Grid2Frame.db.profile.macroRightClick;
	local v = Grid2Frame.db.profile.menuDisabled;

	Grid2Frame:WithAllFrames(function(f)
		f:SetAttribute("*type2", rc and "macro" or ((not v) and "togglemenu" or nil));
		f:SetAttribute("macro", Grid2Frame.db.profile.macroRightClickMacro)
	end)
end
