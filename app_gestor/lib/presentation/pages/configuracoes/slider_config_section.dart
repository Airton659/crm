import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/slider_config.dart';
import '../../../data/repositories/configuracoes_repository.dart';

class SliderConfigSection extends StatefulWidget {
  final String userId;

  const SliderConfigSection({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<SliderConfigSection> createState() => _SliderConfigSectionState();
}

class _SliderConfigSectionState extends State<SliderConfigSection> {
  final _repository = ConfiguracoesRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeConfig();
  }

  Future<void> _initializeConfig() async {
    setState(() => _isLoading = true);
    try {
      await _repository.initializeDefaultConfig(widget.userId);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                const Icon(Icons.tune, color: AppTheme.primaryBlue),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Configuração do Slider de Potência',
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
              'Configure os valores disponíveis no simulador do site',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              StreamBuilder<SliderConfig?>(
                stream: _repository.watchSliderConfig(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final config = snapshot.data;
                  if (config == null || config.valores.isEmpty) {
                    return const Center(
                      child: Text('Nenhuma configuração encontrada'),
                    );
                  }

                  // Ordenar valores por consumo
                  final valores = List<SliderValor>.from(config.valores);
                  valores.sort((a, b) => a.consumoKwh.compareTo(b.consumoKwh));

                  return Column(
                    children: [
                      // Lista de valores
                      ...valores.map((valor) {
                        // Encontrar o índice real no array original (não ordenado)
                        final realIndex = config.valores.indexWhere(
                          (v) => v.consumoKwh == valor.consumoKwh &&
                                 v.investimentoTotal == valor.investimentoTotal &&
                                 v.valorParcela == valor.valorParcela
                        );
                        return _buildValorCard(valor, realIndex);
                      }),

                      const SizedBox(height: 16),

                      // Botão adicionar
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showAddEditDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('Adicionar Novo Valor'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            foregroundColor: AppTheme.primaryBlue,
                            side: const BorderSide(color: AppTheme.primaryBlue),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildValorCard(SliderValor valor, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: valor.ativo ? Colors.white : Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox ativo/inativo
            Checkbox(
              value: valor.ativo,
              onChanged: (bool? value) async {
                await _repository.toggleSliderValorAtivo(index, widget.userId);
              },
              activeColor: AppTheme.successGreen,
            ),
            const SizedBox(width: 12),

            // Informações
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Linha do título com ícones
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              '${valor.consumoKwh} kWh',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (!valor.ativo)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'INATIVO',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Botões de ação
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppTheme.primaryBlue, size: 20),
                        onPressed: () => _showAddEditDialog(valor: valor, index: index),
                        tooltip: 'Editar',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppTheme.dangerRed, size: 20),
                        onPressed: () => _confirmDelete(index),
                        tooltip: 'Remover',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Investimento Total
                  Text(
                    'Investimento Total: R\$ ${_formatCurrency(valor.investimentoTotal)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Parcela
                  Text(
                    'Parcela: R\$ ${_formatCurrency(valor.valorParcela)}/mês',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.successGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Economia Anual
                  Text(
                    'Economia anual: R\$ ${_formatCurrency(valor.economiaAnual)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Payback
                  Text(
                    'Payback: ${valor.paybackAnos.toStringAsFixed(1)} anos',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddEditDialog({SliderValor? valor, int? index}) async {
    final isEdit = valor != null;
    final consumoController = TextEditingController(
      text: valor?.consumoKwh.toString() ?? '',
    );
    final investimentoController = TextEditingController(
      text: valor != null ? _formatCurrency(valor.investimentoTotal) : '',
    );
    final parcelaController = TextEditingController(
      text: valor != null ? _formatCurrency(valor.valorParcela) : '',
    );
    final economiaController = TextEditingController(
      text: valor != null ? _formatCurrency(valor.economiaAnual) : '',
    );
    final paybackController = TextEditingController(
      text: valor?.paybackAnos.toString() ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Editar Valor' : 'Adicionar Novo Valor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Consumo
              TextField(
                controller: consumoController,
                decoration: const InputDecoration(
                  labelText: 'Consumo (kWh)',
                  hintText: 'Ex: 500',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flash_on),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),

              // Investimento Total
              TextField(
                controller: investimentoController,
                decoration: const InputDecoration(
                  labelText: 'Investimento Total (R\$)',
                  hintText: 'Ex: 15.500,00',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
              ),
              const SizedBox(height: 16),

              // Valor da Parcela
              TextField(
                controller: parcelaController,
                decoration: const InputDecoration(
                  labelText: 'Valor da Parcela (R\$/mês)',
                  hintText: 'Ex: 430,56',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                  helperText: 'Defina o valor mensal que será exibido',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
              ),
              const SizedBox(height: 16),

              // Economia Anual
              TextField(
                controller: economiaController,
                decoration: const InputDecoration(
                  labelText: 'Economia Anual Estimada (R\$)',
                  hintText: 'Ex: 6.000,00',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.trending_up),
                  helperText: 'Economia estimada por ano',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
              ),
              const SizedBox(height: 16),

              // Payback
              TextField(
                controller: paybackController,
                decoration: const InputDecoration(
                  labelText: 'Payback (anos)',
                  hintText: 'Ex: 2.6',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.schedule),
                  helperText: 'Tempo de retorno do investimento',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.primaryBlue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Você tem controle total sobre todos os valores. Configure de acordo com suas condições comerciais.',
                        style: TextStyle(fontSize: 12, color: AppTheme.primaryBlue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Validar campos
              final consumo = int.tryParse(consumoController.text);
              final investimento = _parseCurrency(investimentoController.text);
              final parcela = _parseCurrency(parcelaController.text);
              final economia = _parseCurrency(economiaController.text);
              final payback = _parseDecimal(paybackController.text);

              if (consumo == null || consumo <= 0) {
                _showError('Consumo inválido');
                return;
              }
              if (investimento == null || investimento <= 0) {
                _showError('Investimento inválido');
                return;
              }
              if (parcela == null || parcela <= 0) {
                _showError('Parcela inválida');
                return;
              }
              if (parcela > investimento) {
                _showError('Parcela não pode ser maior que investimento total');
                return;
              }
              if (economia == null || economia <= 0) {
                _showError('Economia anual inválida');
                return;
              }
              if (payback == null || payback <= 0) {
                _showError('Payback inválido');
                return;
              }

              final novoValor = SliderValor(
                consumoKwh: consumo,
                investimentoTotal: investimento,
                valorParcela: parcela,
                economiaAnual: economia,
                paybackAnos: payback,
                ativo: valor?.ativo ?? true,
              );

              try {
                if (isEdit && index != null) {
                  await _repository.updateSliderValor(
                    index,
                    novoValor,
                    widget.userId,
                  );
                } else {
                  await _repository.addSliderValor(novoValor, widget.userId);
                }
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              } catch (e) {
                _showError('Erro ao salvar: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: Text(isEdit ? 'Salvar' : 'Adicionar'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit
              ? 'Valor atualizado com sucesso!'
              : 'Valor adicionado com sucesso!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }

  Future<void> _confirmDelete(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Remoção'),
        content: const Text(
          'Tem certeza que deseja remover este valor? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _repository.removeSliderValor(index, widget.userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Valor removido com sucesso!'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      } catch (e) {
        _showError('Erro ao remover: $e');
      }
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

  String _formatCurrency(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    // Adicionar separador de milhar
    final intFormatted = intPart.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );

    return '$intFormatted,$decPart';
  }

  double? _parseCurrency(String value) {
    try {
      // Remover separador de milhar (.) e substituir vírgula (,) por ponto (.)
      final cleaned = value.replaceAll('.', '').replaceAll(',', '.');
      return double.tryParse(cleaned);
    } catch (e) {
      return null;
    }
  }

  double? _parseDecimal(String value) {
    try {
      // Substituir vírgula (,) por ponto (.)
      final cleaned = value.replaceAll(',', '.');
      return double.tryParse(cleaned);
    } catch (e) {
      return null;
    }
  }
}
