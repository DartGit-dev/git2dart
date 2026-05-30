import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:git2dart/src/extensions.dart';
import 'package:git2dart/src/helpers/error_helper.dart';
import 'package:git2dart_binaries/git2dart_binaries.dart';

/// Clean up a commit [message].
String prettify({
  required String message,
  required bool stripComments,
  required int commentChar,
}) {
  return using((arena) {
    final out = arena<git_buf>();
    final messageC = message.toChar(arena);
    final error = libgit2.git_message_prettify(
      out,
      messageC,
      stripComments ? 1 : 0,
      commentChar,
    );

    checkErrorAndThrow(error);

    final result = out.ref.ptr.toDartString(length: out.ref.size);
    libgit2.git_buf_dispose(out);
    return result;
  });
}

/// Parse trailers from a commit [message].
Map<String, String> trailers(String message) {
  return using((arena) {
    final out = arena<git_message_trailer_array>();
    final messageC = message.toChar(arena);
    final error = libgit2.git_message_trailers(out, messageC);

    checkErrorAndThrow(error);

    final result = <String, String>{};
    for (var i = 0; i < out.ref.count; i++) {
      final trailer = out.ref.trailers[i];
      result[trailer.key.toDartString()] = trailer.value.toDartString();
    }

    libgit2.git_message_trailer_array_free(out);
    return result;
  });
}
