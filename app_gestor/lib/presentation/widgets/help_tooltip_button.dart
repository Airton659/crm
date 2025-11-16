import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class HelpTooltipButton extends StatelessWidget {
  final String message;
  final double iconSize;

  const HelpTooltipButton({
    Key? key,
    required this.message,
    this.iconSize = 18,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      preferBelow: false,
      verticalOffset: 20,
      waitDuration: const Duration(milliseconds: 100),
      showDuration: const Duration(seconds: 5),
      child: InkWell(
        onTap: () {
          // Mostrar dialog com a mensagem em dispositivos touch
          _showHelpDialog(context);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.help_outline,
            size: iconSize,
            color: AppTheme.primaryBlue,
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: AppTheme.primaryBlue),
            SizedBox(width: 8),
            Text('Ajuda'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
}
