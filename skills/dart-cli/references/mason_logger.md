# mason_logger API Reference

Reusable logger for Dart CLI applications with styled output, progress indicators, and interactive prompts.

## Installation

```yaml
dependencies:
  mason_logger: ^0.2.0
```

```dart
import 'package:mason_logger/mason_logger.dart';
```

## Logger Class

### Constructor

```dart
final logger = Logger(level: Level.verbose);
```

### Log Levels

```dart
enum Level {
  verbose,  // All messages
  debug,    // Debug and above
  info,     // Info and above (default)
  warning,  // Warning and above
  error,    // Error only
  critical, // Critical only
  quiet,    // No output
}
```

### Output Methods

| Method | Description | Visual |
|--------|-------------|--------|
| `logger.info('message')` | Standard output | Plain text |
| `logger.success('message')` | Success notification | ✓ Green checkmark |
| `logger.err('message')` | Error message | ✗ Red X |
| `logger.warn('message')` | Warning message | Yellow text |
| `logger.alert('message')` | Alert-level message | Highlighted |
| `logger.detail('message')` | Detailed/debug info | Gray text |

### Custom Styling

```dart
String? customInfoStyle(String? m) {
  return backgroundDarkGray.wrap(styleBold.wrap(white.wrap(m)));
}

logger.info('custom styled', style: customInfoStyle);
```

## Interactive Methods

### Single Choice Selection

```dart
final color = logger.chooseOne(
  'Pick a color.',
  choices: ['red', 'green', 'blue'],
  defaultValue: 'blue',
);

// With custom display
final shape = logger.chooseOne<Shape>(
  'What is your favorite shape?',
  choices: Shape.values,
  display: (shape) => shape.name,
);
```

### Multiple Choice Selection

```dart
final desserts = logger.chooseAny(
  'Which desserts do you like?',
  choices: ['🍦', '🍪', '🍩'],
);

// With typed values and defaults
final shapes = logger.chooseAny<Shape>(
  'Choose multiple shapes',
  choices: Shape.values,
  defaultValues: [Shape.circle],
  display: (shape) => shape.name,
);
```

### Text Prompts

```dart
// Single value prompt
final animal = logger.prompt(
  'What is your favorite animal?',
  defaultValue: '🐈',
);

// Multiple values prompt
final languages = logger.promptAny(
  'What are your favorite programming languages?',
);
```

### Confirmation

```dart
final confirmed = logger.confirm(
  'Do you like cats?',
  defaultValue: true,
);
```

## Progress Class

### Basic Usage

```dart
final progress = logger.progress('Calculating');
await Future.delayed(Duration(milliseconds: 500));
progress.update('Halfway!');
await Future.delayed(Duration(milliseconds: 500));
progress.complete('Done!');
```

### Methods

| Method | Description |
|--------|-------------|
| `progress.update('status')` | Update progress message |
| `progress.complete('message')` | Mark as successfully completed |
| `progress.fail('message')` | Mark as failed |
| `progress.cancel()` | Cancel the progress |

### Examples

```dart
// Success flow
final progress = logger.progress('Processing');
await doWork();
progress.complete('Finished!');

// Failure flow
final failing = logger.progress('Trying something');
await attemptWork();
failing.fail('Operation failed');

// Cancellation
final canceling = logger.progress('Working');
if (shouldCancel) {
  canceling.cancel();
}
```

## Exit Codes

```dart
enum ExitCode {
  success,      // 0 - Successful completion
  usage,        // 64 - Command line usage error
  data,         // 65 - Data format error
  noInput,      // 66 - Cannot open input
  noUser,       // 67 - Addressee unknown
  noHost,       // 68 - Host name unknown
  unavailable,  // 69 - Service unavailable
  software,     // 70 - Internal software error
  osError,      // 71 - System error
  osFile,       // 72 - Critical OS file missing
  cantCreate,   // 73 - Cannot create output file
  ioError,      // 74 - Input/output error
  tempFail,     // 75 - Temporary failure
  protocol,     // 76 - Remote protocol error
  noPerm,       // 77 - Permission denied
  config,       // 78 - Configuration error
}

// Usage
return ExitCode.success.code;  // Returns 0
return ExitCode.usage.code;    // Returns 64
```

## Styling Functions

### Text Colors

```dart
// Foreground colors
black.wrap(text)
red.wrap(text)
green.wrap(text)
yellow.wrap(text)
blue.wrap(text)
magenta.wrap(text)
cyan.wrap(text)
white.wrap(text)
lightBlack.wrap(text)    // Gray
lightRed.wrap(text)
lightGreen.wrap(text)
lightYellow.wrap(text)
lightBlue.wrap(text)
lightMagenta.wrap(text)
lightCyan.wrap(text)
lightWhite.wrap(text)
```

### Background Colors

```dart
backgroundBlack.wrap(text)
backgroundRed.wrap(text)
backgroundGreen.wrap(text)
backgroundYellow.wrap(text)
backgroundBlue.wrap(text)
backgroundMagenta.wrap(text)
backgroundCyan.wrap(text)
backgroundWhite.wrap(text)
backgroundDarkGray.wrap(text)
backgroundLightRed.wrap(text)
backgroundLightGreen.wrap(text)
backgroundLightYellow.wrap(text)
backgroundLightBlue.wrap(text)
backgroundLightMagenta.wrap(text)
backgroundLightCyan.wrap(text)
backgroundLightWhite.wrap(text)
```

### Text Styles

```dart
styleBold.wrap(text)
styleDim.wrap(text)
styleItalic.wrap(text)
styleUnderlined.wrap(text)
styleBlink.wrap(text)
styleInverse.wrap(text)
styleHidden.wrap(text)
styleStrikethrough.wrap(text)
```

### Combining Styles

```dart
// Nested wrapping
lightCyan.wrap(styleBold.wrap('Bold cyan text'))
backgroundRed.wrap(white.wrap('White on red'))
styleBold.wrap(styleItalic.wrap(green.wrap('Bold italic green')))
```

## Links

```dart
final repoLink = link(
  message: 'GitHub Repository',
  uri: Uri.parse('https://github.com/felangel/mason'),
);
logger.info('Visit $repoLink for more info.');
```

## Complete Example

```dart
import 'package:mason_logger/mason_logger.dart';

enum Shape { square, circle, triangle }

Future<void> main() async {
  final logger = Logger(level: Level.verbose);

  // Basic logging
  logger
    ..info('Starting application')
    ..detail('Debug information')
    ..warn('This is a warning')
    ..success('Operation completed')
    ..err('Something went wrong')
    ..alert('Important notification');

  // Interactive prompts
  final name = logger.prompt('Enter your name:', defaultValue: 'User');
  final confirmed = logger.confirm('Continue?', defaultValue: true);

  final color = logger.chooseOne(
    'Pick a color:',
    choices: ['red', 'green', 'blue'],
  );

  final features = logger.chooseAny(
    'Select features:',
    choices: ['auth', 'api', 'database'],
  );

  // Progress tracking
  final progress = logger.progress('Processing');
  await Future.delayed(Duration(seconds: 1));
  progress.update('Almost done...');
  await Future.delayed(Duration(seconds: 1));
  progress.complete('Finished!');

  // Styled output
  logger.info(lightCyan.wrap('Cyan text'));
  logger.info(styleBold.wrap(green.wrap('Bold green')));
}
```

## Testing with Mocktail

```dart
import 'package:mason_logger/mason_logger.dart';
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

  test('logs success message', () {
    final command = MyCommand(logger: logger);
    command.run();

    verify(() => logger.success(any())).called(1);
  });

  test('shows progress', () async {
    final command = MyCommand(logger: logger);
    await command.run();

    verify(() => logger.progress('Working...')).called(1);
    verify(() => progress.complete('Done!')).called(1);
  });
}
```

## Resources

- [pub.dev package](https://pub.dev/packages/mason_logger)
- [GitHub repository](https://github.com/felangel/mason)
- [API documentation](https://pub.dev/documentation/mason_logger/latest/)
