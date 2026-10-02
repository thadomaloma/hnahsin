// Prints the content Sheet's “App text” rows (ID, Where, Built-in text) as
// tab-separated lines, from lib/src/app_text.dart. After adding a text to the
// app, paste the new lines at the bottom of the tab; Text can stay empty.
//
//   dart run tool/app_text_rows.dart            # every row
//   dart run tool/app_text_rows.dart --json     # the same, as JSON
import 'dart:convert';
import 'dart:io';

import '../lib/src/app_text.dart';

void main(List<String> args) {
  final rows = [
    for (final MapEntry(:key, :value) in appTextDefaults.entries)
      [key, value.where, value.text],
  ];
  if (args.contains('--json')) {
    stdout.writeln(jsonEncode(rows));
    return;
  }
  for (final row in rows) {
    stdout.writeln(row.map((cell) => cell.replaceAll('\n', r'\n').replaceAll('\t', ' ')).join('\t'));
  }
}
