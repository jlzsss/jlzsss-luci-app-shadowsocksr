#
# Copyright (C) 2016 Jian Chang <aa65535@live.com>
#                    2018 chenhw2 <https://github.com/chenhw2>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-shadowsocksr
PKG_VERSION:=1.9.1
PKG_RELEASE:=1

PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=chenhw2 <https://github.com/chenhw2>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-shadowsocksr
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=LuCI Support for shadowsocksR-libev
	PKGARCH:=all
	DEPENDS:=+iptables +ipset +curl +ip +iptables-mod-tproxy
endef

define Package/luci-app-shadowsocksr/description
	LuCI Support for shadowsocksR-libev.
endef

define Build/Prepare
	$(foreach po,$(wildcard ${CURDIR}/files/luci/i18n/*.po), \
		po2lmo $(po) $(PKG_BUILD_DIR)/$(patsubst %.po,%.lmo,$(notdir $(po)));)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-shadowsocksr/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	if [ -f /etc/uci-defaults/luci-ssr ]; then
		( . /etc/uci-defaults/luci-ssr ) && \
		rm -f /etc/uci-defaults/luci-ssr
	fi
	rm -rf /tmp/luci-indexcache /tmp/luci-modulecache
fi
exit 0
endef

define Package/luci-app-shadowsocksr/conffiles
/etc/config/ssr
endef

define Package/luci-app-shadowsocksr/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/ssr.*.lmo $(1)/usr/lib/lua/luci/i18n/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./files/luci/controller/*.lua $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/ssr
	$(INSTALL_DATA) ./files/luci/model/cbi/ssr/*.lua $(1)/usr/lib/lua/luci/model/cbi/ssr/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/ssr
	$(INSTALL_DATA) ./files/luci/view/ssr/*.htm $(1)/usr/lib/lua/luci/view/ssr/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/root/etc/config/ssr $(1)/etc/config/ssr
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/root/etc/init.d/ssr $(1)/etc/init.d/ssr
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/root/etc/uci-defaults/luci-ssr $(1)/etc/uci-defaults/luci-ssr
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/root/usr/bin/ssr-rules $(1)/usr/bin/ssrr-rules
endef

$(eval $(call BuildPackage,luci-app-shadowsocksr))
