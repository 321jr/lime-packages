#!/usr/bin/lua

local libuci = require("uci")
local fs = require("nixio.fs")
local lan = require("lime.proto.lan")

batadv = {}

function batadv.setup_interface(ifname, args)
	if ifname:match("^wlan%d_ap") then return end
	if not args[2] then return end

	local owrtInterfaceName, _, _ = network.createVlanIface(ifname, args[2], "_batadv")
	local mtu = 1532
	if ifname:match("^eth") then mtu = 1496 end

	local uci = libuci:cursor()

	uci:set("network", owrtInterfaceName, "proto", "batadv")
	uci:set("network", owrtInterfaceName, "mesh", "bat0")
	uci:set("network", owrtInterfaceName, "mtu", mtu)

	-- BEGIN
	-- Workaround to http://www.libre-mesh.org/issues/32
	-- We create a new macaddress for ethernet vlan interface
	-- We use 000049 Unicast MAC prefix reserved by Apricot Ltd
	-- We change the 7nt bit to 1 to give it locally administered meaning
	-- Then use it as the new mac address prefix "02:00:49"
	if ifname:match("^eth") then
		local vlanMacAddr = network.get_mac(ifname)
		vlanMacAddr[1] = "02"
		vlanMacAddr[2] = "00"
		vlanMacAddr[3] = "49"
		uci:set("network", owrtInterfaceName, "macaddr", table.concat(vlanMacAddr, ":"))
	end
	--- END

	uci:save("network")
end

function batadv.clean()
	print("Clearing batman-adv config...")
	local uci = libuci:cursor()
	uci:delete("batman-adv", "bat0")
	uci:save("batman-adv")
	if not fs.lstat("/etc/config/batman-adv") then fs.writefile("/etc/config/batman-adv", "") end
end


function batadv.configure(args)
	batadv.clean()

	local uci = libuci:cursor()
	uci:set("batman-adv", "bat0", "mesh")
	uci:set("batman-adv", "bat0", "bridge_loop_avoidance", "1")

	-- if anygw enabled disable DAT that doesn't play well with it
	for _,proto in pairs(config.get("network", "protocols")) do
		if proto == "anygw" then uci:set("batman-adv", "bat0", "distributed_arp_table", "0") end
	end

	lan.setup_interface("bat0", nil)

	uci:save("batman-adv")
end


return batadv
