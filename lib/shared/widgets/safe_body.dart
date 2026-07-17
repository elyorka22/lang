import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

extension SafePaddingX on BuildContext {
  /// Bottom inset so last list items / buttons clear the home indicator.
  EdgeInsets get scrollPadding {
    final bottom = MediaQuery.paddingOf(this).bottom;
    return EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.lg,
      AppSpacing.lg,
      AppSpacing.lg + bottom,
    );
  }

  EdgeInsets listBottomPadding({double extra = AppSpacing.lg}) {
    final bottom = MediaQuery.paddingOf(this).bottom;
    return EdgeInsets.only(bottom: bottom + extra);
  }
}

/// Applies bottom (and optional top) safe insets for scaffold bodies.
/// Use [top]: false when the screen already has an [AppBar].
class SafeBody extends StatelessWidget {
  const SafeBody({
    super.key,
    required this.child,
    this.top = false,
    this.bottom = true,
    this.minimum = EdgeInsets.zero,
  });

  final Widget child;
  final bool top;
  final bool bottom;
  final EdgeInsets minimum;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      minimum: minimum,
      child: child,
    );
  }
}
