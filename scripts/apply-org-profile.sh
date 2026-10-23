#!/usr/bin/env bash
# Apply the organization profile in org-profile.json to GitHub.
#
# GitHub stores an organization's description, website, location, and email
# in org settings, and each repository's description, website, and topics in
# repository settings, not in any file, so a pull request cannot change them.
# This script pushes the values in org-profile.json through the REST API:
# PATCH /orgs/{org}, then PATCH /repos/{org}/{repo} and PUT .../topics for
# each entry under .repositories. Run it from a machine where `gh` is
# authenticated as an organization owner:
#
#   ./scripts/apply-org-profile.sh            # apply
#   ./scripts/apply-org-profile.sh --dry-run  # print the requests, change nothing
#
# Requires: gh (https://cli.github.com), jq.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
profile="$here/org-profile.json"
dry_run=0
[[ "${1:-}" == "--dry-run" ]] && dry_run=1

for tool in gh jq; do
  command -v "$tool" >/dev/null 2>&1 || { echo "error: $tool is required" >&2; exit 1; }
done
[[ -f "$profile" ]] || { echo "error: $profile not found" >&2; exit 1; }

org="$(jq -r '.login' "$profile")"
[[ -n "$org" && "$org" != "null" ]] || { echo "error: org-profile.json needs a .login" >&2; exit 1; }

# Only the fields GitHub accepts on PATCH /orgs/{org}; nulls are dropped.
payload="$(jq -c '{name, description, blog, location, email, twitter_username}
                  | with_entries(select(.value != null))' "$profile")"

echo "Organization: $org"
echo "Payload:      $payload"

if [[ $dry_run -eq 0 ]]; then
  gh api --method PATCH "/orgs/$org" \
    -H "Accept: application/vnd.github+json" \
    --input <(printf '%s' "$payload") \
    --jq '{login, name, description, blog, location, email, twitter_username}'
fi

# Repository settings. Topics replace the whole list, so an empty list clears it.
jq -r '.repositories // {} | keys[]' "$profile" | while IFS= read -r repo; do
  settings="$(jq -c --arg r "$repo" '.repositories[$r] | {description, homepage}
                                     | with_entries(select(.value != null))' "$profile")"
  topics="$(jq -c --arg r "$repo" '{names: (.repositories[$r].topics // [])}' "$profile")"
  echo
  echo "Repository:   $org/$repo"
  echo "Settings:     $settings"
  echo "Topics:       $topics"
  [[ $dry_run -eq 1 ]] && continue
  gh api --method PATCH "/repos/$org/$repo" \
    -H "Accept: application/vnd.github+json" \
    --input <(printf '%s' "$settings") \
    --jq '{full_name, description, homepage}'
  gh api --method PUT "/repos/$org/$repo/topics" \
    -H "Accept: application/vnd.github+json" \
    --input <(printf '%s' "$topics") \
    --jq '.names'
done

if [[ $dry_run -eq 1 ]]; then
  echo "(dry run, nothing sent)"
  exit 0
fi

echo "Applied. Verify at https://github.com/$org"
