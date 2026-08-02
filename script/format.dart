// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:html2md/html2md.dart';

void main() async {
  await log('generate html files', (log) async {
    final res = await Process.run('genhtml', [
      './coverage/lcov.info',
      '-o',
      './coverage/html',
      '--suppress-aliases',
      '--exclude',
      '.g.dart',
      '--flat',
      '--no-sourceview',
      '--no-function-coverage',
      '-t',
      'flutter test --coverage',
    ]);

    if (res.exitCode != 0) {
      throw res.stderr;
    }
  });

  final parsed = await log('parse coverage html file', (log) async {
    final file = File('coverage/html/index.html');
    final content = await file.readAsString();
    return parse(content);
  });

  await log('process html', (log) {
    int count = 0;

    for (final img in parsed.querySelectorAll('tr > td.ruler > img')) {
      final removed = img.parent?.parent?.remove() != null;
      if (!removed) continue;
      count += 1;
    }

    final elements = parsed
        .querySelectorAll('span.tableHeadSort')
        .followedBy(parsed.querySelectorAll('img'))
        .followedBy(parsed.querySelectorAll('td.coverBar'))
        .followedBy(parsed.querySelectorAll('title'));

    for (final element in elements) {
      element.remove();
      count += 1;
    }

    log('removed $count elements');

    final tables = parsed
        .querySelectorAll('body > *')
        .where((element) => element.localName != 'br')
        .toList();

    if (tables.length != 3) {
      throw 'Expected `body` to have 3 children, found ${tables.length}';
    }

    final [first, second, third] = tables;
    final body = Element.tag('body');

    final title = first.querySelector('td.title')!;
    final descTable = first.querySelector('table')!;

    body.append(Element.tag('h2')..innerHtml = title.text);

    final rows = descTable.querySelectorAll('tr').toList();
    rows.first.remove();
    rows.last.remove();

    final cols = rows.elementAt(1).children;
    cols.elementAt(1).innerHtml = '<code>${cols[1].text}</code>';
    final coverage =
        '${cols[4].innerHtml.replaceAll('&nbsp;', '')} (${cols[6].text} / ${cols[5].text})';

    final remove = rows.first.children
        .skip(1)
        .followedBy(rows.map((r) => r.children.skip(2)).expand((e) => e))
        .toList();

    for (final e in remove) {
      e.remove();
    }

    descTable
        .querySelector('tbody')!
        .append(
          Element.tag('tr')
            ..append(Element.html('<td><b>Coverage:</b></td>'))
            ..append(Element.tag('td')..text = coverage),
        );

    final p = Element.tag('p');

    for (final child in descTable.querySelectorAll('tr')) {
      final text = child
          .querySelectorAll('td')
          .map((d) => d.innerHtml.trim())
          .join(' ');

      p
        ..append(Element.tag('span')..innerHtml = text)
        ..append(Element.tag('br'));
    }

    body.append(p);

    final secondTable = second.querySelector('> table')!;
    final secondRows = secondTable.querySelectorAll('tr');
    secondRows.elementAt(0).remove();

    secondRows.elementAt(1).children.elementAt(1).text = 'Coverage';
    secondRows.elementAt(1).append(Element.tag('td')..text = 'Hits');

    secondRows.elementAt(2).remove();

    for (final element in secondRows.skip(3)) {
      element.children.first.innerHtml =
          '<code>${element.children.first.text}</code>';
      final percent = element.children.elementAt(1);
      percent.text = percent.innerHtml.replaceAll('&nbsp;', '');
      final elements = element.querySelectorAll('td.coverNumDflt').toList();
      final text = elements.reversed.map((e) => e.text).join(' / ');

      for (final e in elements) {
        e.remove();
      }

      element.append(Element.tag('td')..text = text);
    }

    body.append(secondTable);

    final version = third.querySelector('td.versionInfo')!;
    body.append(Element.tag('p')..innerHtml = version.innerHtml);

    int removed = 0;

    for (final element in body.querySelectorAll('*')) {
      element.attributes.removeWhere((name, val) {
        if (name == 'href') return false;

        removed++;
        return true;
      });
    }

    log('stripped $removed attributes');

    parsed.body!.replaceWith(body);
  });

  final converted = await log(
    'convert to markdown',
    (log) => '${convert(parsed.outerHtml)}\n',
  );

  await log('write to coverage/coverage.md', (log) async {
    final out = File('coverage/coverage.md');
    await out.writeAsString(converted);
  });
}

extension on Duration {
  String get asString {
    if (inMilliseconds < 1000) {
      return '$inMilliseconds ms';
    }

    return '${inSeconds.toStringAsFixed(1)}s';
  }
}

FutureOr<T> log<T>(
  String message, [
  FutureOr<T> Function(void Function(String text) log)? callback,
]) async {
  if (callback == null) {
    print('[format] $message');
    return null as T;
  }

  final start = DateTime.now();

  try {
    final result = await callback((text) {
      print('[format] ($message): $text');
    });
    final duration = DateTime.now().difference(start);
    print('[format] done: $message (took ${duration.asString})');
    return result;
  } catch (e) {
    final duration = DateTime.now().difference(start);
    print('[format] task FAILED in ${duration.asString}: $message');
    rethrow;
  }
}
