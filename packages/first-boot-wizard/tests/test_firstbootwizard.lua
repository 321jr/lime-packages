local libuci = require 'uci'
local config = require 'lime.config'
local fbw = require 'firstbootwizard'
local utils = require 'lime.utils'
local test_utils = require 'tests.utils'
local fs = require("nixio.fs")
local fbw_utils = require('firstbootwizard.utils')

local uci = nil

local community_file = [[
config lime 'system'

config lime 'network'

config lime 'wifi'
	option ap_ssid 'foo'
	option apname_ssid 'foo/%H'
	option adhoc_ssid 'LiMe.%H'
	option ieee80211s_mesh_id 'LiMe'
]]

describe('FirstBootWizard tests #fbw', function()

    it('test start/end_scan() and check_scan_file()', function()
        assert.is_nil(fbw.check_scan_file())

        fbw.start_scan_file()
        assert.are.same('true', io.open("/tmp/scanning"):read("*a"))
        assert.is.equal('true', fbw.check_scan_file())

        fbw.end_scan()
        assert.are.same('false', io.open("/tmp/scanning"):read("*a"))
        assert.is.equal('false', fbw.check_scan_file())
    end)

    it('test is_configured() / mark_as_configured() ', function()

        assert.is.equal(false, fbw.is_configured())

        uci:set(config.UCI_NODE_NAME, 'system', 'lime')
        fbw.mark_as_configured()
        assert.is.equal('true', uci:get(config.UCI_NODE_NAME, 'system', 'firstbootwizard_configured'))

        config.uci_autogen()
        assert.is.equal(true, fbw.is_configured())

    end)

    it('test get_networks()', function()
        fbw.get_networks() -- TODO
    end)

    it('test get_networks() empty', function()
        local configs = fbw.read_configs()
        assert.is.equal(0, #configs)
    end)

    it('test get_networks() empty', function()
        local configs = fbw.read_configs()
        assert.is.equal(0, #configs)
    end)

    it('test get_networks() empty', function()
        utils.write_file('/tmp/fbw/lime-community__host__foonode', community_file)

        local configs = fbw.read_configs()
        assert.is.equal(1, #configs)
        assert.is.equal('foo', configs[1]['config']['wifi']['ap_ssid'])
        assert.is.equal('lime-community__host__foonode', configs[1]['file'])
    end)

    before_each('', function()
        uci = test_utils.setup_test_uci()
    end)

    after_each('', function()
        test_utils.teardown_test_uci(uci)
        fbw_utils.execute('rm -f /tmp/fbw/*')
        fbw_utils.execute('rm -f /tmp/scanning')
    end)

end)
