import 'package:flutter/material.dart';

/// Back arrow for screens built without an AppBar.
///
/// Desktop and web have no swipe-back gesture, so these screens need a
/// visible way to return. Renders nothing when there is no route to pop.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Navigator.canPop(context)) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: () => Navigator.maybePop(context),
        icon: const Icon(Icons.arrow_back),
        color: const Color(0xff312C51),
        tooltip: "Back",
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
      ),
    );
  }
}
