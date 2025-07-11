import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/calculator_models/graphing_function.dart';
import 'package:setpocket/widgets/generic/generic_dialog.dart';
import 'package:setpocket/widgets/generic/option_grid_picker.dart';
import 'package:setpocket/widgets/generic/option_item.dart';
import 'dart:math' as math;
import 'package:setpocket/utils/size_utils.dart';
import 'package:setpocket/utils/icon_utils.dart';

class FunctionsPanel extends StatefulWidget {
  final TextEditingController functionController;
  final List<GraphingFunction> functions;
  final bool isCalculating;
  final bool hasValidationError;
  final Animation<double> shakeAnimation;
  final Function(String) onAddFunction;
  final Function(String) onRemoveFunction;
  final Function(String) onToggleVisibility;
  final Function(String, Color) onUpdateColor;
  final VoidCallback? onSaveToHistory;
  final bool showSaveButton;

  const FunctionsPanel({
    super.key,
    required this.functionController,
    required this.functions,
    required this.isCalculating,
    required this.hasValidationError,
    required this.shakeAnimation,
    required this.onAddFunction,
    required this.onRemoveFunction,
    required this.onToggleVisibility,
    required this.onUpdateColor,
    this.onSaveToHistory,
    required this.showSaveButton,
  });

  @override
  State<FunctionsPanel> createState() => _FunctionsPanelState();
}

class _FunctionsPanelState extends State<FunctionsPanel> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _validateFunction(String expression) {
    // Simplified validation - you might want to use the actual validation logic
    return expression.trim().isNotEmpty;
  }

  void _triggerValidationError() {
    // This would be handled by parent widget
  }

  void _insertFunctionText(
      String textToInsert, TextEditingController controller) {
    final currentText = controller.text;
    final selection = controller.selection;

    if (!selection.isValid) {
      // If selection is invalid, append the text.
      final newText = currentText + textToInsert;
      controller.value = controller.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    } else {
      // Otherwise, replace the current selection or insert at the cursor.
      final newText = currentText.replaceRange(
        selection.start,
        selection.end,
        textToInsert,
      );
      controller.value = controller.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.start + textToInsert.length,
        ),
      );
    }
  }

  Future<String?> _showFunctionInputHelp(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final List<Map<String, dynamic>> helpSections = [
      {
        'title': l10n.basicOperations,
        'functions': [
          {'f': 'x + 2', 'd': 'Addition'},
          {'f': 'x - 3', 'd': 'Subtraction'},
          {'f': 'x * 4', 'd': 'Multiplication'},
          {'f': 'x / 2', 'd': 'Division'},
          {'f': 'x^2', 'd': 'Power'},
          {'f': 'x^(1/2)', 'd': 'Square root'},
        ],
      },
      {
        'title': l10n.polynomialFunctions,
        'functions': [
          {'f': 'x^2', 'd': 'Quadratic'},
          {'f': 'x^3 - 2*x + 1', 'd': 'Cubic'},
          {'f': '2*x^4 - x^2 + 3', 'd': 'Quartic'},
          {'f': 'abs(x)', 'd': 'Absolute value'},
        ],
      },
      {
        'title': l10n.trigonometricFunctions,
        'functions': [
          {'f': 'sin(x)', 'd': 'Sine'},
          {'f': 'cos(x)', 'd': 'Cosine'},
          {'f': 'tan(x)', 'd': 'Tangent'},
          {'f': 'sin(x) + cos(x)', 'd': 'Combined trig'},
        ],
      },
      {
        'title': l10n.logarithmicFunctions,
        'functions': [
          {'f': 'log(x)', 'd': 'Natural logarithm'},
          {'f': 'log(abs(x))', 'd': 'Log of absolute'},
          {'f': 'e^x', 'd': 'Exponential'},
          {'f': '2^x', 'd': 'Power of 2'},
        ],
      },
      {
        'title': l10n.advancedFunctions,
        'functions': [
          {'f': '1/x', 'd': 'Hyperbola'},
          {'f': 'sqrt(x)', 'd': 'Square root'},
          {'f': 'sin(x)/x', 'd': 'Sinc function'},
          {'f': 'x*sin(1/x)', 'd': 'Complex oscillation'},
        ],
      },
    ];

    return showDialog(
      context: context,
      builder: (context) {
        return GenericDialog(
          decorator: GenericDialogDecorator(
            width: DynamicDimension.flexibilityMax(90, 600),
            displayTopDivider: true,
          ),
          header: GenericDialogHeader(
            icon: GenericIcon.icon(Icons.help_outline),
            title: l10n.functionInputHelp,
            subtitle: 'Get help with mathematical function syntax',
            displayExitButton: true,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: helpSections.map((section) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section['title'],
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (section['functions']
                                  as List<Map<String, String>>)
                              .map((func) {
                            return ActionChip(
                              onPressed: () {
                                Navigator.of(context).pop(func['f']!);
                              },
                              label: Column(
                                children: [
                                  Text(
                                    func['f']!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(func['d']!),
                                ],
                              ),
                              tooltip: '${l10n.insertFunction}: ${func['f']!}',
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          footer: GenericDialogFooter.empty(),
        );
      },
    );
  }

  void _showColorPickerDialog(
      BuildContext context, GraphingFunction function) async {
    Color pickerColor = function.color;
    final l10n = AppLocalizations.of(context)!;
    int selectedSegment = 0; // 0 for Predefined, 1 for Custom

    final List<Color> predefinedColors = [
      ...Colors.primaries,
      ...Colors.accents,
      Colors.black,
      Colors.white,
      Colors.grey,
      Colors.blueGrey,
      Colors.brown,
    ];

    final colorOptions = predefinedColors
        .map((color) => OptionItem<Color>(
              value: color,
              label: '', // Label is not needed for color swatches
              backgroundColor: color, // Use the color for the background
            ))
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return GenericDialog(
            decorator: GenericDialogDecorator(
                width: DynamicDimension.flexibilityMax(90, 450),
                displayTopDivider: true),
            header: GenericDialogHeader(
              icon: GenericIcon.icon(Icons.color_lens_outlined),
              title: l10n.editFunctionColor,
              subtitle: 'f(x) = ${function.expression}',
              displayExitButton: true,
            ),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: pickerColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      l10n.selectedColor,
                      style: TextStyle(
                        color: pickerColor.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // const SizedBox(height: 16),
                AutoScaleOptionGridPicker<Color>(
                  title: '', // No title needed here
                  options: colorOptions,
                  selectedValue: pickerColor,
                  onSelectionChanged: (newColor) {
                    setDialogState(() {
                      pickerColor = newColor;
                    });
                  },
                  minCellWidth: 40,
                  maxCellWidth: 40,
                  fixedCellHeight: 40, // Make cells square
                  decorator: const OptionGridDecorator(
                    padding: EdgeInsets.zero,
                  ),
                )
              ],
            ),
            footer: GenericDialogFooter.cancelSave(
              onCancel: () => Navigator.of(context).pop(),
              onSave: () {
                widget.onUpdateColor(function.id, pickerColor);
                Navigator.of(context).pop();
              },
              cancelText: l10n.cancel,
              saveText: l10n.select,
            ),
          );
        });
      },
    );
  }

  Widget _buildFunctionChip(String expression, String description) {
    final l10n = AppLocalizations.of(context)!;

    return ActionChip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            expression,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      onPressed: () {
        widget.functionController.text = expression;
        Navigator.of(context).pop();
      },
      tooltip: '${l10n.insertFunction}: $expression',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Function input
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: widget.shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: widget.hasValidationError
                          ? Offset(
                              math.sin(widget.shakeAnimation.value *
                                      math.pi *
                                      4) *
                                  5,
                              0)
                          : Offset.zero,
                      child: TextField(
                        controller: widget.functionController,
                        decoration: InputDecoration(
                          labelText: l10n.graphingFunction,
                          hintText: l10n.enterFunction,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: widget.hasValidationError
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).dividerColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: widget.hasValidationError
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: widget.hasValidationError
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).dividerColor,
                            ),
                          ),
                          errorText: widget.hasValidationError
                              ? l10n.functionSyntaxError
                              : null,
                          errorStyle: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          fillColor: widget.hasValidationError
                              ? Theme.of(context)
                                  .colorScheme
                                  .error
                                  .withValues(alpha: 0.1)
                              : null,
                          filled: widget.hasValidationError,
                        ),
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            if (_validateFunction(value.trim())) {
                              widget.onAddFunction(value.trim());
                              widget.functionController.clear();
                            } else {
                              _triggerValidationError();
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Help button
              IconButton(
                onPressed: () async {
                  final result = await _showFunctionInputHelp(context);
                  if (result != null) {
                    _insertFunctionText(result, widget.functionController);
                  }
                },
                icon: const Icon(Icons.help_outline),
                tooltip: l10n.functionInputHelp,
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.1),
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Add function button
              IconButton(
                onPressed: widget.isCalculating
                    ? null
                    : () {
                        final expression =
                            widget.functionController.text.trim();
                        if (expression.isNotEmpty) {
                          if (_validateFunction(expression)) {
                            widget.onAddFunction(expression);
                            widget.functionController.clear();
                          } else {
                            _triggerValidationError();
                          }
                        }
                      },
                icon: widget.isCalculating
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : const Icon(Icons.add),
                tooltip: l10n.addFunction,
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Save button removed from desktop view - now only in history panel

        const SizedBox(height: 8),

        // Active functions list
        Expanded(
          child: Stack(
            children: [
              widget.functions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.functions,
                            size: 48,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noActiveFunctions,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: widget.functions.length,
                      itemBuilder: (context, index) {
                        final function = widget.functions[index];
                        final screenWidth = MediaQuery.of(context).size.width;

                        // More sophisticated width calculation for responsive design
                        // Consider panel width in desktop mode (roughly 40% of screen)
                        final effectiveWidth =
                            screenWidth > 800 ? screenWidth * 0.4 : screenWidth;

                        // Use context menu if:
                        // - Mobile screen (< 600px)
                        // - Desktop panel too narrow (< 350px effective width)
                        // - Very long function expression
                        final useContextMenu = screenWidth <= 600 ||
                            effectiveWidth < 350 ||
                            function.expression.length > 20;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: ListTile(
                            leading: GestureDetector(
                              onTap: () =>
                                  _showColorPickerDialog(context, function),
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: function.color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 12,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                            title: Text(
                              '${l10n.graphingFunction}${function.expression}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontFamily: 'monospace',
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              function.isVisible
                                  ? l10n.functionVisible
                                  : l10n.functionHidden,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: function.isVisible
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.outline,
                                  ),
                            ),
                            trailing: useContextMenu
                                ? PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, size: 20),
                                    tooltip: l10n.moreActions,
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'toggle':
                                          widget
                                              .onToggleVisibility(function.id);
                                          break;
                                        case 'delete':
                                          widget.onRemoveFunction(function.id);
                                          break;
                                        case 'color':
                                          _showColorPickerDialog(
                                              context, function);
                                          break;
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'toggle',
                                        child: ListTile(
                                          leading: Icon(
                                            function.isVisible
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            size: 20,
                                          ),
                                          title: Text(l10n.toggleFunction),
                                          dense: true,
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'color',
                                        child: ListTile(
                                          leading: const Icon(Icons.color_lens,
                                              size: 20),
                                          title: Text(l10n.editFunctionColor),
                                          dense: true,
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: ListTile(
                                          leading: const Icon(Icons.delete,
                                              size: 20),
                                          title: Text(l10n.removeFunction),
                                          dense: true,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          function.isVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          size: 18,
                                        ),
                                        onPressed: () => widget
                                            .onToggleVisibility(function.id),
                                        tooltip: l10n.toggleFunction,
                                        style: IconButton.styleFrom(
                                          padding: const EdgeInsets.all(4),
                                          minimumSize: const Size(32, 32),
                                          foregroundColor: function.isVisible
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .outline,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon:
                                            const Icon(Icons.delete, size: 18),
                                        onPressed: () => widget
                                            .onRemoveFunction(function.id),
                                        tooltip: l10n.removeFunction,
                                        style: IconButton.styleFrom(
                                          padding: const EdgeInsets.all(4),
                                          minimumSize: const Size(32, 32),
                                          foregroundColor: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                      ),
                                    ],
                                  ),
                            onTap: () =>
                                _showColorPickerDialog(context, function),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
