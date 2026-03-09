# mason API Reference

Dart template generator for creating files quickly and consistently from reusable templates called "bricks".

## Installation

```yaml
dependencies:
  mason: ^0.1.0-dev
```

```dart
import 'package:mason/mason.dart';
```

## Core Concepts

| Term | Description |
|------|-------------|
| **Brick** | A reusable template containing files, variables, and logic |
| **MasonGenerator** | Generates files from a brick definition |
| **DirectoryGeneratorTarget** | Specifies output directory for generated files |
| **Variables** | Dynamic inputs to customize template output |

## Brick Sources

### From Git Repository

```dart
final brick = Brick.git(
  const GitPath(
    'https://github.com/felangel/mason',
    path: 'bricks/greeting',
  ),
);
```

### From Local Path

```dart
final brick = Brick.path('/path/to/brick');
```

### From BrickHub

```dart
final brick = Brick.version(name: 'greeting', version: '^0.1.0');
```

## MasonGenerator

### Creating a Generator

```dart
final generator = await MasonGenerator.fromBrick(brick);
```

### Generator Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Unique identifier |
| `description` | `String` | Template description |
| `vars` | `List<BrickVariable>` | Required variables |
| `hooks` | `GeneratorHooks` | Pre/post generation hooks |

### Generating Files

```dart
final target = DirectoryGeneratorTarget(Directory.current);

final files = await generator.generate(
  target,
  vars: <String, dynamic>{
    'name': 'MyApp',
    'description': 'A sample application',
  },
);

print('Generated ${files.length} files');
```

## BrickYaml

Template definition file (`brick.yaml`):

```yaml
name: my_brick
description: A sample brick template
version: 0.1.0
environment:
  mason: ">=0.1.0-dev <0.1.0"

vars:
  name:
    type: string
    description: The project name
    default: my_project
    prompt: What is the project name?

  feature_enabled:
    type: boolean
    description: Enable the feature
    default: true
    prompt: Enable feature?

  count:
    type: number
    description: Number of items
    default: 5
    prompt: How many items?

  env:
    type: enum
    description: Environment
    default: dev
    prompt: Select environment
    values:
      - dev
      - staging
      - prod

  packages:
    type: array
    description: List of packages
    prompt: Enter packages (comma-separated)

  metadata:
    type: list
    description: Key-value pairs
    prompt: Enter metadata
```

## Variable Types

| Type | Dart Type | Description |
|------|-----------|-------------|
| `string` | `String` | Text value |
| `boolean` | `bool` | True/false |
| `number` | `num` | Numeric value |
| `enum` | `String` | One of allowed values |
| `array` | `List<String>` | List of strings |
| `list` | `List<Map>` | List of key-value maps |

## Template Syntax (Mustache)

### Variable Interpolation

```
// In template files:
Hello {{name}}!
```

### Conditionals

```mustache
{{#feature_enabled}}
This appears when feature_enabled is true.
{{/feature_enabled}}

{{^feature_enabled}}
This appears when feature_enabled is false.
{{/feature_enabled}}
```

### Loops

```mustache
{{#packages}}
- {{.}}
{{/packages}}

{{#metadata}}
{{key}}: {{value}}
{{/metadata}}
```

### Case Transformations

```mustache
{{name.pascalCase()}}    // MyProject
{{name.camelCase()}}     // myProject
{{name.snakeCase()}}     // my_project
{{name.paramCase()}}     // my-project
{{name.titleCase()}}     // My Project
{{name.constantCase()}}  // MY_PROJECT
{{name.headerCase()}}    // My-Project
{{name.dotCase()}}       // my.project
{{name.pathCase()}}      // my/project
{{name.sentenceCase()}}  // My project
{{name.upperCase()}}     // MYPROJECT
{{name.lowerCase()}}     // myproject
```

## Hooks

### Pre-Generation Hook

```dart
// hooks/pre_gen.dart
import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final name = context.vars['name'];
  context.logger.info('Generating $name...');

  // Modify or add variables
  context.vars['timestamp'] = DateTime.now().toIso8601String();
}
```

### Post-Generation Hook

```dart
// hooks/post_gen.dart
import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final progress = context.logger.progress('Running post-gen tasks');

  // Run additional setup
  await Process.run('dart', ['pub', 'get']);

  progress.complete('Setup complete!');
}
```

## MasonBundle

For embedding bricks in Dart packages:

```dart
import 'package:mason/mason.dart';

// Generated bundle from `mason bundle`
import '../../../../dart-cli/references/my_brick_bundle.dart';

Future<void> main() async {
  final generator = await MasonGenerator.fromBundle(myBrickBundle);
  final target = DirectoryGeneratorTarget(Directory.current);

  await generator.generate(
    target,
    vars: {'name': 'MyProject'},
  );
}
```

## Complete Example

```dart
import 'dart:io';
import 'package:mason/mason.dart';

Future<void> main() async {
  // Load brick from Git
  final brick = Brick.git(
    const GitPath(
      'https://github.com/felangel/mason',
      path: 'bricks/greeting',
    ),
  );

  // Create generator
  final generator = await MasonGenerator.fromBrick(brick);

  // Define output directory
  final target = DirectoryGeneratorTarget(
    Directory('output'),
  );

  // Generate files with variables
  final files = await generator.generate(
    target,
    vars: <String, dynamic>{
      'name': 'Dash',
      'greeting': 'Hello',
    },
  );

  print('Generated ${files.length} file(s):');
  for (final file in files) {
    print('  - ${file.path}');
  }
}
```

## CLI Commands

While this is the programmatic API, the `mason_cli` provides these commands:

| Command | Description |
|---------|-------------|
| `mason make <brick>` | Generate files from a brick |
| `mason add <brick>` | Add a brick to the project |
| `mason get` | Get all bricks in mason.yaml |
| `mason new <name>` | Create a new brick |
| `mason bundle <brick>` | Generate a Dart bundle |
| `mason unbundle <bundle>` | Generate brick from bundle |
| `mason list` | List installed bricks |
| `mason cache` | Manage brick cache |

## Resources

- [pub.dev package](https://pub.dev/packages/mason)
- [mason_cli](https://pub.dev/packages/mason_cli)
- [BrickHub](https://brickhub.dev)
- [Documentation](https://docs.brickhub.dev)
- [GitHub repository](https://github.com/felangel/mason)
