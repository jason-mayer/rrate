import 'package:flutter/material.dart';

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
  Widget get body => Builder(
    builder: (context) {
      return FilledButton(onPressed: () {}, child: const Text('Tap'));
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
      body: body,
    );
  }
}
