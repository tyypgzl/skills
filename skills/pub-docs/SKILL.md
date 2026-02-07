---
name: pub-docs
description: >
  Fetch and read Dart/Flutter package documentation from pub.dev and GitHub.
  Use when adding a new package dependency, learning how to use a package,
  checking package version/API, or needing package README documentation.
  Triggers on: "add package", "use package", "how to use X package",
  "package docs", "pub.dev", "package documentation", "install package",
  "flutter pub add", "dart pub add", any mention of integrating or using
  a specific pub.dev package.
---

# Pub Docs

Fetch Dart/Flutter package metadata and README documentation from pub.dev and GitHub.

## Quick Start

1. First, find the fetch script bundled with this skill:
   Use the Glob tool to search for `**/pub-docs/scripts/fetch_pub_docs.sh`

2. Then run it with the package name:
   ```bash
   bash <found_script_path> <package_name>
   ```

Example:
```bash
bash <found_script_path> riverpod
```

## Workflow

1. **Run the script** with the package name to fetch metadata (version, description, SDK constraint, dependencies) and the full README
2. **Read the output** to understand the package API, usage patterns, and examples
3. **Apply the knowledge** to implement the package in the project following the README guidance

## What the Script Returns

- Package name, latest version, description
- Repository URL
- SDK constraint
- Runtime dependencies
- Published date
- Full README content from GitHub (handles monorepos automatically)

## Handling Edge Cases

- **Monorepo packages** (e.g., `http` in `dart-lang/http/pkgs/http`): Script automatically detects subpath and fetches the correct README
- **No repository URL**: Some packages only have `homepage`; the script falls back to that
- **GitHub rate limiting**: If the raw URL fails, the script tries the GitHub API as fallback
- **Non-GitHub repos**: Script outputs a warning; manually fetch the README via WebFetch if needed

## API Details

See [references/workflow.md](references/workflow.md) for detailed API endpoint documentation.
