import 'package:flutter/material.dart';
import 'package:rrate/tapper.dart';

void main() {
  runApp(const RRate());
}

class RRate extends StatelessWidget {
  const RRate({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RRate',
      theme: .dark(),
      home: const TapperPage(),
    );
  }
}

class TapperPage extends StatefulWidget {
  const TapperPage({super.key});

  @override
  State<StatefulWidget> createState() => _TapperPage();
}

class _TapperPage extends State<TapperPage> {
  final Tapper tapper = .new();

  Widget get body => ListenableBuilder(
    listenable: tapper,
    builder: (context, child) {
      return Column(
        children: [
          Text('${tapper.estimate?.runningAverage.asBpm ?? '--'}'),
          const Divider(),
          for (final delay in tapper.delays) Text(delay),
        ],
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Respiratory Rate Tapper'),
        // backgroundColor: theme.colorScheme.surface,
      ),
      backgroundColor: theme.colorScheme.surfaceContainer,
      body: Column(
        children: [
          FilledButton(onPressed: tapper.tap, child: const Text('Tap')),
          body,
        ],
      ),
    );
  }
}
