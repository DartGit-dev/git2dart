# Index and IndexEntry

Some methods and getters to inspect and manipulate the Git index ("staging area"):

```dart
// Initialize Index object
final index = repo.index; // => Index

// Get number of entries in index
index.length; // => 69

// Re-read the index from disk
index.read();

// Write an existing index object to disk
index.write();

// Iterate over index entries
for (final entry in index) {
  print(entry.path); // => 'path/to/file.txt'
}

// Get a specific entry
final entry = index['file.txt']; // => IndexEntry

// Stage using path to file or IndexEntry (updates existing entry if there is one)
index.add('new.txt');

// Unstage entry from index
index.remove('new.txt');
```

---

