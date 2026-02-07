#!/usr/bin/env bash
# fetch_pub_docs.sh - Fetch Dart/Flutter package documentation from pub.dev and GitHub
# Usage: fetch_pub_docs.sh <package_name>
# Output: Package metadata + README content to stdout

set -euo pipefail

PACKAGE_NAME="${1:?Usage: fetch_pub_docs.sh <package_name>}"

# Step 1: Fetch package metadata from pub.dev API
PUB_API_URL="https://pub.dev/api/packages/${PACKAGE_NAME}"
PUB_RESPONSE=$(curl -sS --fail --max-time 15 "$PUB_API_URL" 2>/dev/null) || {
  echo "ERROR: Package '${PACKAGE_NAME}' not found on pub.dev" >&2
  exit 1
}

# Extract key fields and repo URL separately using python3
METADATA=$(python3 -c "
import json, sys

data = json.loads(sys.stdin.read())
latest = data.get('latest', {})
pubspec = latest.get('pubspec', {})

print('PACKAGE:', pubspec.get('name', 'N/A'))
print('VERSION:', pubspec.get('version', 'N/A'))
print('DESCRIPTION:', pubspec.get('description', 'N/A'))

repo = pubspec.get('repository', '') or pubspec.get('homepage', '')
print('REPOSITORY:', repo)

sdk = pubspec.get('environment', {}).get('sdk', 'N/A')
print('SDK:', sdk)

deps = pubspec.get('dependencies', {})
dep_list = [f'  - {k}: {v}' for k, v in deps.items() if not isinstance(v, dict)]
if dep_list:
    print('DEPENDENCIES:')
    print('\n'.join(dep_list))

published = latest.get('published', 'N/A')
print('PUBLISHED:', published)
" <<< "$PUB_RESPONSE")

REPO_URL=$(python3 -c "
import json, sys
data = json.loads(sys.stdin.read())
pubspec = data.get('latest', {}).get('pubspec', {})
print(pubspec.get('repository', '') or pubspec.get('homepage', ''))
" <<< "$PUB_RESPONSE")

echo "═══════════════════════════════════════════════════════"
echo " Package: ${PACKAGE_NAME}"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "$METADATA"
echo ""

# Step 2: Extract repository URL and fetch README
if [ -z "$REPO_URL" ]; then
  echo "WARNING: No repository URL found. Cannot fetch README." >&2
  exit 0
fi

# Parse GitHub owner/repo from repository URL
GITHUB_INFO=$(python3 -c "
import sys, re

url = sys.stdin.read().strip()
m = re.match(r'https?://github\.com/([^/]+)/([^/]+?)(?:\.git)?(?:/tree/([^/]+)(?:/(.+))?)?$', url)
if m:
    owner = m.group(1)
    repo = m.group(2)
    branch = m.group(3) or ''
    subpath = m.group(4) or ''
    print(f'{owner}/{repo}')
    print(branch)
    print(subpath)
else:
    print('')
    print('')
    print('')
" <<< "$REPO_URL")

OWNER_REPO=$(echo "$GITHUB_INFO" | sed -n '1p')
BRANCH=$(echo "$GITHUB_INFO" | sed -n '2p')
SUBPATH=$(echo "$GITHUB_INFO" | sed -n '3p')

if [ -z "$OWNER_REPO" ]; then
  echo "WARNING: Could not parse GitHub URL from: $REPO_URL" >&2
  exit 0
fi

echo "═══════════════════════════════════════════════════════"
echo " README"
echo "═══════════════════════════════════════════════════════"
echo ""

# Try fetching README from subpath first (for monorepo packages), then root
README_CONTENT=""

# Strategy 1: If there's a subpath, try README in subpath directory
if [ -n "$SUBPATH" ]; then
  for try_branch in "$BRANCH" "main" "master"; do
    [ -z "$try_branch" ] && continue
    URL="https://raw.githubusercontent.com/${OWNER_REPO}/${try_branch}/${SUBPATH}/README.md"
    README_CONTENT=$(curl -sS --fail --max-time 15 "$URL" 2>/dev/null) && break || README_CONTENT=""
  done
fi

# Strategy 2: Try root README
if [ -z "$README_CONTENT" ]; then
  for try_branch in "$BRANCH" "main" "master"; do
    [ -z "$try_branch" ] && continue
    URL="https://raw.githubusercontent.com/${OWNER_REPO}/${try_branch}/README.md"
    README_CONTENT=$(curl -sS --fail --max-time 15 "$URL" 2>/dev/null) && break || README_CONTENT=""
  done
fi

# Strategy 3: Use GitHub API as fallback
if [ -z "$README_CONTENT" ]; then
  API_URL="https://api.github.com/repos/${OWNER_REPO}/readme"
  if [ -n "$SUBPATH" ]; then
    API_URL="https://api.github.com/repos/${OWNER_REPO}/readme/${SUBPATH}"
  fi

  DOWNLOAD_URL=$(curl -sS --fail --max-time 15 "$API_URL" 2>/dev/null | python3 -c "
import json, sys
data = json.loads(sys.stdin.read())
print(data.get('download_url', ''))
" 2>/dev/null) || DOWNLOAD_URL=""

  if [ -n "$DOWNLOAD_URL" ]; then
    README_CONTENT=$(curl -sS --fail --max-time 15 "$DOWNLOAD_URL" 2>/dev/null) || README_CONTENT=""
  fi
fi

if [ -n "$README_CONTENT" ]; then
  echo "$README_CONTENT"
else
  echo "WARNING: Could not fetch README from GitHub." >&2
  echo "(Repository: $REPO_URL)" >&2
fi
