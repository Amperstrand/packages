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

## Available travelmate Variables

| Variable | Description |
|---|---|
| `${trm_fetch}` | curl binary path |
| `${trm_fetchparm}` | default curl parameters |
| `${trm_useragent}` | user agent string |
| `${trm_lookupcmd}` | DNS lookup command |
| `${trm_awkcmd}` | awk binary (use this, not raw `awk`) |
| `${trm_jsoncmd}` | jsonfilter binary (OpenWrt's JSON parser) |
| `${trm_sortcmd}` | sort binary |
| `${trm_captiveurl}` | URL used for captive detection |

## Captive Portal Taxonomy

Different portals need different approaches:

### Type 1: Click-through (simplest)
Just need the grant URL. Hit it with `continue_url` param and you're in.
Examples: Meraki, many hotel portals

### Type 2: Form POST
Need to extract a form action URL and POST credentials (or empty form).
Extract CSRF tokens from cookies/HTML first.
Examples: Deutsche Bahn (wifibahn), many European providers

### Type 3: OAuth/redirect chain
Multiple redirects through an identity provider. May need cookies.
Follow each redirect, extract session tokens.
Examples: Some enterprise guest networks

### Type 4: JavaScript-rendered
The splash page requires JavaScript execution to submit.
Cannot be handled by curl alone — needs browser automation or finding the underlying API endpoint.
Examples: Some modern captive portals

### Type 5: Credentials required
Requires username/password (hotel room number, etc.)
Use `script_args` in travelmate config to pass credentials.
Template: `generic-user-pass.login`

## Prompt Templates for AI Capture

### Template: Initial Discovery

```
I'm connected to SSID "[SSID]" which has a captive portal.

Using Playwright, please:
1. Navigate to http://captive.apple.com
2. Capture ALL network requests and responses (headers + bodies)
3. Follow all redirects until the splash page loads
4. Take a screenshot of the splash page
5. Dump the page HTML

Return:
- Ordered list of all URLs visited (redirect chain)
- For each URL: method, status code, Location header (if redirect), Content-Type
- Splash page HTML
- Screenshot description
```

### Template: Auth Flow Capture

```
The splash page is [description]. I need to [click "Continue" / fill form / etc.].

Using Playwright:
1. On the current splash page, find the [button/form element]
2. Start network capture
3. Click/submit
4. Capture ALL network activity during and after the click
5. Wait for redirect to complete
6. Verify by fetching http://captive.apple.com

Return:
- The exact URL that granted access (the "grant URL")
- All parameters in that URL
- Any cookies set
- Whether verification succeeded
```

### Template: Script Generation

```
From the captured traffic below, generate a travelmate-compatible .login script.

Rules:
- Must be /bin/sh (POSIX), NOT bash
- Must use only: ${trm_fetch}, ${trm_fetchparm}, ${trm_useragent}, ${trm_lookupcmd}, ${trm_awkcmd}, ${trm_jsoncmd}, ${trm_sortcmd}, ${trm_captiveurl}
- Must NOT use python3, perl, or any non-busybox tools
- Must source /usr/lib/travelmate-functions.sh
- Must handle errors with appropriate exit codes
- Keep it under 60 lines
- GPL v3 license header

Captured data:
[paste redirect chain, splash HTML, grant URL, cookies]
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
