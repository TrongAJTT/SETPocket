import 'package:flutter/material.dart';
import 'package:setpocket/models/info_models.dart';

class GenericInfoScreen extends StatelessWidget {
  final InfoPage page;
  const GenericInfoScreen({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Text(
              page.overview,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          // Sections
          ...page.sections
              .map((section) => _buildSectionWidget(theme, section)),
        ],
      ),
    );
  }

  Widget _buildSectionWidget(ThemeData theme, InfoSection section) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(section.icon, color: section.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    section.title,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(color: section.color),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Section Items
            ...section.items.map((item) => _buildItemWidget(theme, item)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemWidget(ThemeData theme, InfoItem item) {
    if (item is FeatureInfoItem) {
      return _buildFeatureInfoItem(theme, item);
    }
    if (item is DividerInfoItem) {
      return const Divider();
    }
    if (item is ColoredShapeInfoItem) {
      return _buildColoredShapeItem(theme, item);
    }
    if (item is SubSectionTitleInfoItem) {
      return _buildSubSectionTitleInfoItem(theme, item);
    }
    if (item is StepInfoItem) {
      return _buildStepInfoItem(theme, item);
    }
    if (item is PlainSubSectionInfoItem) {
      return _buildPlainSubSectionInfoItem(theme, item);
    }
    if (item is MathExpressionItem) {
      return _buildMathExpressionItem(theme, item);
    }
    if (item is UnorderListItem) {
      return _buildUnorderListItem(theme, item);
    }
    if (item is ParagraphInfoItem) {
      return _buildParagraphInfoItem(theme, item);
    }
    if (item is BlankLineInfoItem) {
      return _buildBlankLineItem(theme, item);
    }
    return const SizedBox.shrink();
  }

  Widget _buildColoredShapeItem(ThemeData theme, ColoredShapeInfoItem item) {
    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: item.shape == 'circle' ? BoxShape.circle : BoxShape.rectangle,
          color: item.color,
        ),
      ),
      title: Text(item.title, style: theme.textTheme.bodyLarge),
      subtitle: Text(item.description, style: theme.textTheme.bodyMedium),
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      minVerticalPadding: 0,
      dense: true,
    );
  }

  Widget _buildFeatureInfoItem(ThemeData theme, FeatureInfoItem item) {
    return ListTile(
      leading:
          Icon(item.icon, color: theme.iconTheme.color?.withValues(alpha: .7)),
      title: Text(item.title, style: theme.textTheme.titleMedium),
      subtitle: Text(item.description, style: theme.textTheme.bodyMedium),
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      minVerticalPadding: 0,
      dense: true,
    );
  }

  Widget _buildSubSectionTitleInfoItem(
      ThemeData theme, SubSectionTitleInfoItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        item.title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: item.color,
        ),
      ),
    );
  }

  Widget _buildStepInfoItem(ThemeData theme, StepInfoItem item) {
    return ListTile(
      leading: CircleAvatar(
        radius: 14,
        child: Text('${item.step}'),
      ),
      title: Text(item.title, style: theme.textTheme.bodyLarge),
      subtitle: Text(item.description, style: theme.textTheme.bodyMedium),
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      minVerticalPadding: 0,
      dense: true,
    );
  }

  Widget _buildPlainSubSectionInfoItem(
      ThemeData theme, PlainSubSectionInfoItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          if (item.description != null)
            Text(item.description!, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildMathExpressionItem(ThemeData theme, MathExpressionItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Center(
        child: Text(
          item.expression,
          style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'Courier'),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildUnorderListItem(ThemeData theme, UnorderListItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: theme.textTheme.bodyLarge),
          Expanded(
              child: Text(item.content, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildParagraphInfoItem(ThemeData theme, ParagraphInfoItem item) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(item.text, style: theme.textTheme.bodyMedium));
  }

  Widget _buildBlankLineItem(ThemeData theme, BlankLineInfoItem item) {
    return SizedBox(height: item.spaceCount * 8.0); // Adjust space as needed
  }
}
