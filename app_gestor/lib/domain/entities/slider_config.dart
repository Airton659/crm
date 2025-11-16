import 'package:cloud_firestore/cloud_firestore.dart';

class SliderValor {
  final String? id;
  final int consumoKwh;
  final double investimentoTotal;
  final double valorParcela;
  final double economiaAnual;
  final double paybackAnos;
  final bool ativo;

  SliderValor({
    this.id,
    required this.consumoKwh,
    required this.investimentoTotal,
    required this.valorParcela,
    required this.economiaAnual,
    required this.paybackAnos,
    this.ativo = true,
  });

  factory SliderValor.fromJson(Map<String, dynamic> json, {String? id}) {
    return SliderValor(
      id: id,
      consumoKwh: json['consumo_kwh'] as int,
      investimentoTotal: (json['investimento_total'] as num).toDouble(),
      valorParcela: (json['valor_parcela'] as num).toDouble(),
      economiaAnual: (json['economia_anual'] as num?)?.toDouble() ?? 0.0,
      paybackAnos: (json['payback_anos'] as num?)?.toDouble() ?? 0.0,
      ativo: json['ativo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'consumo_kwh': consumoKwh,
      'investimento_total': investimentoTotal,
      'valor_parcela': valorParcela,
      'economia_anual': economiaAnual,
      'payback_anos': paybackAnos,
      'ativo': ativo,
    };
  }

  SliderValor copyWith({
    String? id,
    int? consumoKwh,
    double? investimentoTotal,
    double? valorParcela,
    double? economiaAnual,
    double? paybackAnos,
    bool? ativo,
  }) {
    return SliderValor(
      id: id ?? this.id,
      consumoKwh: consumoKwh ?? this.consumoKwh,
      investimentoTotal: investimentoTotal ?? this.investimentoTotal,
      valorParcela: valorParcela ?? this.valorParcela,
      economiaAnual: economiaAnual ?? this.economiaAnual,
      paybackAnos: paybackAnos ?? this.paybackAnos,
      ativo: ativo ?? this.ativo,
    );
  }
}

class SliderConfig {
  final List<SliderValor> valores;
  final DateTime? updatedAt;
  final String? updatedBy;

  SliderConfig({
    required this.valores,
    this.updatedAt,
    this.updatedBy,
  });

  factory SliderConfig.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final valoresJson = data['valores'] as List<dynamic>? ?? [];

    return SliderConfig(
      valores: valoresJson
          .map((v) => SliderValor.fromJson(v as Map<String, dynamic>))
          .toList(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate(),
      updatedBy: data['updated_by'] as String?,
    );
  }

  Map<String, dynamic> toFirestore(String userId) {
    return {
      'valores': valores.map((v) => v.toJson()).toList(),
      'updated_at': FieldValue.serverTimestamp(),
      'updated_by': userId,
    };
  }

  SliderConfig copyWith({
    List<SliderValor>? valores,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return SliderConfig(
      valores: valores ?? this.valores,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  // Helper para obter valores ativos ordenados por consumo
  List<SliderValor> get valoresAtivos {
    final ativos = valores.where((v) => v.ativo).toList();
    ativos.sort((a, b) => a.consumoKwh.compareTo(b.consumoKwh));
    return ativos;
  }
}
