// ignore_for_file: file_names

import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('fetch contains unmanaged native allocations', () {
    final source = File('lib/src/bindings/remote.dart').readAsStringSync();
    final fetchStart = source.indexOf('void fetch(');
    final fetchEnd = source.indexOf('/// Perform a push', fetchStart);
    final fetchSource = source.substring(fetchStart, fetchEnd);

    expect(RegExp('calloc<').allMatches(fetchSource), hasLength(3));
    expect(fetchSource, isNot(contains('calloc.free(')));
  });
}
