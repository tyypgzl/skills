---
name: dart-cli
description: Develop and extend Dart CLI applications using Very Good CLI patterns with args package and mason_logger. Use when adding commands, options, flags to existing Dart CLIs, implementing styled terminal output, writing testable CLI code with dependency injection, handling exceptions with proper exit codes, or configuring argParser syntax. See references/ for detailed API documentation on mason_logger, mason, and Effective Dart guidelines.
---

# Dart CLI Development

Extend Dart CLI applications following Very Good Ventures patterns.

## References

See `references/` folder for detailed documentation:
- [mason_logger.md](references/mason_logger.md) - Logger API, styling, progress, interactive prompts
- [mason.md](references/mason.md) - Template generator, bricks, Mustache syntax
- [effective_dart.md](references/effective_dart.md) - Style, documentation, usage, design guidelines

## Adding a Command

Create in `lib/src/commands/`:

```dart
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

class MyCommand extends Command<int> {
  MyCommand({Logger? logger}) : _logger = logger ?? Logger() {
    argParser
      ..addFlag('verbose', abbr: 'v', help: 'Verbose output', negatable: false)
      ..addOption('output', abbr: 'o', help: 'Output path', defaultsTo: '.')
      ..addOption('format', allowed: ['json', 'yaml'], defaultsTo: 'json');
  }

  final Logger _logger;

  @override
  String get name => 'mycommand';

  @override
  String get description => 'Does something useful';

  @override
  Future<int> run() async {
    final verbose = argResults?['verbose'] as bool;
    final output = argResults?['output'] as String;
    final args = argResults?.rest ?? []; // positional arguments

    _logger.info('Running...');
    return ExitCode.success.code;
  }
}
```

Register in CommandRunner: `addCommand(MyCommand(logger: logger));`

## Input Syntax

| Type | Definition | Access |
|------|-----------|--------|
| Flag | `addFlag('verbose', abbr: 'v', negatable: false)` | `argResults?['verbose'] as bool` |
| Negatable flag | `addFlag('pub', defaultsTo: true)` | Use `--no-pub` to set false |
| Option | `addOption('out', abbr: 'o')` | `argResults?['out'] as String` |
| Allowed values | `addOption('fmt', allowed: ['a','b'])` | Errors if invalid |
| Arguments | positional after command | `argResults?.rest` |

## Logger Output

### Basic Logging

```dart
_logger.info('Info');           // Standard output
_logger.success('Done');        // Green checkmark ✓
_logger.err('Failed');          // Red X ✗
_logger.warn('Warning');        // Yellow warning
_logger.alert('Alert');         // Highlighted alert
_logger.detail('Debug info');   // Gray detail text
```

### Progress Indicators

```dart
final progress = _logger.progress('Processing');
await doWork();
progress.update('Halfway done...');
await doMoreWork();
progress.complete('Finished!');  // Success
// Or: progress.fail('Error occurred');
// Or: progress.cancel();
```

### Interactive Prompts

```dart
// Single text input
final name = _logger.prompt('Enter name:', defaultValue: 'User');

// Confirmation
final confirmed = _logger.confirm('Continue?', defaultValue: true);

// Single choice
final env = _logger.chooseOne(
  'Select environment:',
  choices: ['dev', 'staging', 'prod'],
  defaultValue: 'dev',
);

// Multiple choice
final features = _logger.chooseAny(
  'Select features:',
  choices: ['auth', 'api', 'database'],
);

// Multiple text inputs
final tags = _logger.promptAny('Enter tags:');
```

### Styling Text

```dart
// Colors
lightCyan.wrap(text)
red.wrap(text)
green.wrap(text)
yellow.wrap(text)

// Background colors
backgroundRed.wrap(text)
backgroundGreen.wrap(text)

// Styles
styleBold.wrap(text)
styleItalic.wrap(text)
styleUnderlined.wrap(text)

// Combining
lightCyan.wrap(styleBold.wrap('Bold cyan'))
backgroundRed.wrap(white.wrap('White on red'))
```

### Hyperlinks

```dart
final link = link(
  message: 'Documentation',
  uri: Uri.parse('https://example.com/docs'),
);
_logger.info('See $link for more info.');
```

## Exit Codes

```dart
ExitCode.success.code      // 0 - successful completion
ExitCode.usage.code        // 64 - command line usage error
ExitCode.software.code     // 70 - internal software error
ExitCode.unavailable.code  // 69 - service unavailable
ExitCode.config.code       // 78 - configuration error
ExitCode.ioError.code      // 74 - input/output error
```

## Exception Handling

In CommandRunner's `run` method:

```dart
@override
Future<int> run(Iterable<String> args) async {
  try {
    return await runCommand(parse(args)) ?? ExitCode.success.code;
  } on FormatException catch (e) {
    _logger.err(e.message);
    return ExitCode.usage.code;
  } on UsageException catch (e) {
    _logger.err(e.message);
    _logger.info(e.usage);
    return ExitCode.usage.code;
  } catch (e) {
    _logger.err('Unexpected error: $e');
    return ExitCode.software.code;
  }
}
```

## Testing

```dart
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockLogger extends Mock implements Logger {}
class MockProgress extends Mock implements Progress {}

void main() {
  late MockLogger logger;
  late MockProgress progress;

  setUp(() {
    logger = MockLogger();
    progress = MockProgress();
    when(() => logger.progress(any())).thenReturn(progress);
  });

  test('command succeeds', () async {
    final command = MyCommand(logger: logger);
    expect(await command.run(), ExitCode.success.code);
    verify(() => logger.info(any())).called(1);
  });

  test('shows progress', () async {
    final command = MyCommand(logger: logger);
    await command.run();

    verify(() => logger.progress('Processing')).called(1);
    verify(() => progress.complete('Done!')).called(1);
  });

  test('prompts for input', () async {
    when(() => logger.prompt(any(), defaultValue: any(named: 'defaultValue')))
        .thenReturn('test-input');

    final command = MyCommand(logger: logger);
    await command.run();

    verify(() => logger.prompt('Enter name:', defaultValue: '')).called(1);
  });
}
```

## Dependencies

```yaml
dependencies:
  args: ^2.4.0
  mason_logger: ^0.2.0
dev_dependencies:
  mocktail: ^1.0.0
  test: ^1.24.0
```

## Code Style (Effective Dart)

### Naming
- `PascalCase` for classes, enums, extensions
- `camelCase` for variables, methods, parameters
- `snake_case` for files, packages
- Prefer `lowerCamelCase` for constants

### Documentation
- Use `///` for doc comments
- Start with single-sentence summary
- Use `[ClassName]` to reference other APIs

### Best Practices
- Prefer `async`/`await` over `.then()` chains
- Use collection literals `[]`, `{}`
- Check emptiness with `.isEmpty` not `.length == 0`
- Use `rethrow` to preserve stack traces
- Prefer tear-offs: `items.forEach(print)` not `items.forEach((e) => print(e))`
