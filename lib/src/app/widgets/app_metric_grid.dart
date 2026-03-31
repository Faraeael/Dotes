import 'package:flutter/material.dart';

class AppMetricGrid extends StatelessWidget {
  const AppMetricGrid({required this.children, this.spacing = 12, super.key});

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    for (var index = 0; index < children.length; index += 2) {
      if (rows.isNotEmpty) {
        rows.add(SizedBox(height: spacing));
      }

      final hasPair = index + 1 < children.length;
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: children[index]),
            if (hasPair) ...[
              SizedBox(width: spacing),
              Expanded(child: children[index + 1]),
            ],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}
