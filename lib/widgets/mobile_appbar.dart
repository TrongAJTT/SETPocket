import 'package:flutter/material.dart';
import 'package:setpocket/controllers/mobile_appbar_controller.dart';

/// AppBar đơn giản cho mobile, sync với controller
class MobileAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? fallbackTitle;
  final List<Widget>? fallbackActions;
  final VoidCallback? onBackPressed;

  const MobileAppBar({
    super.key,
    this.fallbackTitle,
    this.fallbackActions,
    this.onBackPressed,
  });

  @override
  State<MobileAppBar> createState() => _MobileAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MobileAppBarState extends State<MobileAppBar> {
  final controller = MobileAppBarController();

  @override
  void initState() {
    super.initState();
    controller.addListener(_onAppBarChanged);
  }

  @override
  void dispose() {
    controller.removeListener(_onAppBarChanged);
    super.dispose();
  }

  void _onAppBarChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = controller.title.isNotEmpty
        ? controller.title
        : (widget.fallbackTitle ?? '');

    // [Cautions] Using this code block will place the fallback actions EVERYWHERE actions are not specified
    // final actions = controller.actions.isNotEmpty
    //     ? controller.actions
    //     : (widget.fallbackActions ?? []);;

    final actions = controller.actions;

    // Chỉ hiện back button khi controller yêu cầu
    final showBackButton = controller.showBackButton;

    return AppBar(
      title: showBackButton
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 4), // Khoảng cách nhỏ sau back button
                Flexible(child: Text(title)),
              ],
            )
          : Text(title),
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: widget.onBackPressed,
            )
          : null,
      automaticallyImplyLeading: false, // Tắt auto leading
      titleSpacing:
          showBackButton ? 0 : null, // Giảm spacing khi có back button
      actions: actions,
    );
  }
}
