import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: icon == null && !loading
          ? ElevatedButton(
              onPressed: onPressed,
              child: label,
            )
          : ElevatedButton.icon(
              onPressed: loading ? null : onPressed,
              icon: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(icon),
              label: label,
            ),
    );
  }
}
