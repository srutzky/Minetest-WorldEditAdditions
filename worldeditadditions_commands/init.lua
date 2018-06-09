--- WorldEditAdditions-ChatCommands
-- @module worldeditadditions_commands
-- @release 0.1
-- @copyright 2018 Starbeamrainbowlabs
-- @license Mozilla Public License, 2.0
-- @author Starbeamrainbowlabs

local safe_region, check_region, reset_pending = dofile(minetest.get_modpath("worldedit_commands") .. "/safe.lua")


-- ███████ ██       ██████   ██████  ██████  ███████ ██ ██      ██
-- ██      ██      ██    ██ ██    ██ ██   ██ ██      ██ ██      ██
-- █████   ██      ██    ██ ██    ██ ██   ██ █████   ██ ██      ██
-- ██      ██      ██    ██ ██    ██ ██   ██ ██      ██ ██      ██
-- ██      ███████  ██████   ██████  ██████  ██      ██ ███████ ███████

local function parse_params_floodfill(params_text)
	local found, _, replace_node, radius = params_text:find("([a-z:_\\-]+)%s+([0-9]+)")
	
	if found == nil then
		found, _, replace_node = params_text:find("([a-z:_\\-]+)")
		radius = 20
	end
	if found == nil then
		replace_node = "default:water_source"
	end
	radius = tonumber(radius)
	
	replace_node = worldedit.normalize_nodename(replace_node)
	
	return replace_node, radius
end

minetest.register_chatcommand("/floodfill", {
	params = "[<replace_node> [<radius>]]",
	description = "Floods all connected nodes of the same type starting at pos1 with <replace_node> (which defaults to `water_source`), in a sphere with a radius of <radius> (which defaults to 20).",
	privs = { worldedit = true },
	func = safe_region(function(name, params_text)
		local replace_node, radius = parse_params_floodfill(params_text)
		
		if not replace_node then
			worldedit.player_notify(name, "Error: Invalid node name.")
			return false
		end
		
		local start_time = os.clock()
		local nodes_replaced = worldedit.floodfill(worldedit.pos1[name], radius, replace_node)
		local time_taken = os.clock() - start_time
		
		worldedit.player_notify(name, nodes_replaced .. " nodes replaced in " .. time_taken .. "s")
		minetest.log("action", name .. " used //floodfill at " .. worldeditadditions.vector.tostring(worldedit.pos1[name]) .. ", replacing " .. nodes_replaced .. " nodes in " .. time_taken .. "s")
	end, function(name, params_text)
		local replace_node, radius = parse_params_floodfill(params_text)
		-- Volume of a hemisphere
		return math.ceil(((4 * math.pi * (tonumber(radius) ^ 3)) / 3) / 2)
	end)
})


--  ██████  ██    ██ ███████ ██████  ██       █████  ██    ██
-- ██    ██ ██    ██ ██      ██   ██ ██      ██   ██  ██  ██
-- ██    ██ ██    ██ █████   ██████  ██      ███████   ████
-- ██    ██  ██  ██  ██      ██   ██ ██      ██   ██    ██
--  ██████    ████   ███████ ██   ██ ███████ ██   ██    ██

minetest.register_chatcommand("/overlay", {
	params = "<replace_node>",
	description = "Places <replace_node> in the last contiguous air space encountered above the first non-air node. In other words, overlays all top-most nodes in the specified area with <replace_node>.",
	privs = { worldedit = true },
	func = safe_region(function(name, params_text)
		local target_node = worldedit.normalize_nodename(params_text)
		
		if not target_node then
			worldedit.player_notify(name, "Error: Invalid node name.")
			return false
		end
		
		local start_time = os.clock()
		local changes = worldedit.overlay(worldedit.pos1[name], worldedit.pos2[name], target_node)
		local time_taken = os.clock() - start_time
		
		worldedit.player_notify(name, changes.updated .. " nodes replaced and " .. changes.skipped_columns .. " columns skipped in " .. time_taken .. "s")
		minetest.log("action", name .. " used //overlay at " .. worldeditadditions.vector.tostring(worldedit.pos1[name]) .. ", replacing " .. changes.updated .. " nodes and skipping " .. changes.skipped_columns .. " columns in " .. time_taken .. "s")
	end, function(name, params_text)
		if not worldedit.normalize_nodename(params_text) then
			worldedit.player_notify(name, "Error: Invalid node name '" .. params_text .. "'.")
			return 0
		end
		
		local pos1 = worldedit.pos1[name]
		local pos2 = worldedit.pos2[name]
		pos1, pos2 = worldedit.sort_pos(pos1, pos2)
		
		local vol = vector.subtract(pos2, pos1)
		
		return vol.x*vol.z
	end)
})


-- ███████ ██      ██      ██ ██████  ███████  ██████  ██ ██████
-- ██      ██      ██      ██ ██   ██ ██      ██    ██ ██ ██   ██
-- █████   ██      ██      ██ ██████  ███████ ██    ██ ██ ██   ██
-- ██      ██      ██      ██ ██           ██ ██    ██ ██ ██   ██
-- ███████ ███████ ███████ ██ ██      ███████  ██████  ██ ██████

local function parse_params_ellipsoid(params_text)
	local found, _, radius_x, radius_y, radius_z, replace_node = params_text:find("([0-9]+)%s+([0-9]+)%s+([0-9]+)%s+([a-z:_\\-]+)")
	
	if found == nil then
		return nil, nil
	end
	
	local radius = {
		x = tonumber(radius_x),
		y = tonumber(radius_y),
		z = tonumber(radius_z)
	}
	
	minetest.log("action", "Radius x: " .. radius_x)
	minetest.log("action", "Radius y: " .. radius_y)
	minetest.log("action", "Radius z: " .. radius_z)
	
	minetest.log("action", "Raw target node: " .. replace_node)
	replace_node = worldedit.normalize_nodename(replace_node)
	minetest.log("action", "Normalised target node: " .. replace_node)
	
	return replace_node, radius
end

minetest.register_chatcommand("/ellipsoid", {
	params = "<rx> <ry> <rz> <replace_node>",
	description = "Creates a 3D ellipsoid with a radius of (rx, ry, rz) at pos1, filled with <replace_node>.",
	privs = { worldedit = true },
	func = safe_region(function(name, params_text)
		local target_node, radius = parse_params_ellipsoid(params_text)
		
		if not target_node then
			worldedit.player_notify(name, "Error: Invalid node name.")
			return false
		end
		if not radius then
			worldedit.player_notify(name, "Error: Invalid radius(es).")
			return false
		end
		
		local start_time = os.clock()
		local replaced = worldedit.ellipsoid(worldedit.pos1[name], radius, target_node)
		local time_taken = os.clock() - start_time
		
		worldedit.player_notify(name, replaced .. " nodes replaced in " .. time_taken .. "s")
		minetest.log("action", name .. " used //ellipsoid at " .. worldeditadditions.vector.tostring(worldedit.pos1[name]) .. ", replacing " .. replaced .. " nodes in " .. time_taken .. "s")
	end, function(name, params_text)
		local target_node, radius = parse_params_ellipsoid(params_text)
		if not target_node or not radius then
			worldedit.player_notify(name, "Error: Invalid input '" .. params_text .. "'. Try '/help /ellipsoid' to learn how to use this command.")
			return 0
		end
		
		return math.ceil(4/3 * math.pi * radius.x * radius.y * radius.z)
	end)
})
