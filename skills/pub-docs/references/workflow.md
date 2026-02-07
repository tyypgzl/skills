# Pub Docs Workflow Reference

## API Endpoints

### pub.dev Package API
```
GET https://pub.dev/api/packages/<package_name>
```
Returns JSON with `name`, `latest` (version info, pubspec, repository), and `versions` array.

Key fields in `latest.pubspec`:
- `name`, `version`, `description`
- `repository` or `homepage` - GitHub URL
- `environment.sdk` - Dart SDK constraint
- `dependencies` - runtime dependencies

### GitHub README (raw)
```
GET https://raw.githubusercontent.com/<owner>/<repo>/<branch>/README.md
GET https://raw.githubusercontent.com/<owner>/<repo>/<branch>/<subpath>/README.md
```

### GitHub README API (fallback)
```
GET https://api.github.com/repos/<owner>/<repo>/readme
GET https://api.github.com/repos/<owner>/<repo>/readme/<subpath>
```
Returns JSON with `download_url` field.

## Monorepo Handling

Many Dart packages live in monorepos. The `repository` field often looks like:
```
https://github.com/dart-lang/http/tree/master/pkgs/http
```

The script parses this into:
- `owner/repo`: `dart-lang/http`
- `branch`: `master`
- `subpath`: `pkgs/http`

It tries README from subpath first, then falls back to root README.

## Common Package Repository Patterns

| Pattern | Example |
|---------|---------|
| Simple repo | `https://github.com/felangel/equatable` |
| Monorepo with tree | `https://github.com/dart-lang/http/tree/master/pkgs/http` |
| Homepage only | `https://github.com/user/repo` (older packages use `homepage` instead of `repository`) |
