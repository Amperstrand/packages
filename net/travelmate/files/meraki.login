#!/bin/sh
# captive portal auto-login script for Cisco Meraki click-through portals
# Copyright (c) 2025 Amperstrand (https://github.com/Amperstrand)
# This is free software, licensed under the GNU General Public License v3.
#
# Portal type: Click-through (no credentials required)
#
# STATUS: Captured and analyzed but NOT fully tested on OpenWrt hardware.
# The grant URL extraction and redirect chain logic is sound, but the
# actual grant request has only been validated against captured data,
# not a live OpenWrt + travelmate deployment.
#
# Flow: client HTTP -> AP intercepts -> redirects to network-auth.com/splash/?base_grant_url=...
#       This script extracts base_grant_url and hits it directly, bypassing the splash page.

# shellcheck disable=all

export LC_ALL=C
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

trm_funlib="/usr/lib/travelmate-functions.sh"
if [ -z "${trm_bver}" ]; then
	. "${trm_funlib}"
	f_conf
fi

trm_domain="eu.network-auth.com"
if ! "${trm_lookupcmd}" "${trm_domain}" >/dev/null 2>&1; then
	trm_domain="my.meraki.net"
	if ! "${trm_lookupcmd}" "${trm_domain}" >/dev/null 2>&1; then
		exit 1
	fi
fi

# get redirect chain and extract base_grant_url from query parameters
#
redirect_url="$("${trm_fetch}" ${trm_fetchparm} --user-agent "${trm_useragent}" --write-out "%{redirect_url}" --output /dev/null "${trm_captiveurl}")"
base_grant_url="$(printf "%s" "${redirect_url}" 2>/dev/null | "${trm_awkcmd}" '
{
	n = split($0, parts, "&")
	for (i = 1; i <= n; i++) {
		pos = index(parts[i], "base_grant_url=")
		if (pos > 0) {
			val = substr(parts[i], pos + 15)
			gsub(/%25/, "%", val)
			gsub(/%3[Aa]/, ":", val)
			gsub(/%2[Ff]/, "/", val)
			print val
			exit
		}
	}
}')"
[ -z "${base_grant_url}" ] && exit 2

# hit the grant URL directly (bypasses splash page)
#
raw_html="$("${trm_fetch}" ${trm_fetchparm} --user-agent "${trm_useragent}" "${base_grant_url}?continue_url=http://google.com/&duration=86400")"
[ -z "${raw_html}" ] && exit 0 || exit 255
