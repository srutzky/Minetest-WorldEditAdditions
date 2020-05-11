local we_c = worldeditadditions_commands

-- ██████   ██████  ███    ██ ███████ ███    ███ ███████  █████  ██
-- ██   ██ ██    ██ ████   ██ ██      ████  ████ ██      ██   ██ ██
-- ██████  ██    ██ ██ ██  ██ █████   ██ ████ ██ █████   ███████ ██
-- ██   ██ ██    ██ ██  ██ ██ ██      ██  ██  ██ ██      ██   ██ ██
-- ██████   ██████  ██   ████ ███████ ██      ██ ███████ ██   ██ ███████
worldedit.register_command("bonemeal", {
	params = "[<strength> [<chance>]]",
	description = "Bonemeals everything that's bonemeal-able that has an air node directly above it. Optionally takes a strength value to use (default: 1, maximum: 4), and a chance to actually bonemeal an eligible node (positive integer; nodes have a 1-in-<chance> chance to be bonemealed; higher values mean a lower chance; default: 1 - 100% chance).",
	privs = { worldedit = true },
	require_pos = 2,
	parse = function(params_text)
		if not params_text or params_text == "" then
			params_text = "1"
		end
		
		local parts = we_c.split(params_text, "%s+", false)
		
		local strength = 1
		local chance = 1
		
		if #parts >= 1 then
			strength = tonumber(parts[1])
			if not strength then
				return false, "Invalid strength value (value must be an integer)"
			end
		end
		if #parts >= 2 then
			chance = tonumber(parts[2])
			if not chance then
				return false, "Invalid chance value (must be a positive integer)"
			end
		end
		
		if strength < 1 or strength > 4 then
			return false, "Error: strength value out of bounds (value must be an integer between 1 and 4 inclusive)"
		end
		
		-- We unconditionally math.floor here because when we tried to test for it directly it was unreliable
		return true, math.floor(strength), math.floor(chance)
	end,
	nodes_needed = function(name) -- strength, chance
		-- Since every node has to have an air block, in the best-case scenario
		-- edit only half the nodes in the selected area
		return worldedit.volume(worldedit.pos1[name], worldedit.pos2[name]) / 2
	end,
	func = function(name, strength, chance)
		local start_time = os.clock()
		local success, nodes_bonemealed, candidates = worldeditadditions.bonemeal(worldedit.pos1[name], worldedit.pos2[name], strength, chance)
		if not success then
			-- nodes_bonemealed is an error message here because success == false
			return success, nodes_bonemealed
		end
		local percentage = we_c.round((nodes_bonemealed / candidates)*100, 2)
		local time_taken = os.clock() - start_time
		
		minetest.log("action", name .. " used //bonemeal at "..worldeditadditions.vector.tostring(worldedit.pos1[name]).." - "..worldeditadditions.vector.tostring(worldedit.pos2[name])..", bonemealing " .. nodes_bonemealed.." nodes (out of "..candidates.." nodes) at strength "..strength.." in "..time_taken.."s")
		return true, nodes_bonemealed.." out of "..candidates.." (~"..percentage.."%) candidates bonemealed in "..time_taken.."s"
	end
})