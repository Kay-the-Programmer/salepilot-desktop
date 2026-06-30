import 'package:flutter/material.dart';

import 'theme.dart';

/// The SalePilot logo, rendered consistently across every header.
///
/// Single source of truth so a future logo refresh (or per-store
/// white-labeling) only needs to change this one widget. Variants:
///   - [SalePilotLogo.icon] — small square mark for compact spots
///   - [SalePilotLogo.lockup] — mark + wordmark for headers
class SalePilotLogo extends StatelessWidget {
  const SalePilotLogo._({
    super.key,
    required this.size,
    required this.showWordmark,
    this.onTap,
  });

  /// Mark only — the icon tile suitable for tight leading slots.
  /// [size] is the square edge length of the rendered logo.
  const SalePilotLogo.icon({
    Key? key,
    double size = 28,
    VoidCallback? onTap,
  }) : this._(key: key, size: size, showWordmark: false, onTap: onTap);

  /// Mark + "SalePilot" wordmark side-by-side. Used in primary headers
  /// where there's space for the full lockup.
  const SalePilotLogo.lockup({
    Key? key,
    double size = 28,
    VoidCallback? onTap,
  }) : this._(key: key, size: size, showWordmark: true, onTap: onTap);

  final double size;
  final bool showWordmark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final mark = ClipRRect(
      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      child: Image.asset(
        'assets/salepilot_logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        // If the asset is ever missing in a dev build, fall back to the
        // gradient "SP" tile rather than crashing the app bar.
        errorBuilder: (_, _, _) => _GradientFallback(size: size),
      ),
    );

    final content = showWordmark
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              mark,
              const SizedBox(width: AppTokens.s2),
              const Text(
                'SalePilot',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          )
        : mark;

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: content,
        ),
      ),
    );
  }
}

/// Last-resort fallback when the asset can't load (e.g. during the very
/// first frame of a hot reload). Mirrors the gradient mark we used before
/// the real logo existed.
class _GradientFallback extends StatelessWidget {
  const _GradientFallback({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTokens.brandPrimary, AppTokens.brandSecondary],
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      alignment: Alignment.center,
      child: Text(
        'SP',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.35,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
