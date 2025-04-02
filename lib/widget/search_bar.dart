import 'package:flutter/material.dart';

class AppSearchBar extends StatelessWidget implements PreferredSizeWidget {
  AppSearchBar(
    this.title, {
    super.key,
    this.leading,
    required this.searchTap,
    this.actions,
  });
  @override
  Size get preferredSize => const Size.fromHeight(48.0);

  final Widget? leading;
  final String title;
  Function searchTap;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    print(isDarkMode);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(padding: const EdgeInsets.only(right: 10), child: leading ?? Container()),
        Expanded(
          child: InkWell(
            onTap: () {
              searchTap();
            },
            child: Container(
              height: 36.0,
              decoration: BoxDecoration(
                // color: Colors.red,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isDarkMode ? Colors.white.withValues(alpha: 0.5) : Colors.black, width: 1),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                const SizedBox(width: 8),
                const Icon(Icons.search, size: 16),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12),
                ),
              ]),
            ),
          ),
        ),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: actions ?? []),
      ],
    );
  }
}
