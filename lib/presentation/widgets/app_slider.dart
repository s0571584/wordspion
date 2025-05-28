import 'package:flutter/material.dart';

class AppSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final Color? activeColor;
  final Color? inactiveColor;

  const AppSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Safety checks to prevent crashes
    final double safeMax = max > min ? max : min + 1.0;
    final double safeValue = value.clamp(min, safeMax);
    final int safeDivisions = safeMax > min ? divisions : 1;

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: activeColor ?? theme.colorScheme.primary,
        inactiveTrackColor: inactiveColor ?? theme.colorScheme.primary.withOpacity(0.3),
        thumbColor: theme.colorScheme.primary,
        overlayColor: theme.colorScheme.primary.withOpacity(0.2),
        valueIndicatorColor: theme.colorScheme.primary,
        valueIndicatorTextStyle: TextStyle(
          color: theme.colorScheme.onPrimary,
          fontSize: 14.0,
        ),
      ),
      child: Slider(
        value: safeValue,
        min: min,
        max: safeMax,
        divisions: safeDivisions,
        label: safeValue.round().toString(),
        onChanged: onChanged,
      ),
    );
  }
}
