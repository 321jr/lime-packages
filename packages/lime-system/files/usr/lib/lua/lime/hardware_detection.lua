#!/usr/bin/lua

local fs = require("nixio.fs")
local utils = require("lime.utils")


hardware_detection = {}

function hardware_detection.clean()
	for hwd_module_path in fs.glob("/usr/lib/lua/lime/hwd/*.lua") do
		local module_name = "lime.hwd." .. fs.basename(hwd_module_path):sub(1,-5)
		if utils.isModuleAvailable(module_name) then
			require(module_name).clean()
		end
	end
end

function hardware_detection.configure()
	for hwd_module_path in fs.glob("/usr/lib/lua/lime/hwd/*.lua") do
		local module_name = "lime.hwd." .. fs.basename(hwd_module_path):sub(1,-5)
		if utils.isModuleAvailable(module_name) then
			require(module_name).detect_hardware()
		end
	end
end


return hardware_detection
