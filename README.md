# tguzeldev-skills

Claude Code plugin for Dart/Flutter development.

## Skills

### pub-docs

Fetches Dart/Flutter package documentation from pub.dev and GitHub. Claude automatically uses this skill when you mention adding, using, or integrating a pub.dev package.

**Triggers on:** "add package", "use package", "how to use X package", "package docs", "pub.dev", "flutter pub add", "dart pub add", etc.

**What it does:**
- Fetches package metadata (version, description, SDK constraint, dependencies)
- Downloads the full README from GitHub (handles monorepos automatically)
- Provides Claude with the documentation context to help implement the package

## Installation

### From GitHub (marketplace)

Add this repository as a plugin marketplace, then install:

```bash
claude /plugin install tguzeldev-skills
```

### Local development

```bash
git clone https://github.com/tyypgzl/skills.git
claude --plugin-dir ./skills
```

## Plugin Structure

```
.claude-plugin/
  plugin.json          # Plugin manifest
skills/
  pub-docs/
    SKILL.md           # Skill definition
    references/
      workflow.md      # API reference docs
    scripts/
      fetch_pub_docs.sh  # Package fetcher script
```
