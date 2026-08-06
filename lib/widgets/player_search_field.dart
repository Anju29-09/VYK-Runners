import 'package:flutter/material.dart';

import '../core/app_colors.dart';

/// Search box for narrowing a list of saved records down to one player.
///
/// The saved sections group every player under their group, so finding one
/// person means expanding groups and scrolling. This filters instead.
class PlayerSearchField extends StatelessWidget {
  final TextEditingController controller;

  final ValueChanged<String> onChanged;

  final String hintText;

  const PlayerSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = "Search player name",
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,

        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.primary,
        ),

        // Only offer the clear button once there is something to clear.
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: AppColors.primary,
                ),
                tooltip: "Clear",
                onPressed: () {
                  controller.clear();
                  onChanged("");
                },
              ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// Placeholder shown when a search matches none of the saved records.
class NoSearchResults extends StatelessWidget {
  final String query;

  const NoSearchResults({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          'No player found for "$query"',
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
