import 'package:cloud_firestore/cloud_firestore.dart';

/// Calculadora de investimento para sistemas de energia solar
/// Busca valores configurados no Firebase
class InvestmentCalculator {
  // Cache dos valores carregados do Firebase
  static Map<int, _ValorConfig>? _cachedTable;
  static DateTime? _lastUpdate;
  static const _cacheDuration = Duration(minutes: 1);

  /// Valores padrão (fallback caso Firebase falhe)
  static const Map<int, int> _defaultInvestmentTable = {
    250: 11500,
    500: 15500,
    800: 19500,
    1000: 25500,
  };

  /// Carrega configurações do Firebase
  static Future<void> loadConfiguration() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('configurations')
          .doc('slider_potencia')
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final valores = data['valores'] as List<dynamic>? ?? [];

        _cachedTable = {};
        for (var v in valores) {
          if (v['ativo'] == true) {
            final consumo = v['consumo_kwh'] as int;
            _cachedTable![consumo] = _ValorConfig(
              investimentoTotal: (v['investimento_total'] as num).toDouble(),
              valorParcela: (v['valor_parcela'] as num).toDouble(),
              economiaAnual: (v['economia_anual'] as num?)?.toDouble() ?? 0.0,
              paybackAnos: (v['payback_anos'] as num?)?.toDouble() ?? 0.0,
            );
          }
        }
        _lastUpdate = DateTime.now();
      }
    } catch (e) {
      print('Erro ao carregar configuração do slider: $e');
      // Manter valores em cache ou usar defaults
    }
  }

  /// Verifica se o cache precisa ser atualizado
  static bool _needsRefresh() {
    if (_cachedTable == null || _lastUpdate == null) return true;
    return DateTime.now().difference(_lastUpdate!) > _cacheDuration;
  }

  /// Garante que as configurações estão carregadas
  static Future<void> _ensureLoaded() async {
    if (_needsRefresh()) {
      await loadConfiguration();
    }
  }

  /// Retorna o investimento total para um determinado consumo
  static Future<double> getInvestment(int consumption) async {
    await _ensureLoaded();

    // Tentar pegar do cache
    if (_cachedTable != null && _cachedTable!.containsKey(consumption)) {
      return _cachedTable![consumption]!.investimentoTotal;
    }

    // Fallback para valor padrão
    return (_defaultInvestmentTable[consumption] ?? _defaultInvestmentTable[500]!).toDouble();
  }

  /// Retorna o investimento total de forma síncrona (usa cache)
  static double getInvestmentSync(int consumption) {
    // Usar cache se disponível
    if (_cachedTable != null && _cachedTable!.containsKey(consumption)) {
      return _cachedTable![consumption]!.investimentoTotal;
    }

    // Fallback para valor padrão
    return (_defaultInvestmentTable[consumption] ?? _defaultInvestmentTable[500]!).toDouble();
  }

  /// Calcula o valor da parcela mensal
  /// Agora retorna o valor configurado pelo gestor, não mais calculado
  static Future<double> getMonthlyPayment(int consumption) async {
    await _ensureLoaded();

    // Tentar pegar do cache
    if (_cachedTable != null && _cachedTable!.containsKey(consumption)) {
      return _cachedTable![consumption]!.valorParcela;
    }

    // Fallback: calcular com 36 parcelas
    final investment = _defaultInvestmentTable[consumption] ?? _defaultInvestmentTable[500]!;
    return investment / 36;
  }

  /// Retorna o valor da parcela de forma síncrona (usa cache)
  static double getMonthlyPaymentSync(int consumption) {
    // Usar cache se disponível
    if (_cachedTable != null && _cachedTable!.containsKey(consumption)) {
      return _cachedTable![consumption]!.valorParcela;
    }

    // Fallback: calcular com 36 parcelas
    final investment = _defaultInvestmentTable[consumption] ?? _defaultInvestmentTable[500]!;
    return investment / 36;
  }

  /// Formata o valor da parcela para exibição (ex: "R$ 319,44")
  static String formatMonthlyPayment(int consumption) {
    final payment = getMonthlyPaymentSync(consumption);
    return 'R\$ ${payment.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Formata o valor total do investimento (ex: "R$ 11.500,00")
  static String formatInvestment(int consumption) {
    final investment = getInvestmentSync(consumption);
    return 'R\$ ${investment.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    ).replaceAll('.', ',').replaceFirst(',', '.')}';
  }

  /// Retorna todos os consumos disponíveis (ordenados)
  static List<int> getAvailableConsumptions() {
    // Usar cache se disponível
    if (_cachedTable != null && _cachedTable!.isNotEmpty) {
      final consumptions = _cachedTable!.keys.toList();
      consumptions.sort();
      return consumptions;
    }

    // Fallback para valores padrão
    final consumptions = _defaultInvestmentTable.keys.toList();
    consumptions.sort();
    return consumptions;
  }

  /// Verifica se um consumo específico está disponível
  static bool isConsumptionAvailable(int consumption) {
    // Usar cache se disponível
    if (_cachedTable != null) {
      return _cachedTable!.containsKey(consumption);
    }

    // Fallback para valores padrão
    return _defaultInvestmentTable.containsKey(consumption);
  }

  /// Retorna a economia anual estimada
  static double getEconomiaAnual(int consumption) {
    if (_cachedTable != null && _cachedTable!.containsKey(consumption)) {
      return _cachedTable![consumption]!.economiaAnual;
    }
    return 0.0;
  }

  /// Retorna o payback em anos
  static double getPaybackAnos(int consumption) {
    if (_cachedTable != null && _cachedTable!.containsKey(consumption)) {
      return _cachedTable![consumption]!.paybackAnos;
    }
    return 0.0;
  }

  /// Formata a economia anual para exibição (ex: "R$ 6.000,00")
  static String formatEconomiaAnual(int consumption) {
    final economia = getEconomiaAnual(consumption);
    if (economia == 0) return 'Em breve';
    return 'R\$ ${economia.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    ).replaceAll('.', ',').replaceFirst(',', '.')}';
  }

  /// Formata o payback para exibição (ex: "2,6 anos")
  static String formatPayback(int consumption) {
    final payback = getPaybackAnos(consumption);
    if (payback == 0) return 'Em breve';
    return '${payback.toStringAsFixed(1).replaceAll('.', ',')} anos';
  }
}

/// Classe auxiliar para armazenar config
class _ValorConfig {
  final double investimentoTotal;
  final double valorParcela;
  final double economiaAnual;
  final double paybackAnos;

  _ValorConfig({
    required this.investimentoTotal,
    required this.valorParcela,
    required this.economiaAnual,
    required this.paybackAnos,
  });
}
