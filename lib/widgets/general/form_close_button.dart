import "package:flow/l10n/extensions.dart";
import "package:flow/utils/utils.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

/// A simple [IconButton] that pops the current route if [canPop] is true.
///
/// If `canPop()` evaluates to `false`, a confirmation dialog will be shown,
/// in which the user can choose to discard the unsaved changes.
class FormCloseButton extends StatelessWidget {
  final bool Function() canPop;

  const FormCloseButton({super.key, required this.canPop});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => onPressed(context),
      icon: const Icon(Symbols.close_rounded),
    );
  }

  void onPressed(BuildContext context) async {
    if (canPop()) {
      context.pop();
      return;
    }

    final bool? confirmPop = await context.showConfirmDialog(
      title: "general.delete.unsavedProgress".t(context),
      child: Text("general.delete.unsavedProgress.description".t(context)),
    );

    if (confirmPop != true) return;

    if (context.mounted) {
      _pop(context);
    }
  }

  static _pop(BuildContext context) {
    context.pop();
  }
}
