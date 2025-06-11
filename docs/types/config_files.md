# Config files

Some methods and getters of Config object:

```dart
// Open config file at provided path
final config = Config.open('path/to/config'); // => Config

// Open configuration file for repository
final config = repo.config; // => Config

// Get value of config variable
config['user.name'].value; // => 'Some Name'

// Set value of config variable
config['user.name'] = 'Another Name';

// Delete variable from the config
config.delete('user.name');
```

---

