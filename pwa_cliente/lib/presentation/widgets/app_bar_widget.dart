import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 100,
      backgroundColor: Colors.white,
      elevation: 2,
      title: Container(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Image.asset(
                'assets/icons/logo.png',
                height: 70,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 70,
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      'GRUPO SOLAR',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Navegação (opcional para futuras expansões)
          ],
        ),
      ),
    );
  }
}
