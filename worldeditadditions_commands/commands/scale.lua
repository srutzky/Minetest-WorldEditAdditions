-- ███████  ██████  █████  ██      ███████
-- ██      ██      ██   ██ ██      ██
-- ███████ ██      ███████ ██      █████
--      ██ ██      ██   ██ ██      ██
-- ███████  ██████ ██   ██ ███████ ███████
worldedit.register_command("scale", {
	params = "<axis> <scale_factor> | <factor_x> [<factor_y> <factor_z> [<anchor_x> <anchor_y> <anchor_z>]]",
	description = "Combined scale up / down. Takes either an axis name + a scale factor (e.g. y 3 or -z 2; negative values swap the anchor point for the scale operation), or 3 scale factor values for x, y, and z respectively. In the latter mode, a set of anchors can also be specified, which indicate which size the scale operation should be anchored to.",
	privs = { worldedit = true },
	require_pos = 2,
	parse = function(params_text)
		if not params_text then params_text = "" end
		
		local parts = worldeditadditions.split(params_text, "%s+", false)
		
		local scale = vector.new(1, 1, 1)
		local direction = vector.new(1, 1, 1)
		
		if #parts == 2 then
			if parts[1] ~= "x" or parts[1] ~= "y" or parts[1] ~= "z"
			 	or parts[1] ~= "-x" or parts[1] ~= "-y" or parts[1] ~= "-z" then
				return false, "Error: Got 2 arguments, but the first doesn't look like the name of an axis."
			end
			local axis = parts[1]
			local factor = tonumber(parts[2])
			if not factor then return false, "Error: Invalid scale factor." end
			
			if axis:sub(1, 1) == "-" then
				axis = axis:sub(2, 2)
				direction[axis] = -1
			end
			
			scale[axis] = factor
		elseif #parts >= 3 then
			local val = tonumber(parts[1])
			if not val then return false, "Error: x axis scale factor wasn't a number." end
			scale.x = val
			val = tonumber(parts[2])
			if not val then return false, "Error: y axis scale factor wasn't a number." end
			scale.y = val
			val = tonumber(parts[3])
			if not val then return false, "Error: z axis scale factor wasn't a number." end
			scale.z = val
		else
			local val = tonumber(parts[1])
			if not val then
				return false, "Error: scale factor wasn't a number."
			end
			scale.x = val
			scale.y = val
			scale.z = val
		end
		
		if #parts == 6 then
			local val = tonumber(parts[4])
			if not val then return false, "Error: x axis anchor wasn't a number." end
			direction.x = val
			val = tonumber(parts[5])
			if not val then return false, "Error: y axis anchor wasn't a number." end
			direction.y = val
			val = tonumber(parts[6])
			if not val then return false, "Error: z axis anchor wasn't a number." end
			direction.z = val
		end
		
		if scale.x == 0 then return false, "Error: x scale factor was 0" end
		if scale.y == 0 then return false, "Error: y scale factor was 0" end
		if scale.z == 0 then return false, "Error: z scale factor was 0" end
		
		if direction.x == 0 then return false, "Error: x axis anchor was 0" end
		if direction.y == 0 then return false, "Error: y axis anchor was 0" end
		if direction.z == 0 then return false, "Error: z axis anchor was 0" end
		
		return true, scale, direction
	end,
	nodes_needed = function(name, scale, direction)
		local volume = worldedit.volume(worldedit.pos1[name], worldedit.pos2[name])
		local factor = math.ceil(math.abs(scale.x))
			* math.ceil(math.abs(scale.y))
			* math.ceil(math.abs(scale.z))
		return volume * factor
	end,
	func = function(name, scale, direction)
		local start_time = worldeditadditions.get_ms_time()
		
		local success, stats = worldeditadditions.scale(pos1, pos2, scale, direction)
		if not success then return success, stats end
		
		-- TODO read stats here
		
		
		local time_taken = worldeditadditions.get_ms_time() - start_time
		
		
		minetest.log("action", name.." used //scale at "..worldeditadditions.vector.tostring(worldedit.pos1[name]).." - "..worldeditadditions.vector.tostring(worldedit.pos2[name])..", updating "..stats.updated.." nodes in "..time_taken.."s")
		return true, stats.updated.." nodes updated in " .. worldeditadditions.human_time(time_taken)
	end
})
