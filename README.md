# tguzeldev-skills

Claude Code plugin marketplace for Dart/Flutter development.

## Skills

### pub-docs

Fetches Dart/Flutter package documentation from pub.dev and GitHub. Claude automatically uses this skill when you mention adding, using, or integrating a pub.dev package.

**Triggers on:** "add package", "use package", "how to use X package", "package docs", "pub.dev", "flutter pub add", "dart pub add", etc.

**What it does:**
- Fetches package metadata (version, description, SDK constraint, dependencies)
- Downloads the full README from GitHub (handles monorepos automatically)
- Provides Claude with the documentation context to help implement the package

## Installation

### Option 1: Claude Code CLI

1. Open Claude Code in your terminal:

```bash
claude
```

2. Add the marketplace:

```shell
/plugin marketplace add tyypgzl/skills
```

3. Install the plugin:

```shell
/plugin install tguzeldev-skills@tguzeldev-skills
```

### Option 2: OpenSkills

You can also install using [OpenSkills](https://www.npmjs.com/package/openskills) with the GitHub repository:

```
https://github.com/tyypgzl/skills/
```

## Plugin Structure

```
.claude-plugin/
  plugin.json          # Plugin manifest
  marketplace.json     # Marketplace catalog
skills/
  pub-docs/
    SKILL.md           # Skill definition
    references/
      workflow.md      # API reference docs
    scripts/
      fetch_pub_docs.sh  # Package fetcher script
```
