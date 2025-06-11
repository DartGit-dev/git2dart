# Submodules

Some API methods for submodule management:

```dart
// Get list with all tracked submodules paths
repo.submodules; // => ['Submodule1', 'Submodule2'];

// Lookup submodule
Submodule.lookup(repo: repo, name: 'Submodule'); // => Submodule

// Init and update
Submodule.init(repo: repo, name: 'Submodule');
Submodule.update(repo: repo, name: 'Submodule');

// Add submodule
Submodule.add(repo: repo, url: 'https://some.url', path: 'submodule'); // => Submodule
```

Some methods for inspecting Submodule object:

```dart
// Get name of the submodule
submodule.name; // => 'Submodule'

// Get path to the submodule
submodule.path; // => 'Submodule'

// Get URL for the submodule
submodule.url; // => 'https://some.url'

// Set URL for the submodule in the configuration
submodule.url = 'https://updated.url';
submodule.sync();
```

---

