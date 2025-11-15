import 'package:flutter/material.dart';

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Soluções Completas para Você',
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
            final cards = _buildServiceCards();

            if (constraints.maxWidth > 900) {
              // Desktop: 3 colunas
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: cards.take(3).map((card) {
                      return Expanded(child: Padding(padding: const EdgeInsets.all(8), child: card));
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...cards.skip(3).map((card) {
                        return Expanded(child: Padding(padding: const EdgeInsets.all(8), child: card));
                      }),
                      const Expanded(child: SizedBox()), // Espaço vazio para alinhar
                    ],
                  ),
                ],
              );
            } else if (constraints.maxWidth > 600) {
              // Tablet: 2 colunas
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: cards.map((card) {
                  return SizedBox(
                    width: (constraints.maxWidth - 16) / 2 - 8,
                    child: card,
                  );
                }).toList(),
              );
            } else {
              // Mobile: 1 coluna
              return Column(
                children: cards.map((card) {
                  return Padding(padding: const EdgeInsets.only(bottom: 16), child: card);
                }).toList(),
              );
            }
          },
        ),
      ],
    );
  }

  List<Widget> _buildServiceCards() {
    return [
      _ServiceCard(
        title: 'COMÉRCIO',
        description:
            'Comprovadamente empresas na Europa e Ásia se tornaram mais competitivas no preço de seus produtos após não se preocuparem mais com a conta de luz.',
        buttonText: 'Solicitar Orçamento',
      ),
      _ServiceCard(
        title: 'ESCOLA',
        description:
            'Escolas conseguem diminuir as despesas mensais e investir em mais qualidade de ensino. Com a verba extra da economia com o sistema de energia solar, escolas podem focar na qualidade do ensino e outros requisitos.',
        buttonText: 'Solicitar Orçamento',
      ),
      _ServiceCard(
        title: 'INDÚSTRIA',
        description:
            'Podemos afirmar que para a indústria gerar sua própria energia através de sistema solar hoje é uma necessidade. O maior vilão na produção industrial nacional é a conta de luz.',
        buttonText: 'Solicitar Orçamento',
      ),
      _ServiceCard(
        title: 'CONDOMÍNIO',
        description:
            'Condomínios comerciais e residenciais são um dos setores responsáveis pelo impulsionamento e aumento da instalação de sistemas solares no Brasil.',
        buttonText: 'Solicitar Orçamento',
      ),
      _ServiceCard(
        title: 'MERCADO LIVRE',
        description:
            'Já pensou em transmitir energia para empresas, comércios e condomínios com desconto e faturando por 25 anos? Este é o melhor investimento da atualidade e o Grupo Solar Brasil é uma das poucas empresas nacionais com esta real experiência.',
        buttonText: 'Saiba Mais',
      ),
    ];
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;

  const _ServiceCard({
    required this.title,
    required this.description,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 280,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                // Scroll para seção de simulação
                Scrollable.ensureVisible(
                  context,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    buttonText,
                    style: const TextStyle(
                      color: Color(0xFFF59E0B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Color(0xFFF59E0B),
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
