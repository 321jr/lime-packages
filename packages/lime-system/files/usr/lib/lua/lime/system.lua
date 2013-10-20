#!/usr/bin/lua

module(..., package.seeall)

function clean()
    -- nothing to clean
end

function init()
    -- TODO
end

function configure()
    clean()

    print("Configuring system...")
    set_hostname()

    print("Let uhttpd listen on IPv4/IPv6")
    x:set("uhttpd", "main", "listen_http", "80")
    x:set("uhttpd", "main", "listen_https", "443")
    x:save("uhttpd")
end

function apply()
    -- apply hostname
    local hostname
    x:foreach("system", "system", function(s)
        hostname = x:get("system", s[".name"], "hostname")
    end)
    fs.writefile("/proc/sys/kernel/hostname", hostname)

    -- apply uhttpd settings
    os.execute("/etc/init.d/uhttpd reload")
end

function set_hostname()
    local r1, r2, r3 = node_id()
    local hostname = string.format("%02x%02x%02x", r1, r2, r3)

    x:foreach("system", "system", function(s)
        x:set("system", s[".name"], "hostname", hostname)
    end)
    x:save("system")
end
