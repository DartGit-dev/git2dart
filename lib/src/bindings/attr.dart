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
    final pathC = path.toChar();
    final nameC = name.toChar();

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
