import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Create a new empty config instance. The returned config must be freed with
/// [free].
Pointer<git_config> init() {
  return using((arena) {
    final out = arena<Pointer<git_config>>();
    final error = libgit2.git_config_new(out);

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Create a new config instance containing a single on-disk file. The returned
/// config must be freed with [free].
Pointer<git_config> open(String path) {
  return using((arena) {
    final out = arena<Pointer<git_config>>();
    final pathC = path.toChar(arena);
    final error = libgit2.git_config_open_ondisk(out, pathC);

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Open the global, XDG and system configuration files.
///
/// Utility wrapper that finds the global, XDG and system configuration
/// files and opens them into a single prioritized config object that can
/// be used when accessing default config data outside a repository.
///
/// The returned config must be freed with [free].
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_config> openDefault() {
  return using((arena) {
    final out = arena<Pointer<git_config>>();
    final error = libgit2.git_config_open_default(out);

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Open the global configuration for writing according to git's rules.
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_config> openGlobal(Pointer<git_config> configPointer) {
  return using((arena) {
    final out = arena<Pointer<git_config>>();
    final error = libgit2.git_config_open_global(out, configPointer);

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Build a single-level focused config object from a multi-level one.
/// The returned config must be freed with [free].
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_config> openLevel({
  required Pointer<git_config> parentPointer,
  required int level,
}) {
  return using((arena) {
    final out = arena<Pointer<git_config>>();
    final error = libgit2.git_config_open_level(
      out,
      parentPointer,
      git_config_level_t.fromValue(level),
    );

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Add an on-disk config file to an existing config at the given [level].
///
/// Throws a [LibGit2Error] if error occured.
void addFileOndisk({
  required Pointer<git_config> configPointer,
  required String path,
  required int level,
  required Pointer<git_repository> repoPointer,
  bool force = false,
}) {
  using((arena) {
    final pathC = path.toChar(arena);
    final error = libgit2.git_config_add_file_ondisk(
      configPointer,
      pathC,
      git_config_level_t.fromValue(level),
      repoPointer,
      force ? 1 : 0,
    );

    checkErrorAndThrow(error);
  });
}

/// Set the write order for configuration backends.
///
/// Throws a [LibGit2Error] if error occured.
void setWriteOrder({
  required Pointer<git_config> configPointer,
  required List<int> levels,
}) {
  using((arena) {
    final levelsC = arena<Int>(levels.length);
    for (var i = 0; i < levels.length; i++) {
      levelsC[i] = levels[i];
    }
    final error = libgit2.git_config_set_writeorder(
      configPointer,
      levelsC,
      levels.length,
    );
    checkErrorAndThrow(error);
  });
}

/// Get a path value from the config.
///
/// Throws a [LibGit2Error] if error occured.
String getPath({
  required Pointer<git_config> configPointer,
  required String name,
}) {
  return using((arena) {
    final out = arena<git_buf>();
    final nameC = name.toChar(arena);
    final error = libgit2.git_config_get_path(out, configPointer, nameC);

    checkErrorAndThrow(error);

    final result = out.ref.ptr.toDartString(length: out.ref.size);
    libgit2.git_buf_dispose(out);
    return result;
  });
}

/// Locate the path to the global configuration file.
///
/// The user or global configuration file is usually located in
/// `$HOME/.gitconfig`.
///
/// This method will try to guess the full path to that file, if the file
/// exists. The returned path may be used to load the global configuration file.
///
/// This method will not guess the path to the xdg compatible config file
/// (`.config/git/config`).
///
/// Throws a [LibGit2Error] if error occured.
String findGlobal() {
  return using((arena) {
    final out = arena<git_buf>();
    final error = libgit2.git_config_find_global(out);

    checkErrorAndThrow(error);

    return out.ref.ptr.toDartString(length: out.ref.size);
  });
}

/// Locate the path to the system configuration file.
///
/// If `/etc/gitconfig` doesn't exist, it will look for
/// `%PROGRAMFILES%\Git\etc\gitconfig`
///
/// Throws a [LibGit2Error] if error occured.
String findSystem() {
  return using((arena) {
    final out = arena<git_buf>();
    final error = libgit2.git_config_find_system(out);

    checkErrorAndThrow(error);

    return out.ref.ptr.toDartString(length: out.ref.size);
  });
}

/// Locate the path to the global xdg compatible configuration file.
///
/// The xdg compatible configuration file is usually located in
/// `$HOME/.config/git/config`.
///
/// This method will try to guess the full path to that file, if the file
/// exists. The returned path may be used to load the xdg compatible
/// configuration file.
///
/// Throws a [LibGit2Error] if error occured.
String findXdg() {
  return using((arena) {
    final out = arena<git_buf>();
    final error = libgit2.git_config_find_xdg(out);

    checkErrorAndThrow(error);

    return out.ref.ptr.toDartString(length: out.ref.size);
  });
}

/// Locate the path to the global programdata configuration file.
///
/// Throws a [LibGit2Error] if error occured.
String findProgramData() {
  return using((arena) {
    final out = arena<git_buf>();
    final error = libgit2.git_config_find_programdata(out);

    checkErrorAndThrow(error);

    final result = out.ref.ptr.toDartString(length: out.ref.size);
    libgit2.git_buf_dispose(out);
    return result;
  });
}

/// Create a snapshot of the configuration. The returned config must be freed
/// with [free].
///
/// Create a snapshot of the current state of a configuration, which allows you
/// to look into a consistent view of the configuration for looking up complex
/// values (e.g. a remote, submodule).
Pointer<git_config> snapshot(Pointer<git_config> config) {
  return using((arena) {
    final out = arena<Pointer<git_config>>();
    final error = libgit2.git_config_snapshot(out, config);

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Get the config entry of a config variable. The returned config entry must
/// be freed with [freeEntry].
///
/// Throws a [LibGit2Error] if error occured.
Pointer<git_config_entry> getEntry({
  required Pointer<git_config> configPointer,
  required String variable,
}) {
  return using((arena) {
    final out = arena<Pointer<git_config_entry>>();
    final nameC = variable.toChar(arena);
    final error = libgit2.git_config_get_entry(out, configPointer, nameC);

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Get a boolean config value.
bool getBool({
  required Pointer<git_config> configPointer,
  required String variable,
}) {
  return using((arena) {
    final out = arena<Int>();
    final nameC = variable.toChar(arena);
    final error = libgit2.git_config_get_bool(out, configPointer, nameC);

    checkErrorAndThrow(error);
    return out.value != 0;
  });
}

/// Get a 32-bit integer config value.
int getInt32({
  required Pointer<git_config> configPointer,
  required String variable,
}) {
  return using((arena) {
    final out = arena<Int32>();
    final nameC = variable.toChar(arena);
    final error = libgit2.git_config_get_int32(out, configPointer, nameC);

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Get a 64-bit integer config value.
int getInt64({
  required Pointer<git_config> configPointer,
  required String variable,
}) {
  return using((arena) {
    final out = arena<Int64>();
    final nameC = variable.toChar(arena);
    final error = libgit2.git_config_get_int64(out, configPointer, nameC);

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Get a string config value.
String getString({
  required Pointer<git_config> configPointer,
  required String variable,
}) {
  return getStringBuf(configPointer: configPointer, name: variable);
}

/// Get a string config value using libgit2's direct pointer API.
///
/// libgit2 rejects this call for live config objects; use [getString] for
/// normal public reads.
String getStringPointer({
  required Pointer<git_config> configPointer,
  required String variable,
}) {
  return using((arena) {
    final out = arena<Pointer<Char>>();
    final nameC = variable.toChar(arena);
    final error = libgit2.git_config_get_string(out, configPointer, nameC);

    checkErrorAndThrow(error);
    return out.value.toDartString();
  });
}

/// Set the value of a boolean config variable in the config file with the
/// highest level (usually the local one).
void setBool({
  required Pointer<git_config> configPointer,
  required String variable,
  required bool value,
}) {
  return using((arena) {
    final nameC = variable.toChar(arena);
    final valueC = value ? 1 : 0;
    final error = libgit2.git_config_set_bool(configPointer, nameC, valueC);

    checkErrorAndThrow(error);
  });
}

/// Set the value of an integer config variable in the config file with the
/// highest level (usually the local one).
void setInt({
  required Pointer<git_config> configPointer,
  required String variable,
  required int value,
}) {
  return using((arena) {
    final nameC = variable.toChar(arena);
    final error = libgit2.git_config_set_int64(configPointer, nameC, value);

    checkErrorAndThrow(error);
  });
}

/// Set the value of a 32-bit integer config variable in the config file with
/// the highest level (usually the local one).
void setInt32({
  required Pointer<git_config> configPointer,
  required String variable,
  required int value,
}) {
  return using((arena) {
    final nameC = variable.toChar(arena);
    final error = libgit2.git_config_set_int32(configPointer, nameC, value);

    checkErrorAndThrow(error);
  });
}

/// Set the value of a string config variable in the config file with the
/// highest level (usually the local one).
void setString({
  required Pointer<git_config> configPointer,
  required String variable,
  required String value,
}) {
  return using((arena) {
    final nameC = variable.toChar(arena);
    final valueC = value.toChar(arena);
    final error = libgit2.git_config_set_string(configPointer, nameC, valueC);

    checkErrorAndThrow(error);
  });
}

/// Iterate over all the config variables. The returned iterator must be freed
/// with [freeIterator].
Pointer<git_config_iterator> iterator(Pointer<git_config> cfg) {
  return using((arena) {
    final out = arena<Pointer<git_config_iterator>>();
    final error = libgit2.git_config_iterator_new(out, cfg);

    checkErrorAndThrow(error);

    return out.value;
  });
}

/// Iterate over all config variables whose name matches [regexp].
///
/// The returned iterator must be freed with [freeIterator].
Pointer<git_config_iterator> globIterator({
  required Pointer<git_config> configPointer,
  required String regexp,
}) {
  return using((arena) {
    final out = arena<Pointer<git_config_iterator>>();
    final regexpC = regexp.toChar(arena);
    final error = libgit2.git_config_iterator_glob_new(
      out,
      configPointer,
      regexpC,
    );

    checkErrorAndThrow(error);

    return out.value;
  });
}

Map<String, Object?> _entryToMap(Pointer<git_config_entry> entry) {
  return {
    'name': entry.ref.name.toDartString(),
    'value': entry.ref.value.toDartString(),
    'includeDepth': entry.ref.include_depth,
    'level': entry.ref.level.value,
  };
}

List<Map<String, Object?>> _entriesFromIterator(
  Pointer<git_config_iterator> iterator,
) {
  return using((arena) {
    final entry = arena<Pointer<git_config_entry>>();
    final result = <Map<String, Object?>>[];

    while (true) {
      final error = libgit2.git_config_next(entry, iterator);
      if (error == git_error_code.GIT_ITEROVER.value) {
        break;
      }

      checkErrorAndThrow(error);
      result.add(_entryToMap(entry.value));
    }

    return result;
  });
}

/// Return all config entries from a glob iterator.
List<Map<String, Object?>> globEntries({
  required Pointer<git_config> configPointer,
  required String regexp,
}) {
  final iter = globIterator(configPointer: configPointer, regexp: regexp);
  try {
    return _entriesFromIterator(iter);
  } finally {
    freeIterator(iter);
  }
}

var _foreachEntries = <Map<String, Object?>>[];

int _foreachCb(Pointer<git_config_entry> entry, Pointer<Void> payload) {
  _foreachEntries.add(_entryToMap(entry));
  return 0;
}

/// Return entries by using libgit2's config foreach callback API.
List<Map<String, Object?>> foreachEntries(Pointer<git_config> configPointer) {
  final cb = Pointer.fromFunction<
    Int Function(Pointer<git_config_entry>, Pointer<Void>)
  >(_foreachCb, 0);

  _foreachEntries.clear();
  final error = libgit2.git_config_foreach(configPointer, cb, nullptr);
  checkErrorAndThrow(error);
  final result = _foreachEntries.toList(growable: false);
  _foreachEntries.clear();
  return result;
}

/// Return matching entries by using libgit2's config foreach-match API.
List<Map<String, Object?>> foreachMatchEntries({
  required Pointer<git_config> configPointer,
  required String regexp,
}) {
  return using((arena) {
    final cb = Pointer.fromFunction<
      Int Function(Pointer<git_config_entry>, Pointer<Void>)
    >(_foreachCb, 0);
    final regexpC = regexp.toChar(arena);

    _foreachEntries.clear();
    final error = libgit2.git_config_foreach_match(
      configPointer,
      regexpC,
      cb,
      nullptr,
    );
    checkErrorAndThrow(error);
    final result = _foreachEntries.toList(growable: false);
    _foreachEntries.clear();
    return result;
  });
}

/// Delete a config variable from the config file with the highest level
/// (usually the local one).
///
/// Throws a [LibGit2Error] if error occured.
void delete({
  required Pointer<git_config> configPointer,
  required String variable,
}) {
  return using((arena) {
    final nameC = variable.toChar(arena);
    final error = libgit2.git_config_delete_entry(configPointer, nameC);

    checkErrorAndThrow(error);
  });
}

/// Iterate over the values of a multivar.
///
/// If [regexp] is present, then the iterator will only iterate over all
/// values which match the pattern.
///
/// The regular expression is applied case-sensitively on the normalized form
/// of the variable name: the section and variable parts are lower-cased. The
/// subsection is left unchanged.
List<String> multivarValues({
  required Pointer<git_config> configPointer,
  required String variable,
  String? regexp,
}) {
  return using((arena) {
    final nameC = variable.toChar(arena);
    final regexpC = regexp?.toChar(arena) ?? nullptr;
    final iterator = arena<Pointer<git_config_iterator>>();
    final entry = arena<Pointer<git_config_entry>>();

    final error = libgit2.git_config_multivar_iterator_new(
      iterator,
      configPointer,
      nameC,
      regexpC,
    );

    checkErrorAndThrow(error);

    var nextError = 0;
    final entries = <String>[];

    try {
      while (nextError == 0) {
        nextError = libgit2.git_config_next(entry, iterator.value);
        if (nextError == git_error_code.GIT_ITEROVER.value) {
          break;
        }

        checkErrorAndThrow(nextError);
        entries.add(entry.value.ref.value.toDartString());
      }
    } finally {
      freeIterator(iterator.value);
    }

    return entries;
  });
}

/// Return multivar values using libgit2's foreach callback API.
List<String> multivarValuesForeach({
  required Pointer<git_config> configPointer,
  required String variable,
  String? regexp,
}) {
  return using((arena) {
    final nameC = variable.toChar(arena);
    final regexpC = regexp?.toChar(arena) ?? nullptr;
    final cb = Pointer.fromFunction<
      Int Function(Pointer<git_config_entry>, Pointer<Void>)
    >(_foreachCb, 0);

    _foreachEntries.clear();
    final error = libgit2.git_config_get_multivar_foreach(
      configPointer,
      nameC,
      regexpC,
      cb,
      nullptr,
    );

    if (error == git_error_code.GIT_ENOTFOUND.value) {
      return <String>[];
    }

    checkErrorAndThrow(error);
    final result = _foreachEntries
        .map((entry) => entry['value']! as String)
        .toList(growable: false);
    _foreachEntries.clear();
    return result;
  });
}

/// Mapping specification for config value mapping helpers.
class ConfigMapSpec {
  /// Creates a config mapping specification.
  const ConfigMapSpec({required this.type, required this.value, this.match});

  /// Type of value to match.
  final git_configmap_t type;

  /// String value to match when [type] is [git_configmap_t.GIT_CONFIGMAP_STRING].
  final String? match;

  /// Integer value returned for this mapping.
  final int value;
}

Pointer<git_configmap> _configMaps(Arena arena, List<ConfigMapSpec> maps) {
  final mapsC = arena<git_configmap>(maps.length);
  for (var i = 0; i < maps.length; i++) {
    mapsC[i].typeAsInt = maps[i].type.value;
    mapsC[i].str_match = maps[i].match?.toChar(arena) ?? nullptr;
    mapsC[i].map_value = maps[i].value;
  }
  return mapsC;
}

/// Return a config value mapped to an integer constant.
int getMapped({
  required Pointer<git_config> configPointer,
  required String name,
  required List<ConfigMapSpec> maps,
}) {
  return using((arena) {
    final out = arena<Int>();
    final nameC = name.toChar(arena);
    final mapsC = _configMaps(arena, maps);
    final error = libgit2.git_config_get_mapped(
      out,
      configPointer,
      nameC,
      mapsC,
      maps.length,
    );

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Return [value] mapped to an integer constant.
int lookupMapValue({required List<ConfigMapSpec> maps, required String value}) {
  return using((arena) {
    final out = arena<Int>();
    final mapsC = _configMaps(arena, maps);
    final valueC = value.toChar(arena);
    final error = libgit2.git_config_lookup_map_value(
      out,
      mapsC,
      maps.length,
      valueC,
    );

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Lock and immediately release the highest-priority config backend.
void lock(Pointer<git_config> configPointer) {
  return using((arena) {
    final out = arena<Pointer<git_transaction>>();
    final error = libgit2.git_config_lock(out, configPointer);

    checkErrorAndThrow(error);
    libgit2.git_transaction_free(out.value);
  });
}

/// Free the configuration and its associated memory and files.
void free(Pointer<git_config> cfg) => libgit2.git_config_free(cfg);

/// Free a config entry.
void freeEntry(Pointer<git_config_entry> entry) =>
    libgit2.git_config_entry_free(entry);

/// Free a config iterator.
void freeIterator(Pointer<git_config_iterator> iter) =>
    libgit2.git_config_iterator_free(iter);

/// Get a string value from a config.
///
/// The returned string must be freed with [free].
///
/// Throws a [LibGit2Error] if error occurred.
String getStringBuf({
  required Pointer<git_config> configPointer,
  required String name,
}) {
  return using((arena) {
    final out = arena<git_buf>();
    final nameC = name.toChar(arena);
    final error = libgit2.git_config_get_string_buf(out, configPointer, nameC);

    checkErrorAndThrow(error);

    final result = out.ref.ptr.toDartString(length: out.ref.size);
    libgit2.git_buf_dispose(out);
    return result;
  });
}

/// Parse [value] as a Git boolean.
bool parseBool(String value) {
  return using((arena) {
    final out = arena<Int>();
    final valueC = value.toChar(arena);
    final error = libgit2.git_config_parse_bool(out, valueC);

    checkErrorAndThrow(error);
    return out.value != 0;
  });
}

/// Parse [value] as a 32-bit Git integer.
int parseInt32(String value) {
  return using((arena) {
    final out = arena<Int32>();
    final valueC = value.toChar(arena);
    final error = libgit2.git_config_parse_int32(out, valueC);

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Parse [value] as a 64-bit Git integer.
int parseInt64(String value) {
  return using((arena) {
    final out = arena<Int64>();
    final valueC = value.toChar(arena);
    final error = libgit2.git_config_parse_int64(out, valueC);

    checkErrorAndThrow(error);
    return out.value;
  });
}

/// Parse [value] as a Git path.
String parsePath(String value) {
  return using((arena) {
    final out = arena<git_buf>();
    final valueC = value.toChar(arena);
    final error = libgit2.git_config_parse_path(out, valueC);

    checkErrorAndThrow(error);

    final result = out.ref.ptr.toDartString(length: out.ref.size);
    libgit2.git_buf_dispose(out);
    return result;
  });
}

/// Set a multivar in the local config file.
///
/// The [regexp] is a regular expression to indicate which values to replace.
///
/// Throws a [LibGit2Error] if error occurred.
void setMultivar({
  required Pointer<git_config> configPointer,
  required String name,
  required String regexp,
  required String value,
}) {
  return using((arena) {
    final nameC = name.toChar(arena);
    final regexpC = regexp.toChar(arena);
    final valueC = value.toChar(arena);
    final error = libgit2.git_config_set_multivar(
      configPointer,
      nameC,
      regexpC,
      valueC,
    );

    checkErrorAndThrow(error);
  });
}

/// Delete a multivar from the local config file.
///
/// The [regexp] is a regular expression to indicate which values to delete.
///
/// Throws a [LibGit2Error] if error occurred.
void deleteMultivar({
  required Pointer<git_config> configPointer,
  required String name,
  required String regexp,
}) {
  return using((arena) {
    final nameC = name.toChar(arena);
    final regexpC = regexp.toChar(arena);
    final error = libgit2.git_config_delete_multivar(
      configPointer,
      nameC,
      regexpC,
    );

    checkErrorAndThrow(error);
  });
}
