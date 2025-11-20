# Android Platform Setup

git2dart supports Android.

## Requirements

- Android API 21+ (Android 5.0+)
- Currently supports arm64-v8a and x86_64 architectures

### Quick Setup

Add this to your app's `main()` function:

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:git2dart/git2dart.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize platform specific logic 
  await PlatformSpecific.androidInitialize();

  runApp(MyApp());
}
```

### Why is this needed?

Android apps cannot access system CA certificates via standard filesystem paths. git2dart bundles Mozilla's trusted root certificates and extracts them to your app's cache directory on first run.

### Initialization Order

**Critical**: You must call  Call `await PlatformSpecific.androidInitialize()` before all works.

## Storage Recommendations

Use app-private storage to avoid Android permission issues:

```dart
import 'package:path_provider/path_provider.dart';
Future<void> cloneRepo() async {
  // Use app-private directory
  final appDir = await getApplicationDocumentsDirectory();
  final repoPath = '${appDir.path}/my-repo';
  final repo = Repository.clone(
    url: 'https://github.com/user/repo.git',
    localPath: repoPath,
  );
}
```

## Complete Example

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:git2dart/git2dart.dart';
import 'package:path_provider/path_provider.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PlatformSpecific.androidInitialize();

  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GitDemo(),
    );
  }
}
class GitDemo extends StatefulWidget {
  @override
  _GitDemoState createState() => _GitDemoState();
}
class _GitDemoState extends State<GitDemo> {
  String _status = 'Ready';
  Future<void> _cloneRepo() async {
    setState(() => _status = 'Cloning...');
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final repoPath = '${appDir.path}/my-repo';
      final repo = Repository.clone(
        url: 'https://github.com/DartGit-dev/git2dart_binaries.git',
        localPath: repoPath,
      );
      setState(() => _status = 'Cloned successfully!');
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('git2dart Android Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _cloneRepo,
              child: Text('Clone Repository'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Troubleshooting

### SSL errors

If you see SSL errors like "SSL error: unknown" or "no TLS stream available":

1. Verify you've added `await PlatformSpecific.androidInitialize()` to `main()`
2. Ensure `WidgetsFlutterBinding.ensureInitialized()` is called before call androidInitialize

### Authentication for private repositories

Use personal access tokens for private repositories:

```dart
Repository.clone(
  url: 'https://github.com/user/private-repo.git',
  localPath: repoPath,
  callbacks: Callbacks(
    credentials: (url, usernameFromUrl, allowedTypes) {
      return Credential.userpassPlaintext(
        username: 'your-username',
        password: 'your-personal-access-token',
      );
    },
  ),
);
```

## See Also

- [Main Documentation](README.md)
- [Repository Guide](types/repository.md)
- [Remote Operations](types/remote.md)
- [Credentials](types/credentials.md)