-- Copyright (C) 2016 Jian Chang <aa65535@live.com>
-- Licensed to the public under the GNU General Public License v3.

module("luci.controller.ssr", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/ssr") then
		return
	end

	entry({"admin", "services", "ssr"},
		alias("admin", "services", "ssr", "general"),
		_("ssr"), 11).dependent = true

	entry({"admin", "services", "ssr", "general"},
		cbi("ssr/general"),
		_("General Settings"), 10).leaf = true

	entry({"admin", "services", "ssr", "status"},
		call("action_status")).leaf = true

	entry({"admin", "services", "ssr", "servers"},
		arcombine(cbi("ssr/servers"), cbi("ssr/servers-details")),
		_("Servers Manage"), 20).leaf = true

	if luci.sys.call("command -v ssr-redir >/dev/null") ~= 0 then
		return
	end

	entry({"admin", "services", "ssr", "access-control"},
		cbi("ssr/access-control"),
		_("Access Control"), 30).leaf = true

	entry({"admin", "services", "ssr", "log"},
		call("action_log"),
		_("System Log"), 90).leaf = true

	if luci.sys.call("command -v /etc/init.d/dnsmasq-extra >/dev/null") ~= 0 then
		return
	end

	entry({"admin", "services", "ssr", "gfwlist"},
		call("action_gfw"),
		_("GFW-List"), 60).leaf = true

	entry({"admin", "services", "ssr", "custom"},
		cbi("ssr/gfwlist-custom"),
		_("Custom-List"), 50).leaf = true

end

local function is_running(name)
	return luci.sys.call("pgrep -x %s >/dev/null" %{name}) == 0
end

function action_status()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		ssr_redir = is_running("ssr-redir"),
		ssr_local = is_running("ssr-local"),
		ssr_tunnel = is_running("ssr-tunnel")
	})
end

function action_log()
	local fs = require "nixio.fs"
	local conffile = "/var/log/ssr_watchdog.log"
	local watchdog = fs.readfile(conffile) or ""
	luci.template.render("ssr/plain", {content=watchdog})
end

function action_gfw()
	local fs = require "nixio.fs"
	local conffile = "/etc/dnsmasq-extra.d/gfwlist"
	local gfwlist = fs.readfile(conffile) or ""
	luci.template.render("ssr/plain", {content=gfwlist})
end
