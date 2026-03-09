# Effective Dart Reference

Best practices for writing clear, idiomatic Dart code across four categories: Style, Documentation, Usage, and Design.

## Guideline Strength

| Level | Meaning |
|-------|---------|
| **DO** | Always follow |
| **DON'T** | Almost never appropriate |
| **PREFER** | Generally recommended |
| **AVOID** | Rarely advisable |
| **CONSIDER** | Situational application |

---

## Style

### Identifiers

#### Types & Extensions: `UpperCamelCase`

```dart
class SliderMenu { }
enum Color { red, green, blue }
typedef Predicate<T> = bool Function(T value);
extension MyFancyList<T> on List<T> { }
```

#### Packages, Files, Imports: `lowercase_with_underscores`

```dart
// Package and file names
my_package/lib/file_system.dart

// Import prefixes
import 'dart:math' as math;
import 'package:flutter/material.dart' as material;
```

#### Other Identifiers: `lowerCamelCase`

```dart
var count = 3;
const defaultTimeout = Duration(seconds: 30);
void align(bool clearItems) { }
```

#### Constants: Prefer `lowerCamelCase`

```dart
// Good
const pi = 3.14;
final urlScheme = RegExp('^([a-z]+)://');

// Acceptable for consistency with existing code
const SHOUTY_CONSTANT = 42;
```

#### Acronyms

| Scenario | Rule | Example |
|----------|------|---------|
| 3+ letters | Capitalize as word | `Http`, `Uri`, `Nasa` |
| 2 letters (caps in English) | Keep both caps | `ID`, `UI`, `TV` |
| 2 letters (not caps) | Capitalize as word | `Mr`, `St`, `Ave` |
| Start of lowerCamelCase | All lowercase | `httpConnection`, `tvSet` |

#### Unused Parameters

```dart
// Use _ for unused callback parameters
futureOfVoid.then((_) { print('Done'); });

// Multiple unused can each be _
items.fold(0, (_, __) => count++);
```

### Import Ordering

1. `dart:` imports (core libraries)
2. `package:` imports (third-party)
3. Relative imports (local files)
4. Export statements (separate section)

```dart
import 'dart:async';
import 'dart:collection';

import 'package:bar/bar.dart';
import 'package:foo/foo.dart';

import '../../../../dart-cli/references/util.dart';

export '../../../../dart-cli/references/src/error.dart';
```

### Formatting

- Use `dart format` for all whitespace
- Aim for 80-character line length
- Always use curly braces for `if`, `else`, loops
- Exception: single-line `if` without `else` may omit braces

```dart
// Allowed
if (arg == null) return defaultValue;

// Required braces for multi-line or with else
if (condition) {
  doSomething();
} else {
  doSomethingElse();
}
```

---

## Documentation

### Comments

**DO format as sentences** - capitalize first word, end with punctuation.

**DON'T use block comments** for documentation - use `//` instead.

### Doc Comments

**DO use `///`** for documenting members and types:

```dart
/// Returns the lesser of two numbers.
///
/// Returns [a] if [a] is less than or equal to [b],
/// otherwise returns [b].
int min(int a, int b) => a <= b ? a : b;
```

**DO start with a single-sentence summary**:

```dart
/// Deletes the file at [path] from the file system.
void delete(String path) { }
```

**DO separate first sentence into its own paragraph**:

```dart
/// Deletes the file at [path].
///
/// Throws an [IOException] if the file could not be found.
/// Throws a [PermissionException] if access is denied.
void delete(String path) { }
```

### Describing APIs

| API Type | Start With | Example |
|----------|------------|---------|
| Function (side effect) | Third-person verb | "Connects to the server" |
| Function (returns value) | Noun phrase | "The element at [index]" |
| Variable (non-bool) | Noun phrase | "The current day of the week" |
| Variable (bool) | "Whether" | "Whether the modal is displayed" |
| Library/Type | Noun phrase | "A generator that produces..." |

### Markdown in Docs

- **AVOID** excessive formatting
- **AVOID** HTML (use Markdown)
- **PREFER** backtick fences for code blocks:

````dart
/// ```dart
/// final example = MyClass();
/// example.doSomething();
/// ```
````

### References

Use square brackets for identifiers:

```dart
/// Throws a [StateError] if called after [close].
/// See [MyClass.method()] for details.
void doSomething() { }
```

---

## Usage

### Libraries

- **DON'T** import private libraries from `src/`
- **DON'T** use relative paths crossing `lib` boundaries
- **PREFER** relative imports within the same package

### Null Safety

```dart
// DON'T explicitly initialize to null
int? value;  // Already null

// DON'T add explicit null defaults
void method({String? name}) { }  // null is implicit

// DON'T compare bool to true/false
if (isReady) { }  // Not: if (isReady == true)
if (!isEnabled) { }  // Not: if (isEnabled == false)
```

### Strings

```dart
// PREFER adjacent string concatenation
final message = 'This is a very long string that '
    'spans multiple lines.';

// PREFER interpolation
final greeting = 'Hello, $name!';
final info = 'Count: ${items.length}';

// DON'T use unnecessary braces
final simple = '$name is here';  // Not: '${name} is here'
```

### Collections

```dart
// DO use collection literals
var points = <Point>[];
var addresses = <String, Address>{};

// DO check emptiness properly
if (items.isEmpty) { }  // Not: if (items.length == 0)
if (items.isNotEmpty) { }

// AVOID forEach with function literals
for (final item in items) {
  process(item);
}
// forEach OK with existing functions:
items.forEach(print);

// DO use whereType for filtering
items.whereType<String>()  // Not: where((e) => e is String).cast<String>()
```

### Functions

```dart
// DO use function declarations
void greet(String name) {
  print('Hello, $name!');
}
// Not: final greet = (String name) { ... };

// DO use tear-offs
items.forEach(print);  // Not: items.forEach((e) => print(e))
```

### Members

```dart
// DON'T wrap fields unnecessarily
class Box {
  int value;  // Not: int _value; int get value => _value;
}

// DO use final for read-only fields
class Config {
  final String name;
}

// AVOID this. except for disambiguation
class Point {
  int x, y;
  Point(this.x, this.y);  // Not: Point(int x, int y) { this.x = x; ... }
}
```

### Constructors

```dart
// DO use initializing formals
class Point {
  final int x, y;
  Point(this.x, this.y);  // Not: Point(int x, int y) : x = x, y = y;
}

// DO use ; for empty constructor bodies
class Empty {
  Empty();  // Not: Empty() {}
}

// DON'T use new
final point = Point(1, 2);  // Not: new Point(1, 2)
```

### Error Handling

```dart
// AVOID bare catch
try {
  doSomething();
} on FormatException catch (e) {
  logger.warn('Bad format: $e');
} on IOException catch (e) {
  logger.err('IO failed: $e');
}
// Not: catch (e) { ... }

// DO use rethrow
try {
  process();
} catch (e) {
  logger.err('Failed');
  rethrow;  // Not: throw e;
}
```

### Asynchrony

```dart
// PREFER async/await
Future<void> fetchData() async {
  final response = await http.get(url);
  final data = await parseResponse(response);
  return processData(data);
}

// Not chained .then()
Future<void> fetchData() {
  return http.get(url).then((response) {
    return parseResponse(response).then((data) {
      return processData(data);
    });
  });
}

// DON'T use async when unnecessary
Future<int> getValue() => Future.value(42);  // No async needed
```

---

## Design

### Names

**DO use consistent naming** - same name for same concept throughout.

**DO place descriptive noun last**:
```dart
pageCount     // Not: countOfPages
ConversionSink  // Not: SinkForConversion
```

**Boolean naming**:
```dart
// PREFER non-imperative verbs
isEmpty
hasElements
canClose

// PREFER positive forms
isEnabled  // Not: isNotDisabled
```

**Method naming**:
```dart
// Imperative for side effects
list.add(item);
window.refresh();

// Noun/non-imperative for returning values
element = list.elementAt(0);
item = list.firstWhere(predicate);

// DON'T start with "get" - use getter
int get count => _count;  // Not: int getCount()

// to___() creates new object
list.toSet();
uri.toString();

// as___() returns view
list.asMap();
bytes.asUint8List();
```

### Libraries

- **PREFER** making declarations private (use `_` prefix)
- Consider multiple classes in one library for "friend" access

### Classes

```dart
// DON'T define single-member abstract classes
// Just use the function type
typedef Predicate<T> = bool Function(T);  // Not: abstract class Predicate<T>

// DON'T create classes with only static members
// Use top-level functions/constants instead

// DO use class modifiers
final class Immutable { }  // Can't be subclassed
interface class Pluggable { }  // Must be implemented, not extended
sealed class Result { }  // Exhaustive subtypes
```

### Constructors

```dart
// CONSIDER const constructors when possible
class Point {
  final int x, y;
  const Point(this.x, this.y);
}
```

### Members

```dart
// PREFER final fields
class Config {
  final String host;
  final int port;
  Config(this.host, this.port);
}

// DON'T return this from methods - use cascades
button
  ..color = Colors.red
  ..text = 'Click me'
  ..onClick = handler;

// AVOID returning null for Future/Stream/collections
Future<List<Item>> fetchItems() async {
  return [];  // Not: return null;
}
```

### Types

```dart
// DO annotate uninitialized variables
String name;  // Type required - no initializer

// PREFER inference for initialized locals
final items = <String>[];  // Type inferred
var count = 0;  // Type inferred

// DO write type arguments when inference fails
var playerScores = <String, int>{};

// DON'T use bare Function type
void process(int Function(String) parser) { }  // Not: Function parser
```

### Parameters

```dart
// AVOID positional boolean parameters
// Bad:
void connect(String host, bool secure) { }
connect('example.com', true);  // What's true?

// Good:
void connect(String host, {bool secure = false}) { }
connect('example.com', secure: true);

// Use inclusive start, exclusive end for ranges
list.sublist(1, 4);  // Elements 1, 2, 3
```

### Equality

```dart
// DO override hashCode when overriding ==
@override
bool operator ==(Object other) =>
    other is Point && other.x == x && other.y == y;

@override
int get hashCode => Object.hash(x, y);

// AVOID custom equality in mutable classes
// DON'T make == parameter nullable
```

---

## Resources

- [Effective Dart](https://dart.dev/effective-dart)
- [Dart Style Guide](https://dart.dev/effective-dart/style)
- [Dart Documentation Guide](https://dart.dev/effective-dart/documentation)
- [Dart Usage Guide](https://dart.dev/effective-dart/usage)
- [Dart Design Guide](https://dart.dev/effective-dart/design)
