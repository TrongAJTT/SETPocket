import 'package:flutter/material.dart';

/// A generic option picker widget that supports both single and multiple selection
/// with configurable nullable behavior.
class OptionListPicker<T> extends StatelessWidget {
  /// List of available options
  final List<OptionItem<T>> options;

  /// Currently selected value(s)
  /// For single selection: T? or Set<T> with single item
  /// For multiple selection: Set<T>
  final dynamic selectedValue;

  /// Callback when selection changes
  /// For single selection: void Function(T? value)
  /// For multiple selection: void Function(Set<T> values)
  final void Function(dynamic value) onChanged;

  /// Whether to allow multiple selection
  final bool allowMultiple;

  /// Whether to allow null/no selection (only for single selection)
  final bool allowNull;

  /// Whether to show the selection control (radio/checkbox)
  final bool showSelectionControl;

  /// Whether to use compact layout (less padding)
  final bool isCompact;

  /// Custom card color when selected
  final Color? selectedCardColor;

  const OptionListPicker({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.allowMultiple = false,
    this.allowNull = false,
    this.showSelectionControl = true,
    this.isCompact = false,
    this.selectedCardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((option) {
        final isSelected = _isOptionSelected(option.value);

        return Padding(
          padding: EdgeInsets.only(bottom: isCompact ? 8 : 12),
          child: Card(
            color: isSelected
                ? (selectedCardColor ??
                    Theme.of(context).colorScheme.primaryContainer)
                : null,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _handleTap(option.value),
              child: Padding(
                padding: EdgeInsets.all(isCompact ? 12 : 16),
                child: Row(
                  children: [
                    // Selection control (radio button or checkbox)
                    if (showSelectionControl) ...[
                      if (allowMultiple)
                        Checkbox(
                          value: isSelected,
                          onChanged: (_) => _handleTap(option.value),
                        )
                      else
                        Radio<T?>(
                          value: option.value,
                          groupValue: allowNull
                              ? selectedValue
                              : (isSelected ? option.value : null),
                          onChanged: (value) => _handleTap(value),
                        ),
                      SizedBox(width: isCompact ? 8 : 12),
                    ],

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.label,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: isSelected
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer
                                      : null,
                                ),
                          ),
                          if (option.description != null) ...[
                            SizedBox(height: isCompact ? 2 : 4),
                            Text(
                              option.description!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: isSelected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer
                                            .withOpacity(0.8)
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Trailing icon (if provided by option)
                    if (option.trailingIcon != null) ...[
                      SizedBox(width: isCompact ? 8 : 12),
                      Icon(
                        option.trailingIcon,
                        size: 20,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  bool _isOptionSelected(T value) {
    if (allowMultiple) {
      final selectedSet = selectedValue as Set<T>?;
      return selectedSet?.contains(value) ?? false;
    } else {
      return selectedValue == value;
    }
  }

  void _handleTap(T? value) {
    if (allowMultiple) {
      final currentSet = Set<T>.from(selectedValue as Set<T>? ?? <T>{});

      if (value != null) {
        if (currentSet.contains(value)) {
          currentSet.remove(value);
        } else {
          currentSet.add(value);
        }
      }

      onChanged(currentSet);
    } else {
      // Single selection
      if (allowNull && selectedValue == value) {
        // Deselect if already selected and nulls are allowed
        onChanged(null);
      } else {
        onChanged(value);
      }
    }
  }
}

/// Data class for an option item
class OptionItem<T> {
  /// The value of this option
  final T value;

  /// Display label for this option
  final String label;

  /// Optional description text
  final String? description;

  /// Optional trailing icon
  final IconData? trailingIcon;

  /// Whether this option is enabled
  final bool enabled;

  const OptionItem({
    required this.value,
    required this.label,
    this.description,
    this.trailingIcon,
    this.enabled = true,
  });

  /// Factory constructor for simple text options
  factory OptionItem.simple(T value, String label) {
    return OptionItem(value: value, label: label);
  }

  /// Factory constructor for options with descriptions
  factory OptionItem.withDescription(
      T value, String label, String description) {
    return OptionItem(value: value, label: label, description: description);
  }
}
