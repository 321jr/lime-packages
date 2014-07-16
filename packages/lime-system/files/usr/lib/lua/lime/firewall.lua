#!/usr/bin/lua

firewall = {}

function firewall.clean()
	print("Clearing firewall config...")
	local uci = libuci:cursor()
	uci:delete("firewall", "bmxtun")
	uci:save("firewall")
end

function firewall.configure()
	local uci = libuci:cursor()

	uci:foreach("firewall", "defaults",
		function(section)
			uci:set("firewall", section[".name"], "input", "ACCEPT")
			uci:set("firewall", section[".name"], "output", "ACCEPT")
			uci:set("firewall", section[".name"], "forward", "ACCEPT")
		end
	)

	uci:foreach("firewall", "zone",
		function(section)
			if uci:get("firewall", section[".name"], "name") == "wan"
			or uci:get("firewall", section[".name"], "name") == "lan" then
				uci:set("firewall", section[".name"], "input", "ACCEPT")
				uci:set("firewall", section[".name"], "output", "ACCEPT")
				uci:set("firewall", section[".name"], "forward", "ACCEPT")
			end
		end
	)

	uci:set("firewall", "bmxtun", "zone")
	uci:set("firewall", "bmxtun", "name", "bmxtun")
	uci:set("firewall", "bmxtun", "input", "ACCEPT")
	uci:set("firewall", "bmxtun", "output", "ACCEPT")
	uci:set("firewall", "bmxtun", "forward", "ACCEPT")
	uci:set("firewall", "bmxtun", "mtu_fix", "1")
	uci:set("firewall", "bmxtun", "device", "bmx+")
	uci:set("firewall", "bmxtun", "family", "ipv4")

	uci:save("firewall")
end

return firewall
