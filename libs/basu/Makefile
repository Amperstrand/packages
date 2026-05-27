#
# Copyright (C) 2025
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=basu
PKG_VERSION:=0.2.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/emersion/basu.git
PKG_SOURCE_VERSION:=9ff82e33e501d39a1db8c7b20074bc883cc246c6
PKG_MIRROR_HASH:=315eeeb12f41447a5e1d8c296eeac4ab222fe69bbc30cb847904bb021830fe9c

PKG_MAINTAINER:=Amperstrand
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=gperf/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/libbasu
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Standalone sd-bus library (from systemd)
  URL:=https://github.com/emersion/basu
  DEPENDS:=+libpthread +librt
endef

define Package/libbasu/description
  basu provides the sd-bus D-Bus client library extracted from systemd.
  It allows applications to use the sd-bus API on systems without
  systemd, such as OpenWrt.
endef

MESON_ARGS += \
	-Daudit=false

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/systemd
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/include/systemd/*.h $(1)/usr/include/systemd/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libbasu.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/basu.pc $(1)/usr/lib/pkgconfig/ 2>/dev/null || true
endef

define Package/libbasu/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libbasu.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libbasu))
