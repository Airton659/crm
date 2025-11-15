import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/lead.dart';
import '../../domain/repositories/lead_repository.dart';

class LeadRepositoryImpl implements LeadRepository {
  final FirebaseFirestore firestore;

  LeadRepositoryImpl({required this.firestore});

  @override
  Future<Either<String, void>> submitLead(Lead lead) async {
    try {
      final now = DateTime.now();
      final weekDays = ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];

      await firestore.collection('leads').add({
        'nome': lead.nome,
        'email': lead.email,
        'telefone': lead.telefone,
        'consumo_kwh': lead.consumoKwh,
        'tipo_telhado': lead.tipoTelhado,
        'tipo_servico': lead.tipoServico,
        'origem': lead.origem.toJson(),
        'status': lead.status,
        'prioridade': 'media',
        'valor_estimado': _calcularValorEstimado(lead.consumoKwh),
        'notas': '',
        'gestor_responsavel_id': null,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'last_contact_at': null,
        'metadata': {
          'device': lead.origem.device,
          'browser': lead.origem.browser,
          'os': lead.origem.os,
        },
        'analytics': {
          ...?lead.analytics?.toJson(),
          'submission_hour': now.hour,
          'submission_day_of_week': now.weekday,
          'submission_day_name': weekDays[now.weekday % 7],
          'submission_date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        },
      });

      // Atualizar estatísticas de origem
      await _atualizarEstatisticasOrigem(lead);

      return const Right(null);
    } catch (e) {
      return Left('Erro ao enviar lead: ${e.toString()}');
    }
  }

  double _calcularValorEstimado(int consumoKwh) {
    // Cálculo aproximado: R$ 100 por kWh de potência instalada
    // Consumo médio / 30 dias / 5 horas de sol = potência necessária
    final potenciaNecessaria = (consumoKwh / 30 / 5) * 1.2; // +20% margem
    return potenciaNecessaria * 100 * 1000; // R$ por kW
  }

  Future<void> _atualizarEstatisticasOrigem(Lead lead) async {
    try {
      final now = DateTime.now();
      final docId = '${now.year}-${now.month.toString().padLeft(2, '0')}-${lead.origem.source}';

      final docRef = firestore.collection('lead_sources').doc(docId);
      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.update({
          'total_leads': FieldValue.increment(1),
          'ultima_atualizacao': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.set({
          'ano': now.year,
          'mes': now.month,
          'source': lead.origem.source,
          'medium': lead.origem.medium,
          'total_leads': 1,
          'total_conversoes': 0,
          'taxa_conversao': 0.0,
          'ultima_atualizacao': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Falha silenciosa em estatísticas não deve impedir o envio do lead
      print('Erro ao atualizar estatísticas: $e');
    }
  }
}
