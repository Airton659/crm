/// Calculadora de investimento para sistemas de energia solar
class InvestmentCalculator {
  /// Tabela de investimento baseado no consumo médio mensal (kWh)
  static const Map<int, int> investmentTable = {
    250: 11500,
    500: 15500,
    800: 19500,
    1000: 25500,
  };

  /// Retorna o investimento total para um determinado consumo
  /// Se o consumo não estiver na tabela, retorna o valor padrão (500 kWh)
  static int getInvestment(int consumption) {
    return investmentTable[consumption] ?? investmentTable[500]!;
  }

  /// Calcula o valor da parcela mensal
  /// [consumption] - Consumo em kWh
  /// [months] - Número de meses (padrão: 36)
  static double getMonthlyPayment(int consumption, {int months = 36}) {
    final investment = getInvestment(consumption);
    return investment / months;
  }

  /// Formata o valor da parcela para exibição (ex: "R$ 319,44")
  static String formatMonthlyPayment(int consumption, {int months = 36}) {
    final payment = getMonthlyPayment(consumption, months: months);
    return 'R\$ ${payment.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Formata o valor total do investimento (ex: "R$ 11.500,00")
  static String formatInvestment(int consumption) {
    final investment = getInvestment(consumption);
    return 'R\$ ${investment.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')},00';
  }

  /// Retorna todos os consumos disponíveis na tabela (ordenados)
  static List<int> getAvailableConsumptions() {
    final consumptions = investmentTable.keys.toList();
    consumptions.sort();
    return consumptions;
  }

  /// Verifica se um consumo específico está disponível na tabela
  static bool isConsumptionAvailable(int consumption) {
    return investmentTable.containsKey(consumption);
  }
}
