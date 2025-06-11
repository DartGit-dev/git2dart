import 'package:git2dart/git2dart.dart';
import 'package:test/test.dart';

void main() {
  group('Git2DartError', () {
    test('toString returns message', () {
      expect(Git2DartError('msg').toString(), 'msg');
    });

    test('stackTrace is not null', () {
      final error = Git2DartError('msg');
      expect(error.stackTrace, isNotNull);
    });
  });
}
