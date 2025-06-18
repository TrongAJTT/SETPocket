import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/graphing_function.dart';
import 'package:setpocket/widgets/color_picker_dialog.dart';
import 'dart:math' as math;

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
  bool _validateFunction(String expression) {
    // Simplified validation - you might want to use the actual validation logic
    return expression.trim().isNotEmpty;
  }

  void _triggerValidationError() {
    // This would be handled by parent widget
  }

  Future<void> _showColorPicker(GraphingFunction function) async {
    final l10n = AppLocalizations.of(context)!;

    final selectedColor = await showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return ColorPickerDialog(
          initialColor: function.color,
          title: l10n.editFunctionColor,
          subtitle: '${l10n.graphingFunction}${function.expression}',
        );
      },
    );

    if (selectedColor != null) {
      widget.onUpdateColor(function.id, selectedColor);
    }
  }

  void _showFunctionInputHelp() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 700,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Container(
              width: MediaQuery.of(context).size.width < 700
                  ? MediaQuery.of(context).size.width * 0.9
                  : 700,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.functionInputHelp,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.functionInputHelpDesc,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFunctionCategory(
                            l10n.basicOperations,
                            [
                              ('x + 2', 'Addition'),
                              ('x - 3', 'Subtraction'),
                              ('x * 4', 'Multiplication'),
                              ('x / 2', 'Division'),
                              ('x^2', 'Power'),
                              ('x^(1/2)', 'Square root'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildFunctionCategory(
                            l10n.polynomialFunctions,
                            [
                              ('x^2', 'Quadratic'),
                              ('x^3 - 2*x + 1', 'Cubic'),
                              ('2*x^4 - x^2 + 3', 'Quartic'),
                              ('abs(x)', 'Absolute value'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildFunctionCategory(
                            l10n.trigonometricFunctions,
                            [
                              ('sin(x)', 'Sine'),
                              ('cos(x)', 'Cosine'),
                              ('tan(x)', 'Tangent'),
                              ('sin(x) + cos(x)', 'Combined trig'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildFunctionCategory(
                            l10n.logarithmicFunctions,
                            [
                              ('log(x)', 'Natural logarithm'),
                              ('log(abs(x))', 'Log of absolute'),
                              ('e^x', 'Exponential'),
                              ('2^x', 'Power of 2'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildFunctionCategory(
                            l10n.advancedFunctions,
                            [
                              ('1/x', 'Hyperbola'),
                              ('sqrt(x)', 'Square root'),
                              ('sin(x)/x', 'Sinc function'),
                              ('x*sin(1/x)', 'Complex oscillation'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFunctionCategory(
      String title, List<(String, String)> functions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: functions.map((func) {
            return _buildFunctionChip(func.$1, func.$2);
          }).toList(),
        ),
      ],
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
                onPressed: _showFunctionInputHelp,
                icon: const Icon(Icons.help_outline),
                tooltip: l10n.functionInputHelp,
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.1),
                  foregroundColor: Theme.of(context).colorScheme.secondary,
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
                              onTap: () => _showColorPicker(function),
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
                                          _showColorPicker(function);
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
                            onTap: () => _showColorPicker(function),
                          ),
                        );
                      },
                    ),

              // Floating save button for mobile
              if (widget.showSaveButton &&
                  MediaQuery.of(context).size.width <= 800 &&
                  widget.functions.isNotEmpty &&
                  widget.onSaveToHistory != null)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: widget.onSaveToHistory,
                    tooltip: l10n.saveCurrentToHistory,
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    foregroundColor: Theme.of(context).colorScheme.onTertiary,
                    child: const Icon(Icons.save),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
