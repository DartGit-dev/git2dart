import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Look up the value of one git attribute for path.
///
/// Returned value can be either `true`, `false`, `null` (if the attribute was
/// not set at all), or a [String] value, if the attribute was set to an actual
/// string.
Object? getAttribute({
  required Pointer<git_repository> repoPointer,
  required int flags,
  required String path,
  required String name,
}) {
  return using((arena) {
    final out = arena<Pointer<Char>>();
    final pathC = path.toChar(arena);
    final nameC = name.toChar(arena);

    final error = libgit2.git_attr_get(out, repoPointer, flags, pathC, nameC);
    checkErrorAndThrow(error);

    final result = out.value;
    final attributeValue = libgit2.git_attr_value(result);

    if (attributeValue == git_attr_value_t.GIT_ATTR_VALUE_UNSPECIFIED) {
      return null;
    }
    if (attributeValue == git_attr_value_t.GIT_ATTR_VALUE_TRUE) {
      return true;
    }
    if (attributeValue == git_attr_value_t.GIT_ATTR_VALUE_FALSE) {
      return false;
    }
    if (attributeValue == git_attr_value_t.GIT_ATTR_VALUE_STRING) {
      return result.toDartString();
    }
    return null;
  });
}

/// Look up the value of one git attribute for path with extended options.
///
/// Returns either `true`, `false`, `null` or a [String] value just like
/// [getAttribute].
Object? getAttributeExt({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_attr_options> optionsPointer,
  required String path,
  required String name,
}) {
  return using((arena) {
    final out = arena<Pointer<Char>>();
    final pathC = path.toChar(arena);
    final nameC = name.toChar(arena);

    final error = libgit2.git_attr_get_ext(
      out,
      repoPointer,
      optionsPointer,
      pathC,
      nameC,
    );
    checkErrorAndThrow(error);

    final result = out.value;
    final attributeValue = libgit2.git_attr_value(result);

    if (attributeValue == git_attr_value_t.GIT_ATTR_VALUE_UNSPECIFIED) {
      return null;
    }
    if (attributeValue == git_attr_value_t.GIT_ATTR_VALUE_TRUE) {
      return true;
    }
    if (attributeValue == git_attr_value_t.GIT_ATTR_VALUE_FALSE) {
      return false;
    }
    if (attributeValue == git_attr_value_t.GIT_ATTR_VALUE_STRING) {
      return result.toDartString();
    }
    return null;
  });
}

/// Look up a list of git attributes for a path.
///
/// Returns a list of attribute values corresponding to [names]. Each item is
/// either `true`, `false`, `null` or a [String] value.
List<Object?> getAttributesMany({
  required Pointer<git_repository> repoPointer,
  required int flags,
  required String path,
  required List<String> names,
}) {
  return using((arena) {
    final out = arena<Pointer<Char>>(names.length);
    final pathC = path.toChar(arena);
    final namesC = arena<Pointer<Char>>(names.length);
    for (var i = 0; i < names.length; i++) {
      namesC[i] = names[i].toChar(arena);
    }

    final error = libgit2.git_attr_get_many(
      out,
      repoPointer,
      flags,
      pathC,
      names.length,
      namesC,
    );
    checkErrorAndThrow(error);

    final results = <Object?>[];
    for (var i = 0; i < names.length; i++) {
      final ptr = out[i];
      final attributeValue = libgit2.git_attr_value(ptr);
      if (attributeValue == git_attr_value_t.GIT_ATTR_VALUE_UNSPECIFIED) {
        results.add(null);
      } else if (attributeValue == git_attr_value_t.GIT_ATTR_VALUE_TRUE) {
        results.add(true);
      } else if (attributeValue == git_attr_value_t.GIT_ATTR_VALUE_FALSE) {
        results.add(false);
      } else if (attributeValue == git_attr_value_t.GIT_ATTR_VALUE_STRING) {
        results.add(ptr.toDartString());
      } else {
        results.add(null);
      }
    }
    return results;
  });
}

/// Look up a list of git attributes for a path with extended options.
List<Object?> getAttributesManyExt({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_attr_options> optionsPointer,
  required String path,
  required List<String> names,
}) {
  return using((arena) {
    final out = arena<Pointer<Char>>(names.length);
    final pathC = path.toChar(arena);
    final namesC = arena<Pointer<Char>>(names.length);
    for (var i = 0; i < names.length; i++) {
      namesC[i] = names[i].toChar(arena);
    }

    final error = libgit2.git_attr_get_many_ext(
      out,
      repoPointer,
      optionsPointer,
      pathC,
      names.length,
      namesC,
    );
    checkErrorAndThrow(error);

    final results = <Object?>[];
    for (var i = 0; i < names.length; i++) {
      final ptr = out[i];
      final attributeValue = libgit2.git_attr_value(ptr);
      if (attributeValue == git_attr_value_t.GIT_ATTR_VALUE_UNSPECIFIED) {
        results.add(null);
      } else if (attributeValue == git_attr_value_t.GIT_ATTR_VALUE_TRUE) {
        results.add(true);
      } else if (attributeValue == git_attr_value_t.GIT_ATTR_VALUE_FALSE) {
        results.add(false);
      } else if (attributeValue == git_attr_value_t.GIT_ATTR_VALUE_STRING) {
        results.add(ptr.toDartString());
      } else {
        results.add(null);
      }
    }
    return results;
  });
}

final _attrEntries = <MapEntry<String, String?>>[];

int _foreachCb(Pointer<Char> name, Pointer<Char> value, Pointer<Void> payload) {
  final attrName = name.toDartString();
  final attrValue = value == nullptr ? null : value.toDartString();
  _attrEntries.add(MapEntry(attrName, attrValue));
  return 0;
}

/// Loop over all git attributes for a path.
List<MapEntry<String, String?>> foreachAttributes({
  required Pointer<git_repository> repoPointer,
  required int flags,
  required String path,
}) {
  const except = -1;
  final cb = Pointer.fromFunction<
    Int Function(Pointer<Char>, Pointer<Char>, Pointer<Void>)
  >(_foreachCb, except);

  using((arena) {
    final pathC = path.toChar(arena);
    final error = libgit2.git_attr_foreach(
      repoPointer,
      flags,
      pathC,
      cb,
      nullptr,
    );
    checkErrorAndThrow(error);
  });

  final result = List<MapEntry<String, String?>>.from(_attrEntries);
  _attrEntries.clear();
  return result;
}

/// Loop over all git attributes for a path with extended options.
List<MapEntry<String, String?>> foreachAttributesExt({
  required Pointer<git_repository> repoPointer,
  required Pointer<git_attr_options> optionsPointer,
  required String path,
}) {
  const except = -1;
  final cb = Pointer.fromFunction<
    Int Function(Pointer<Char>, Pointer<Char>, Pointer<Void>)
  >(_foreachCb, except);

  using((arena) {
    final pathC = path.toChar(arena);
    final error = libgit2.git_attr_foreach_ext(
      repoPointer,
      optionsPointer,
      pathC,
      cb,
      nullptr,
    );
    checkErrorAndThrow(error);
  });

  final result = List<MapEntry<String, String?>>.from(_attrEntries);
  _attrEntries.clear();
  return result;
}

/// Flush the gitattributes cache.
void cacheFlush(Pointer<git_repository> repo) {
  final error = libgit2.git_attr_cache_flush(repo);
  checkErrorAndThrow(error);
}

/// Add a macro definition.
void addMacro({
  required Pointer<git_repository> repoPointer,
  required String name,
  required String values,
}) {
  using((arena) {
    final nameC = name.toChar(arena);
    final valuesC = values.toChar(arena);
    final error = libgit2.git_attr_add_macro(repoPointer, nameC, valuesC);
    checkErrorAndThrow(error);
  });
}
