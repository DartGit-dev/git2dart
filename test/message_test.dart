import 'package:git2dart/git2dart.dart';
import 'package:test/test.dart';

void main() {
  group('Message', () {
    test('prettifies commit message', () {
      expect(
        Message.prettify(
          message: 'subject\n\n# comment\n\nbody',
          stripComments: true,
        ),
        'subject\n\nbody\n',
      );
    });

    test('throws when comment char has invalid length', () {
      expect(
        () => Message.prettify(message: 'subject', commentChar: '//'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('parses trailers', () {
      expect(
        Message.trailers(
          'Subject\n\nBody\n\nReviewed-by: A User\nTicket: 42\n',
        ),
        {'Reviewed-by': 'A User', 'Ticket': '42'},
      );
    });
  });
}
