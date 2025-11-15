import 'package:flutter/material.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'O que nossos clientes dizem',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 768) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _TestimonialCard(
                      quote:
                          'O atendimento foi impecável do início ao fim. Minha conta de luz reduziu em 90%!',
                      author: 'Maria S., Cliente Residencial',
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _TestimonialCard(
                      quote:
                          'Investimento com retorno rápido. A equipe do Grupo Solar é muito profissional e qualificada.',
                      author: 'João P., Dono de Padaria',
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  _TestimonialCard(
                    quote:
                        'O atendimento foi impecável do início ao fim. Minha conta de luz reduziu em 90%!',
                    author: 'Maria S., Cliente Residencial',
                  ),
                  const SizedBox(height: 16),
                  _TestimonialCard(
                    quote:
                        'Investimento com retorno rápido. A equipe do Grupo Solar é muito profissional e qualificada.',
                    author: 'João P., Dono de Padaria',
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String quote;
  final String author;

  const _TestimonialCard({
    required this.quote,
    required this.author,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFF59E0B),
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"$quote"',
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF374151),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '— $author',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A8A),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
