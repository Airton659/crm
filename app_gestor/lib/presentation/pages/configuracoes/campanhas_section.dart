import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/campaign.dart';
import '../../widgets/help_tooltip_button.dart';

class CampanhasSection extends StatefulWidget {
  final String userId;
  final String baseUrl;

  const CampanhasSection({
    Key? key,
    required this.userId,
    this.baseUrl = 'https://grupo-solar-producao.web.app',
  }) : super(key: key);

  @override
  State<CampanhasSection> createState() => _CampanhasSectionState();
}

class _CampanhasSectionState extends State<CampanhasSection> {
  final _nomeController = TextEditingController();
  final _sourceController = TextEditingController();
  final _mediumController = TextEditingController();
  final _campaignController = TextEditingController();
  final _contentController = TextEditingController();

  String _urlGerada = '';

  @override
  void dispose() {
    _nomeController.dispose();
    _sourceController.dispose();
    _mediumController.dispose();
    _campaignController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _gerarUrl() {
    if (_sourceController.text.isEmpty ||
        _mediumController.text.isEmpty ||
        _campaignController.text.isEmpty) {
      setState(() => _urlGerada = '');
      return;
    }

    final url = Campaign.generateUrl(
      baseUrl: widget.baseUrl,
      source: _sourceController.text.trim(),
      medium: _mediumController.text.trim(),
      campaign: Campaign.sanitizeCampaignName(_campaignController.text.trim()),
      content: _contentController.text.trim().isEmpty
          ? null
          : _contentController.text.trim(),
    );

    setState(() => _urlGerada = url);
  }

  Future<void> _salvarCampanha() async {
    if (_nomeController.text.trim().isEmpty) {
      _showError('Nome da campanha é obrigatório');
      return;
    }
    if (_urlGerada.isEmpty) {
      _showError('Gere a URL antes de salvar');
      return;
    }

    try {
      final campaign = Campaign(
        nome: _nomeController.text.trim(),
        utmSource: _sourceController.text.trim(),
        utmMedium: _mediumController.text.trim(),
        utmCampaign: Campaign.sanitizeCampaignName(_campaignController.text.trim()),
        utmContent: _contentController.text.trim().isEmpty
            ? null
            : _contentController.text.trim(),
        urlCompleta: _urlGerada,
        createdAt: DateTime.now(),
        createdBy: widget.userId,
      );

      await FirebaseFirestore.instance
          .collection('campaigns')
          .add(campaign.toFirestore());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Campanha salva com sucesso!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );

        // Limpar formulário
        _nomeController.clear();
        _sourceController.clear();
        _mediumController.clear();
        _campaignController.clear();
        _contentController.clear();
        setState(() => _urlGerada = '');
      }
    } catch (e) {
      _showError('Erro ao salvar campanha: $e');
    }
  }

  Future<void> _copiarUrl(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link copiado para a área de transferência!'),
          backgroundColor: AppTheme.successGreen,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.dangerRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.link, color: AppTheme.primaryBlue),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Gerador de Links de Campanha',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Crie links rastreáveis para suas campanhas de marketing',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Formulário
            _buildFormulario(),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // Lista de campanhas
            const Text(
              'Campanhas Criadas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildListaCampanhas(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nome da Campanha
        Row(
          children: [
            const Expanded(
              child: Text(
                'Nome da Campanha',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            HelpTooltipButton(
              message: 'Nome interno para identificar esta campanha.\nEx: "Instagram Stories - Black Friday"',
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nomeController,
          decoration: const InputDecoration(
            hintText: 'Ex: Instagram Stories - Black Friday',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.label),
          ),
        ),
        const SizedBox(height: 16),

        // Source
        Row(
          children: [
            const Expanded(
              child: Text(
                'Source (Origem)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            HelpTooltipButton(
              message: 'De onde vem o tráfego.\n\nExemplos:\n• instagram\n• facebook\n• google\n• email\n• whatsapp',
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _sourceController,
          decoration: const InputDecoration(
            hintText: 'Ex: instagram',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.source),
          ),
          onChanged: (_) => _gerarUrl(),
        ),
        const SizedBox(height: 16),

        // Medium
        Row(
          children: [
            const Expanded(
              child: Text(
                'Medium (Meio)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            HelpTooltipButton(
              message: 'Tipo de marketing utilizado.\n\nExemplos:\n• social (redes sociais)\n• cpc (anúncio pago)\n• email (email marketing)\n• referral (indicação)\n• organic (orgânico)',
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _mediumController,
          decoration: const InputDecoration(
            hintText: 'Ex: social',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          onChanged: (_) => _gerarUrl(),
        ),
        const SizedBox(height: 16),

        // Campaign
        Row(
          children: [
            const Expanded(
              child: Text(
                'Campaign (Campanha)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            HelpTooltipButton(
              message: 'Nome específico da campanha.\n\nExemplos:\n• blackfriday2024\n• verao2024\n• lancamento-produto\n\nUse apenas letras minúsculas e hífen.\nEspaços serão convertidos automaticamente.',
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _campaignController,
          decoration: const InputDecoration(
            hintText: 'Ex: blackfriday2024',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.campaign),
          ),
          onChanged: (_) => _gerarUrl(),
        ),
        const SizedBox(height: 16),

        // Content (opcional)
        Row(
          children: [
            const Expanded(
              child: Text(
                'Content (Conteúdo) - Opcional',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            HelpTooltipButton(
              message: 'Variação do anúncio (opcional).\n\nExemplos:\n• post-carrossel\n• stories-dia15\n• banner-topo\n• video-1\n\nÚtil para testar diferentes criativos da mesma campanha.',
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _contentController,
          decoration: const InputDecoration(
            hintText: 'Ex: stories-dia15',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.content_copy),
          ),
          onChanged: (_) => _gerarUrl(),
        ),
        const SizedBox(height: 24),

        // URL Gerada
        if (_urlGerada.isNotEmpty) ...[
          const Text(
            'URL Gerada',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    _urlGerada,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: AppTheme.primaryBlue),
                  onPressed: () => _copiarUrl(_urlGerada),
                  tooltip: 'Copiar',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Botão Salvar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _salvarCampanha,
            icon: const Icon(Icons.save),
            label: const Text('Salvar Campanha'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListaCampanhas() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('campaigns')
          .where('ativo', isEqualTo: true)
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'Nenhuma campanha criada ainda',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        final campanhas = snapshot.data!.docs
            .map((doc) => Campaign.fromFirestore(doc))
            .toList();

        return Column(
          children: campanhas.map((campanha) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Text(
                  campanha.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(
                  campanha.nome,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      '${campanha.utmSource} / ${campanha.utmMedium} / ${campanha.utmCampaign}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      campanha.urlCompleta,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Total de leads
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${campanha.totalLeads} leads',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Botão copiar
                    IconButton(
                      icon: const Icon(Icons.copy, color: AppTheme.primaryBlue),
                      onPressed: () => _copiarUrl(campanha.urlCompleta),
                      tooltip: 'Copiar Link',
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
