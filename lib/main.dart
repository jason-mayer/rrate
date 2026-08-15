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
      title: 'Respiratory Rate',
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
          Text('${tapper.estimate?.asBpm.toStringAsFixed(0) ?? "--"} bpm'),
          const Divider(),
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
          FutureBuilder(
            future: tapper.completer.future,
            builder: (context, snapshot) {
              if (snapshot.data case final Result data) {
                return Text(data.toString());
              }

              return FilledButton(
                onPressed: tapper.tap,
                child: const Text('Tap'),
              );
            },
          ),
          body,
        ],
      ),
    );
  }
}
