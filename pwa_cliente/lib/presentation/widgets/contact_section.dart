import 'package:flutter/material.dart';
import 'dart:html' as html;

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  void _openWhatsApp() {
    const phone = '5579999998888'; // Formato: código país + DDD + número
    const message = 'Olá! Gostaria de mais informações sobre energia solar.';
    final url = 'https://wa.me/$phone?text=${Uri.encodeComponent(message)}';
    html.window.open(url, '_blank');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            const Text(
              'Fale Conosco',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Pronto para começar a economizar? Entre em contato com nossos especialistas.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 32,
              runSpacing: 16,
              children: const [
                _ContactInfo(
                  icon: Icons.email_outlined,
                  text: 'contato@gruposolar.com',
                ),
                _ContactInfo(
                  icon: Icons.phone_outlined,
                  text: '(79) 99999-8888',
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _openWhatsApp,
              icon: const Icon(Icons.phone, size: 20),
              label: const Text('Entrar em Contato por WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactInfo({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: const Color(0xFF1E3A8A),
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
      ],
    );
  }
}
