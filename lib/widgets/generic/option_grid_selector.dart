import 'package:flutter/material.dart';

class OptionItem<T> {
  final T value;
  final String label;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;

  const OptionItem({
    required this.value,
    required this.label,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
  });
}

class OptionGridSelector<T> extends StatelessWidget {
  final String title;
  final List<OptionItem<T>> options;
  final T selectedValue;
  final ValueChanged<T> onSelectionChanged;
  final int crossAxisCount;
  final double aspectRatio;
  final EdgeInsets? padding;

  const OptionGridSelector({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelectionChanged,
    this.crossAxisCount = 3,
    this.aspectRatio = 1.2,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth =
                  (constraints.maxWidth - (crossAxisCount - 1) * 8) /
                      crossAxisCount;
              final itemHeight = itemWidth / aspectRatio;

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: options.map((option) {
                  final isSelected = option.value == selectedValue;

                  return SizedBox(
                    width: itemWidth,
                    height: itemHeight,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onSelectionChanged(option.value),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected
                                ? theme.colorScheme.primaryContainer
                                : option.backgroundColor ??
                                    theme.colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.3),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline
                                      .withValues(alpha: 0.2),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                option.icon,
                                size: 28,
                                color: isSelected
                                    ? theme.colorScheme.onPrimaryContainer
                                    : (option.iconColor ??
                                        theme.colorScheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                option.label,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isSelected
                                      ? theme.colorScheme.onPrimaryContainer
                                      : theme.colorScheme.onSurfaceVariant,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SortOptionItem<T> {
  final T value;
  final String label;
  final IconData icon;
  final Color? iconColor;

  const SortOptionItem({
    required this.value,
    required this.label,
    required this.icon,
    this.iconColor,
  });
}

class SortOptionSelector<T> extends StatelessWidget {
  final String title;
  final List<SortOptionItem<T>> options;
  final T selectedValue;
  final bool isAscending;
  final ValueChanged<T> onSelectionChanged;
  final VoidCallback onOrderToggle;
  final EdgeInsets? padding;

  const SortOptionSelector({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.isAscending,
    required this.onSelectionChanged,
    required this.onOrderToggle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              // Sort order toggle button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onOrderToggle,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.3),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isAscending ? 'A-Z' : 'Z-A',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = option.value == selectedValue;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onSelectionChanged(option.value),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isSelected
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withValues(alpha: 0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          option.icon,
                          size: 16,
                          color: isSelected
                              ? theme.colorScheme.onPrimaryContainer
                              : (option.iconColor ??
                                  theme.colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          option.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
