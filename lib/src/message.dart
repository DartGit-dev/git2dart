import 'package:git2dart/src/bindings/message.dart' as bindings;

/// Utilities for commit message cleanup and trailer parsing.
class Message {
  Message._(); // coverage:ignore-line

  /// Cleans up excess whitespace and ensures the message has a trailing newline.
  ///
  /// If [stripComments] is true, lines starting with [commentChar] are removed.
  static String prettify({
    required String message,
    bool stripComments = false,
    String commentChar = '#',
  }) {
    if (commentChar.length != 1) {
      throw ArgumentError.value(
        commentChar,
        'commentChar',
        'Must be a single character.',
      );
    }

    return bindings.prettify(
      message: message,
      stripComments: stripComments,
      commentChar: commentChar.codeUnitAt(0),
    );
  }

  /// Parses Git trailers from the final paragraph of [message].
  static Map<String, String> trailers(String message) {
    return bindings.trailers(message);
  }
}
