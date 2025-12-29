import 'package:flutter/material.dart';

/// Small reusable play/stop button that floats above rule example boards.
class RuleAnimationButton extends StatelessWidget {
  final bool isPlaying;
  final bool enabled;
  final VoidCallback onPressed;

  const RuleAnimationButton({
    super.key,
    required this.isPlaying,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color background = isPlaying
        ? scheme.errorContainer
        : scheme.primaryContainer;
    final Color foreground = isPlaying
        ? scheme.onErrorContainer
        : scheme.onPrimaryContainer;

    return IgnorePointer(
      ignoring: !enabled,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 0.95 : 0.35,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: enabled ? onPressed : null,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: background.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(80),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isPlaying ? Icons.stop : Icons.play_arrow,
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
