# Amperstrand/packages — AI-Experimental Fork

This is an experimental fork of [openwrt/packages](https://github.com/openwrt/packages) focused on **AI-assisted captive portal onboarding** for [travelmate](https://github.com/openwrt/packages/tree/master/net/travelmate).

## What's Different

| Branch | Purpose |
|---|---|
| `master` | Synced with upstream — do not modify |
| `ai-experimental` | This branch. Adds AGENTS.md, workflow docs, experimental tooling |
| `feature/*` | Individual captive portal implementations (may be untested) |

## Goal

Make it easy for anyone — with or without shell scripting experience — to capture their captive portal's login flow and contribute a working travelmate `.login` script.

See [net/travelmate/AGENTS.md](net/travelmate/AGENTS.md) for the full workflow.

## Portal Status

| Portal | Branch | Status | Notes |
|---|---|---|---|
| Cisco Meraki (click-through) | `feature/meraki-captive-portal` | ⚠️ Captured, not live-tested | Grant URL extracted. Needs verification on actual OpenWrt hardware. |

## Syncing with Upstream

```bash
git remote add upstream https://github.com/openwrt/packages.git
git fetch upstream
git checkout ai-experimental
git rebase upstream/master
```
