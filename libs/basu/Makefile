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

PKG_BUILD_FLAGS:=gc-sections

include $(INCLUDE_DIR)/package.mk

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

BASU_SRC_BASIC := \
	alloc-util.c \
	escape.c \
	fd-util.c \
	fileio.c \
	gunicode.c \
	hash-funcs.c \
	hashmap.c \
	hexdecoct.c \
	io-util.c \
	log.c \
	macro.c \
	mempool.c \
	parse-util.c \
	proc-cmdline.c \
	rlimit-util.c \
	sigbus.c \
	signal-util.c \
	siphash24.c \
	stat-util.c \
	string-table.c \
	string-util.c \
	strv.c \
	strxcpyx.c \
	time-util.c \
	umask-util.c \
	user-util.c \
	utf8.c \
	util.c \
	virt.c

BASU_SRC_SDBUS := \
	bus-common-errors.c \
	bus-container.c \
	bus-control.c \
	bus-convenience.c \
	bus-creds.c \
	bus-dump.c \
	bus-error.c \
	bus-gvariant.c \
	bus-internal.c \
	bus-introspect.c \
	bus-kernel.c \
	bus-match.c \
	bus-message.c \
	bus-objects.c \
	bus-protocol.c \
	bus-signature.c \
	bus-slot.c \
	bus-socket.c \
	bus-track.c \
	bus-type.c \
	sd-bus.c

BASU_SRC_SDDAEMON := \
	sd-daemon.c

BASU_SRC_SDID128 := \
	sd-id128.c \
	id128-util.c

BASU_BASIC_SRCS := $(addprefix src/basic/,$(BASU_SRC_BASIC))
BASU_SDBUS_SRCS := $(addprefix src/libsystemd/sd-bus/,$(BASU_SRC_SDBUS))
BASU_SDDAEMON_SRCS := $(addprefix src/libsystemd/sd-daemon/,$(BASU_SRC_SDDAEMON))
BASU_SDID128_SRCS := $(addprefix src/libsystemd/sd-id128/,$(BASU_SRC_SDID128))

BASU_ALL_SRCS := $(BASU_BASIC_SRCS) $(BASU_SDBUS_SRCS) $(BASU_SDDAEMON_SRCS) $(BASU_SDID128_SRCS)

BASU_INCLUDES := \
	-I$(PKG_BUILD_DIR)/src/basic \
	-I$(PKG_BUILD_DIR)/src/systemd \
	-I$(PKG_BUILD_DIR)/src/libsystemd/sd-bus \
	-I$(PKG_BUILD_DIR)/src/libsystemd/sd-daemon \
	-I$(PKG_BUILD_DIR)/src/libsystemd/sd-id128 \
	-I$(PKG_BUILD_DIR)/src/test

define Build/Configure
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_CPPFLAGS) \
		$(BASU_INCLUDES) \
		-include $(PKG_BUILD_DIR)/src/basic/config.h \
		-D_GNU_SOURCE \
		-ffunction-sections -fdata-sections \
		-c $(addprefix $(PKG_BUILD_DIR)/,$(BASU_ALL_SRCS))
	$(TARGET_AR) rcs $(PKG_BUILD_DIR)/libbasu.a *.o
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/systemd
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_BUILD_DIR)/src/systemd/sd-bus.h $(1)/usr/include/systemd/
	$(CP) $(PKG_BUILD_DIR)/src/systemd/sd-daemon.h $(1)/usr/include/systemd/
	$(CP) $(PKG_BUILD_DIR)/src/systemd/sd-id128.h $(1)/usr/include/systemd/
	$(CP) $(PKG_BUILD_DIR)/src/systemd/_sd-common.h $(1)/usr/include/systemd/
	$(CP) $(PKG_BUILD_DIR)/libbasu.a $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/libbasu.so $(1)/usr/lib/ 2>/dev/null || true
endef

define Package/libbasu/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libbasu.a $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libbasu))
