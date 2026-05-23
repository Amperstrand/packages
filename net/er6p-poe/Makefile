# Copyright (C) 2025 Amperstrand
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=er6p-poe
PKG_VERSION:=0.5.0
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0-or-later
PKG_MAINTAINER:=Amperstrand

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./Kbuild $(PKG_BUILD_DIR)/
	$(CP) ./src $(PKG_BUILD_DIR)/src/
endef

define Build/Compile
	$(MAKE) $(KERNEL_MAKEOPTS) M="$(PKG_BUILD_DIR)" modules
endef

# ── Kernel module package ─────────────────────────────────────────────

define KernelPackage/er6p-poe
  SUBMENU:=Other modules
  TITLE:=EdgeRouter 6P PoE control driver
  DEPENDS:=@TARGET_octeon +kmod-i2c-core +kmod-hwmon-core
  FILES:=$(PKG_BUILD_DIR)/er6p-poe.ko
  AUTOLOAD:=$(call AutoLoad,30,er6p_poe,1)
endef

define KernelPackage/er6p-poe/description
  Kernel module for controlling 24V passive PoE on EdgeRouter 6P.
  Direct GPIO register manipulation for Cavium Octeon III.
  Provides sysfs interface at /sys/kernel/er6p_poe/ with per-port
  enable/mode controls and power budget tracking.
endef

# ── Userspace tools package ───────────────────────────────────────────

define Package/er6p-poe
  SECTION:=net
  CATEGORY:=Network
  TITLE:=EdgeRouter 6P PoE control tools
  DEPENDS:=+kmod-er6p-poe +jshn +i2c-tools
endef

define Package/er6p-poe/description
  Userspace tools for managing 24V passive PoE on EdgeRouter 6P:
  - poe: CLI tool for enable/disable/status
  - procd init script with UCI config (realtek-poe format)
  - poe-ubus: ubus provider for programmatic control
  - poe-monitor: hwmon-style power monitoring daemon
  - poe-watchdog: overcurrent protection daemon
endef

define Package/er6p-poe/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/etc/init.d/poe $(1)/etc/init.d/poe
	$(INSTALL_BIN) ./files/etc/init.d/poe-monitor $(1)/etc/init.d/poe-monitor
	$(INSTALL_BIN) ./files/etc/init.d/poe-watchdog $(1)/etc/init.d/poe-watchdog
	$(INSTALL_CONF) ./files/etc/config/poe $(1)/etc/config/poe
	$(INSTALL_BIN) ./files/etc/uci-defaults/30-poe-er6p $(1)/etc/uci-defaults/30-poe-er6p
	$(INSTALL_BIN) ./files/usr/sbin/poe $(1)/usr/sbin/poe
	$(INSTALL_BIN) ./files/usr/sbin/poe-ubus $(1)/usr/sbin/poe-ubus
	$(INSTALL_BIN) ./files/usr/sbin/poe-monitor $(1)/usr/sbin/poe-monitor
	$(INSTALL_BIN) ./files/usr/sbin/poe-watchdog $(1)/usr/sbin/poe-watchdog
endef

$(eval $(call KernelPackage,er6p-poe))
$(eval $(call BuildPackage,er6p-poe))
