#
# Copyright (C) 2025
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bitchat-relay
PKG_VERSION:=0.1.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/russellballestrini/bitchat-linux.git
PKG_SOURCE_VERSION:=f78e9766cbe9f908850ef36b9fb4db13ec03fc3d
PKG_MIRROR_HASH:=08a2fcd5eec15a2b822149d5dda2f492f5c288797b52f11f06748bd0b4a7db33

PKG_MAINTAINER:=Amperstrand
PKG_LICENSE:=Public-Domain
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_FLAGS:=gc-sections

include $(INCLUDE_DIR)/package.mk

define Package/bitchat-relay
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Bluetooth
  TITLE:=BitChat BLE mesh relay client
  URL:=https://github.com/russellballestrini/bitchat-linux
  DEPENDS:=+bluez-daemon +bluez-utils +dbus +libbasu +libopenssl +zlib +libpthread +librt
endef

define Package/bitchat-relay/description
  bitchat-linux is a C client for the BitChat Bluetooth LE mesh network.
  It joins the same BLE mesh that iOS, macOS, and Android clients use.
  This package provides a headless relay daemon that scans, advertises,
  serves GATT, and relays public messages with TTL decrement and dedup.
endef

define Package/bitchat-relay/conffiles
/etc/config/bitchat-relay
endef

define Build/Prepare
	$(call Build/Prepare/Default)
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -ffunction-sections -fdata-sections" \
		CPPFLAGS="-Iinclude -D_POSIX_C_SOURCE=200809L -D_GNU_SOURCE \
			-I$(STAGING_DIR)/usr/include \
			$(TARGET_CPPFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS) -Wl,--gc-sections" \
		LDLIBS_CORE="-lz -lbasu -lcrypto -lssl -lpthread -lrt" \
		LDLIBS_BLE="" \
		BIN=bitchat-relay \
		bitchat-relay
endef

define Package/bitchat-relay/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bitchat-relay $(1)/usr/sbin/bitchat-relay
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/bitchat-relay.config $(1)/etc/config/bitchat-relay
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/bitchat-relay.init $(1)/etc/init.d/bitchat-relay
	$(INSTALL_DIR) $(1)/etc/bitchat-relay
endef

define Package/bitchat-relay/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	echo "Run 'bitchat-relay --listen' for receive-only mode."
	echo "Run 'bitchat-relay --chat --nick <name>' for full mesh participation."
	echo "Enable as service: /etc/init.d/bitchat-relay enable && /etc/init.d/bitchat-relay start"
}
endef

$(eval $(call BuildPackage,bitchat-relay))
