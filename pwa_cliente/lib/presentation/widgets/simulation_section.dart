import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:email_validator/email_validator.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../core/utils/analytics_tracker.dart';
import '../../core/utils/investment_calculator.dart';
import '../bloc/lead_form/lead_form_bloc.dart';
import '../bloc/lead_form/lead_form_event.dart';
import '../bloc/lead_form/lead_form_state.dart';

class SimulationSection extends StatefulWidget {
  const SimulationSection({super.key});

  @override
  State<SimulationSection> createState() => _SimulationSectionState();
}

class _SimulationSectionState extends State<SimulationSection> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();

  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  // Slider state
  int _selectedConsumption = 500; // Valor inicial
  bool _showResult = false; // Resultado começa invisível
  int _sliderInteractions = 0; // Contador de mudanças no slider

  // YouTube controller
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    // Inicializar YouTube player com o vídeo do cliente
    _youtubeController = YoutubePlayerController.fromVideoId(
      videoId: 'ekxYqw220rA',
      autoPlay: false,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        mute: false,
        showControls: true,
        loop: false,
        enableCaption: false,
      ),
    );

    // Listeners para atualizar estado do botão em tempo real
    _nomeController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    _telefoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _youtubeController?.close();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Enviar lead com consumo do slider
      context.read<LeadFormBloc>().add(
            SubmitLeadFormEvent(
              nome: _nomeController.text.trim(),
              email: _emailController.text.trim(),
              telefone: _telefoneController.text,
              consumoKwh: _selectedConsumption,
              tipoTelhado: 'nao_informado', // Não coletamos mais
              tipoServico: null, // Não coletamos mais
            ),
          );
    }
  }

  void _handleSliderChange(double value) {
    // Encontrar o valor mais próximo da tabela
    final consumptions = InvestmentCalculator.getAvailableConsumptions();
    int newConsumption = consumptions.first;
    double menorDiferenca = (value - consumptions.first).abs();

    for (final consumption in consumptions) {
      final diferenca = (value - consumption).abs();
      if (diferenca < menorDiferenca) {
        menorDiferenca = diferenca;
        newConsumption = consumption;
      }
    }

    if (newConsumption != _selectedConsumption) {
      setState(() {
        _selectedConsumption = newConsumption;
        if (_showResult) {
          // Só conta interações depois que já enviou o formulário
          _sliderInteractions++;
        }
      });
    }
  }

  bool get _isFormValid {
    final hasName = _nomeController.text.trim().isNotEmpty;
    final hasEmail = _emailController.text.trim().isNotEmpty;
    final hasPhone = _telefoneController.text.trim().isNotEmpty;

    // Válido se tiver nome E (email OU telefone)
    return hasName && (hasEmail || hasPhone);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LeadFormBloc, LeadFormState>(
      listener: (context, state) {
        if (state is LeadFormSuccess) {
          // Mostrar resultado
          setState(() {
            _showResult = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lead enviado com sucesso! Veja sua simulação abaixo.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else if (state is LeadFormError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A8A), // blue-900
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              const Text(
                'Transforme Luz do Sol em Economia',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Preencha seus dados e descubra quanto você pode economizar com energia solar.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),

              // Vídeo Explicativo (Placeholder)
              _buildVideoPlaceholder(),
              const SizedBox(height: 32),

              // Nome
              TextFormField(
                controller: _nomeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Seu nome completo',
                  hintText: 'Ex: João Silva',
                  prefixIcon: Icon(Icons.person, color: Colors.white70),
                ),
                onTap: () => AnalyticsTracker.startFormTracking('nome'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, informe seu nome';
                  }
                  if (value.trim().split(' ').length < 2) {
                    return 'Por favor, informe nome e sobrenome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email e Telefone em linha
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 768) {
                    return Row(
                      children: [
                        Expanded(child: _buildEmailField()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildPhoneField()),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildEmailField(),
                        const SizedBox(height: 16),
                        _buildPhoneField(),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 32),

              // Slider de Consumo (bloqueado inicialmente)
              _buildConsumptionSlider(),
              const SizedBox(height: 24),

              // Botão de Submit
              BlocBuilder<LeadFormBloc, LeadFormState>(
                builder: (context, state) {
                  final isLoading = state is LeadFormSubmitting;

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (isLoading || _showResult || !_isFormValid) ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: const Color(0xFF10B981),
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _showResult ? 'Simulação Realizada ✓' : 'Ver Minha Simulação',
                              style: const TextStyle(fontSize: 18, color: Colors.white),
                            ),
                    ),
                  );
                },
              ),

              // Card de Resultado (aparece após submit)
              if (_showResult) ...[
                const SizedBox(height: 32),
                _buildResultCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlaceholder() {
    if (_youtubeController == null) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24, width: 2),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white54),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: YoutubePlayer(
              controller: _youtubeController!,
              aspectRatio: 16 / 9,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Seu e-mail',
        hintText: 'exemplo@email.com',
        prefixIcon: const Icon(Icons.email, color: Colors.white70),
        helperText: _telefoneController.text.trim().isEmpty ? 'Obrigatório se não preencher telefone' : null,
        helperStyle: const TextStyle(color: Colors.white60, fontSize: 11),
      ),
      onTap: () => AnalyticsTracker.startFormTracking('email'),
      validator: (value) {
        final hasPhone = _telefoneController.text.trim().isNotEmpty;

        // Se tiver telefone, email é opcional
        if (hasPhone) {
          // Se preencheu email, valida formato
          if (value != null && value.isNotEmpty && !EmailValidator.validate(value)) {
            return 'E-mail inválido';
          }
          return null;
        }

        // Se não tiver telefone, email é obrigatório
        if (value == null || value.isEmpty) {
          return 'Informe e-mail ou telefone';
        }
        if (!EmailValidator.validate(value)) {
          return 'E-mail inválido';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _telefoneController,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.phone,
      inputFormatters: [_phoneMask],
      decoration: InputDecoration(
        labelText: 'Seu telefone',
        hintText: '(79) 99999-9999',
        prefixIcon: const Icon(Icons.phone, color: Colors.white70),
        helperText: _emailController.text.trim().isEmpty ? 'Obrigatório se não preencher e-mail' : null,
        helperStyle: const TextStyle(color: Colors.white60, fontSize: 11),
      ),
      onTap: () => AnalyticsTracker.startFormTracking('telefone'),
      validator: (value) {
        final hasEmail = _emailController.text.trim().isNotEmpty;

        // Se tiver email, telefone é opcional
        if (hasEmail) {
          // Se preencheu telefone, valida formato
          if (value != null && value.isNotEmpty && value.length < 15) {
            return 'Telefone incompleto';
          }
          return null;
        }

        // Se não tiver email, telefone é obrigatório
        if (value == null || value.isEmpty) {
          return 'Informe e-mail ou telefone';
        }
        if (value.length < 15) {
          return 'Telefone incompleto';
        }
        return null;
      },
    );
  }

  Widget _buildConsumptionSlider() {
    final consumptions = InvestmentCalculator.getAvailableConsumptions();
    // Usar índice ao invés de valor direto para evitar interpolação
    final currentIndex = consumptions.indexOf(_selectedConsumption);
    final sliderIndex = currentIndex >= 0 ? currentIndex.toDouble() : 1.0;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Consumo Médio Mensal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$_selectedConsumption kWh',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF10B981),
                inactiveTrackColor: Colors.white24,
                thumbColor: const Color(0xFF10B981),
                overlayColor: const Color(0xFF10B981).withOpacity(0.2),
                valueIndicatorColor: const Color(0xFF10B981),
                valueIndicatorTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Slider(
                value: sliderIndex,
                min: 0,
                max: (consumptions.length - 1).toDouble(),
                divisions: consumptions.length - 1,
                label: '$_selectedConsumption kWh',
                onChanged: (index) {
                  final consumption = consumptions[index.round()];
                  _handleSliderChange(consumption.toDouble());
                },
              ),
            ),
            // Labels do slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: consumptions.map((consumption) {
                return Text(
                  '$consumption',
                  style: TextStyle(
                    color: _selectedConsumption == consumption
                        ? const Color(0xFF10B981)
                        : Colors.white54,
                    fontWeight: _selectedConsumption == consumption
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    final monthlyPayment = InvestmentCalculator.getMonthlyPaymentSync(_selectedConsumption);

    return AnimatedOpacity(
      opacity: _showResult ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 32),
                SizedBox(width: 12),
                Text(
                  'Sua Simulação Personalizada',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Consumo
            Row(
              children: [
                const Icon(Icons.bolt, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Consumo: ',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  '$_selectedConsumption kWh/mês',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Parcelas
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Parcelas a partir de:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'R\$ ${monthlyPayment.toStringAsFixed(2).replaceAll('.', ',')} /mês*',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '*Baseado em 36x sem juros',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Economia e Payback
            _buildInfoRow(
              Icons.trending_up,
              'Economia anual estimada:',
              InvestmentCalculator.formatEconomiaAnual(_selectedConsumption),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.schedule,
              'Payback (retorno do investimento):',
              InvestmentCalculator.formatPayback(_selectedConsumption),
            ),

            if (_sliderInteractions > 0) ...[
              const SizedBox(height: 16),
              const Divider(color: Colors.white38),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white60, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Você ajustou o slider $_sliderInteractions ${_sliderInteractions == 1 ? 'vez' : 'vezes'}',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
