import 'package:flutter/material.dart';

import 'theme.dart';

/// Layout breakpoints (logical pixels of the available width).
///
/// The app targets desktop/tablet terminals, so these favour a dense two-pane
/// layout above [medium] and graceful stacking below it.
class Breakpoints {
  /// Below this, treat the surface as a single narrow column (phone / split view).
  static const double compact = 640;

  /// Below this, two-pane layouts tighten and multi-card rows halve.
  static const double medium = 1000;
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  bool get isCompact => screenWidth < Breakpoints.compact;
  bool get isMedium => screenWidth < Breakpoints.medium;
}

/// Lays out a list of equal-priority cards into a responsive grid that wraps
/// based on the available width. Cards in a row share width equally (via
/// [Expanded]) and each row is height-matched, so a row of summary tiles stays
/// tidy as the window resizes.
///
/// Defaults to a 4 / 2 / 1 column progression (expanded / medium / compact),
/// which suits the dashboard + inventory summary rows. Pass [columnsForWidth]
/// to override.
class ResponsiveCardGrid extends StatelessWidget {
  const ResponsiveCardGrid({
    super.key,
    required this.children,
    this.spacing = AppTokens.s3,
    this.columnsForWidth,
  });

  final List<Widget> children;
  final double spacing;
  final int Function(double width)? columnsForWidth;

  static int _defaultColumns(double width) {
    if (width >= Breakpoints.medium) return 4;
    if (width >= Breakpoints.compact) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolve = columnsForWidth ?? _defaultColumns;
        var cols = resolve(constraints.maxWidth);
        cols = cols.clamp(1, children.length);

        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += cols) {
          final end = (i + cols) > children.length ? children.length : i + cols;
          final slice = children.sublist(i, end);
          final cells = <Widget>[];
          for (var j = 0; j < cols; j++) {
            if (j > 0) cells.add(SizedBox(width: spacing));
            // Pad the final row with empty cells so card widths stay equal.
            cells.add(Expanded(
              child: j < slice.length ? slice[j] : const SizedBox.shrink(),
            ));
          }
          rows.add(IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: cells),
          ));
          if (end < children.length) rows.add(SizedBox(height: spacing));
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
      },
    );
  }
}
