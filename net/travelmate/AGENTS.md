# AI-Assisted Captive Portal Onboarding

This branch contains AI-experimental tooling for the [travelmate](https://github.com/openwrt/packages/tree/master/net/travelmate) captive portal auto-login system.

The goal: make it trivial to add support for new captive portals by using AI agents (Playwright, LLMs, traffic analysis) to reverse-engineer the login flow and generate a travelmate-compatible `.login` script.

## Why This Exists

Travelmate ships 4 login scripts (wifibahn, telekom, vodafone, generic). The world has thousands of captive portals — hotels, airports, cafes, coworking spaces, transit systems. Each one is slightly different. Writing a `.login` script requires:

1. Connecting to the network
2. Observing the redirect chain (captive detection → splash page)
3. Finding the authentication mechanism (click-through, form POST, OAuth, etc.)
4. Extracting the grant/auth URL and required parameters
5. Writing a ~40-line shell script using only busybox tools

Steps 1-4 are repetitive, discoverable, and perfect for AI automation. Step 5 is a template.

## How to Onboard a New Captive Portal

### Method 1: Playwright Traffic Capture (Recommended)

Connect to the captive portal network on your laptop, then use Playwright to automate the browser while capturing all network traffic:

```
I'm connected to SSID [name] which has a captive portal.

1. Open Playwright with traffic capture enabled
2. Navigate to http://captive.apple.com (or any HTTP URL)
3. The AP will redirect — capture the full redirect chain
4. The splash page will load — capture its HTML and all JS/CSS resources
5. Record the "click through" or "accept" action (button click, form submit, etc.)
6. Capture the grant/redirect URL that authenticates the client
7. Verify by fetching http://captive.apple.com — should return "Success"

Give me:
- All redirect URLs in order (Location headers)
- The splash page HTML
- Any form actions or JavaScript that triggers authentication
- The final grant URL with all parameters
- Any cookies set during the flow
```

**What the AI agent does with this:**
- Parses the redirect chain to extract `base_grant_url`, `continue_url`, `node_mac`, etc.
- Identifies the auth mechanism (click-through = just hit the grant URL, form = POST credentials, OAuth = follow redirect chain)
- Generates a `.login` script following the travelmate conventions
- Tests the script logic against the captured data

### Method 2: Manual Capture + AI Script Generation

If Playwright isn't available (e.g., on a phone or restricted device):

```bash
# Step 1: Capture redirect chain
curl -svL --max-time 10 http://captive.apple.com 2>&1 | tee captive_trace.txt

# Step 2: Capture splash page
curl -sL http://my.meraki.net/ > splash.html  # or whatever the redirect target is

# Step 3: Capture the grant/auth after clicking through manually
# (click through in your browser, then immediately run:)
curl -sv http://captive.apple.com 2>&1 | tee post_auth.txt

# Step 4: Give all three files to an AI with:
# "Generate a travelmate .login script from these captures"
```

### Method 3: ADB Phone Automation

For Android phones with USB debugging:

```bash
adb shell "curl -svL --max-time 10 http://captive.apple.com" 2>&1 | tee captive_trace.txt
adb shell "am start -a android.intent.action.VIEW -d 'http://captive.apple.com'"
adb shell "screencap -p /data/local/tmp/splash.png" && adb pull /data/local/tmp/splash.png
adb shell "uiautomator dump /data/local/tmp/ui.xml" && adb pull /data/local/tmp/ui.xml
```

## Anatomy of a travelmate .login Script

Every script follows this structure:

```sh
#!/bin/sh
# captive portal auto-login script for [portal name] ([country])
# Copyright (c) 2025 [Your Name]
# This is free software, licensed under the GNU General Public License v3.
# shellcheck disable=all

export LC_ALL=C
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

trm_funlib="/usr/lib/travelmate-functions.sh"
if [ -z "${trm_bver}" ]; then
    . "${trm_funlib}"
    f_conf
fi

# Portal-specific domain (for DNS lookup check)
trm_domain="[portal-domain.example.com]"
if ! "${trm_lookupcmd}" "${trm_domain}" >/dev/null 2>&1; then
    exit 1
fi

# Step 1: Discover auth parameters
# Use ONLY: ${trm_fetch}, ${trm_fetchparm}, ${trm_useragent},
#           ${trm_lookupcmd}, ${trm_awkcmd}, ${trm_captiveurl}
#           ${trm_jsoncmd}, ${trm_sortcmd}

# Step 2: Authenticate

# Exit codes: 0 = success, 1-254 = specific failure, 255 = generic failure
```

## Defensive Coding Guidelines

When writing login scripts, apply these practices to handle edge cases from
unpredictable captive portal behavior:

### Validate extracted URLs

Before passing an extracted URL to curl, confirm it starts with `http://` or
`https://`. Some captive portals return malformed or empty redirect targets:

```sh
case "${extracted_url}" in
    http://*|https://*) ;;
    *) exit 2 ;;
esac
```

### Validate extracted hostnames

If extracting a domain name from a redirect, confirm it only contains valid
hostname characters (alphanumeric, dots, hyphens). This prevents issues with
malformed Location headers:

```sh
case "${domain}" in
    *[!a-zA-Z0-9._-]*) exit 1 ;;
esac
```

### Sanitize tokens before use in headers

Strip newlines and control characters from any value used in curl
`--header` arguments. While modern curl rejects multi-line headers,
this is a safe practice for compatibility with older versions:

```sh
token="$(printf "%s" "${token}" | tr -d '\000-\037\177')"
```

## Branch Structure

```
master              → upstream openwrt/packages (sync regularly)
ai-experimental     → this branch (default on fork)
feature/*           → specific portal implementations
```

## Contributing Back to Upstream

Once a `.login` script has been tested on actual OpenWrt hardware:

1. Rebase onto latest `openwrt/packages` master
2. Create a PR with just the `.login` file + Makefile install entry
3. Reference this repo's documentation in the PR description
4. Follow the contributing guidelines in the upstream CONTRIBUTING.md

## License

All travelmate `.login` scripts in this repo are GPL v3, matching the upstream project.
Documentation (AGENTS.md, etc.) is CC0 / public domain.
