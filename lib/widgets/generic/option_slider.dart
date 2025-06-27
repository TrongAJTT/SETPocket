import 'package:flutter/material.dart';

/// A generic class to hold a value and its display label for the slider.
class SliderOption<T> {
  final T value;
  final String label;

  const SliderOption({required this.value, required this.label});
}

/// A generic, reusable slider widget for selecting from a list of predefined options.
/// It mirrors the design of the FileSizeSlider for a consistent UI.
class OptionSlider<T> extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData icon;
  final T currentValue;
  final List<SliderOption<T>> options;
  final ValueChanged<T> onChanged;
  final double fixedWidth;
  const OptionSlider(
      {super.key,
      required this.label,
      this.subtitle,
      required this.icon,
      required this.currentValue,
      required this.options,
      required this.onChanged,
      this.fixedWidth = 100});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    // Find the index of the currently selected option.
    final int selectedIndex =
        options.indexWhere((opt) => opt.value == currentValue);
    // If not found, default to the first option.
    final int displayIndex = selectedIndex != -1 ? selectedIndex : 0;
    final SliderOption<T> selectedOption = options[displayIndex];

    final valueSlider = Slider(
      value: displayIndex.toDouble(),
      min: 0,
      max: (options.length - 1).toDouble(),
      divisions: options.length > 1 ? options.length - 1 : 1,
      label: selectedOption.label,
      onChanged: (double value) {
        final newIndex = value.round();
        if (newIndex >= 0 && newIndex < options.length) {
          final newValue = options[newIndex].value;
          onChanged(newValue);
        }
      },
    );

    final displayValueWidget = Container(
      width: fixedWidth > 0 ? fixedWidth : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        selectedOption.label,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon,
                    color: theme.colorScheme.primary,
                    size: 24), // Slightly larger icon
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: theme.textTheme.titleMedium),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                    ],
                  ),
                ),
                // Desktop value display
                if (isLargeScreen) ...[
                  const SizedBox(width: 12),
                  displayValueWidget
                ],
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(child: valueSlider),
                if (!isLargeScreen) ...[
                  const SizedBox(width: 4),
                  displayValueWidget
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MobileRatio {
  int sliderWidth;
  int valueWidth;
  MobileRatio({required this.sliderWidth, required this.valueWidth});
}
