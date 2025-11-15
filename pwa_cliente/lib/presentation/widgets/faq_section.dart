import 'package:flutter/material.dart';

class FaqSection extends StatelessWidget {
  const FaqSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Perguntas Frequentes',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _FaqItem(
          question: 'Em quanto tempo tenho o retorno do investimento?',
          answer:
              'O retorno médio do investimento em energia solar é de 4 a 7 anos, dependendo do consumo e da região. Após este período, toda a economia é lucro puro por mais 20 anos.',
        ),
        const SizedBox(height: 16),
        _FaqItem(
          question: 'Como funciona a instalação?',
          answer:
              'Fazemos uma visita técnica gratuita, elaboramos o projeto personalizado, cuidamos de toda a documentação junto à concessionária e realizamos a instalação completa em poucos dias.',
        ),
        const SizedBox(height: 16),
        _FaqItem(
          question: 'Preciso de manutenção nos painéis?',
          answer:
              'A manutenção é mínima. Recomendamos apenas limpeza periódica dos painéis (a chuva já ajuda bastante) e inspeção anual do sistema. Os painéis têm garantia de 25 anos.',
        ),
      ],
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItem({
    required this.question,
    required this.answer,
  });

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF1E3A8A),
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 12),
                Text(
                  widget.answer,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.6,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
