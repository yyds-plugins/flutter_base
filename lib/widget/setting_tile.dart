import 'package:flutter/material.dart';

class SettingTile extends StatelessWidget {
  final Icon? icon;

  final String title;
  final String? subtitle;

  final TextStyle? style;
  final String arrowText;
  final bool? value;
  final bool isLoad;
  final void Function(bool)? onChanged;
  final void Function()? onTap;

  const SettingTile({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.style,
    this.arrowText = '',
    this.value,
    this.isLoad = false,
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    var text = arrowText.isNotEmpty
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              isLoad
                  ? const SizedBox(
                      width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 3))
                  : Text(arrowText,
                      textAlign: TextAlign.right, style: const TextStyle(fontSize: 14)),
              const Icon(Icons.arrow_forward_ios, size: 16)
            ],
          )
        : const Icon(Icons.arrow_forward_ios, size: 16);

    var trailing = value != null ? Switch(value: value!, onChanged: onChanged) : text;

    return ListTile(
      leading: icon,
      contentPadding: const EdgeInsets.only(left: 16, right: 8),
      title: Text(title, style: style),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
