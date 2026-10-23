# Augusto Plugins

This repository holds the public organization profile for
[github.com/augusto-plugins](https://github.com/augusto-plugins), where Augusto
Digital shares its Claude plugins privately with clients.

| What | Where |
|---|---|
| Profile page shown on the org home | [`profile/README.md`](profile/README.md) |
| Org settings (description, website, location, email) | [`org-profile.json`](org-profile.json), applied with [`scripts/apply-org-profile.sh`](scripts/apply-org-profile.sh) |
| Repository settings (description, website, topics) | `repositories` in [`org-profile.json`](org-profile.json), applied by the same script |

## Organization settings

GitHub keeps an organization's description, website, location and email, and
each repository's description, website and topics, in settings rather than in
a file, so this repo records the intended values and ships a script that
applies them.

| Field | Value |
|---|---|
| Display name | Augusto Plugins |
| Description | Claude plugins from Augusto Digital, shared privately with our clients. Access is by invitation. |
| Website | https://augusto.digital |
| Location | Grand Rapids, MI |
| Email | brian@augustodigital.com |

To apply, an org owner runs the following from a machine with an authenticated
[GitHub CLI](https://cli.github.com):

```sh
./scripts/apply-org-profile.sh --dry-run   # preview
./scripts/apply-org-profile.sh             # apply
```

Edit `org-profile.json` first when the values need to change, then re-run the
script so the repo and the settings stay in step. When a new plugin repository
joins the org, add it under `repositories` and give it an entry under Plugins
in `profile/README.md`.

Plugin repositories here are copies. Each one is replaced at every release from
its private source repository in Augusto-Digital, so edit a plugin's README or
files there, never here. Repository settings are not part of that copy, which is
why they live in this file.

## Logo

`profile/logo-light.png` and `profile/logo-dark.png` are the augusto-brand
skill's Full Horizontal lockups, copied unmodified (`Augusto-Full-Horizontal-2C.png`
for light, `Augusto-Full-Horizontal-Reverse.png` for dark), the same files the
Augusto-Digital public profile uses. Replace them from the brand skill, never by
hand.
