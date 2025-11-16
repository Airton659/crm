import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/slider_config.dart';

class ConfiguracoesRepository {
  final FirebaseFirestore _firestore;

  ConfiguracoesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Referência para o documento de configuração do slider
  DocumentReference get _sliderConfigDoc =>
      _firestore.collection('configurations').doc('slider_potencia');

  // Buscar configuração do slider
  Future<SliderConfig?> getSliderConfig() async {
    try {
      final doc = await _sliderConfigDoc.get();
      if (!doc.exists) {
        return null;
      }
      return SliderConfig.fromFirestore(doc);
    } catch (e) {
      print('Erro ao buscar configuração do slider: $e');
      return null;
    }
  }

  // Stream da configuração do slider (realtime)
  Stream<SliderConfig?> watchSliderConfig() {
    return _sliderConfigDoc.snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return SliderConfig.fromFirestore(doc);
    });
  }

  // Salvar configuração do slider
  Future<void> saveSliderConfig(SliderConfig config, String userId) async {
    try {
      await _sliderConfigDoc.set(config.toFirestore(userId));
    } catch (e) {
      print('Erro ao salvar configuração do slider: $e');
      rethrow;
    }
  }

  // Adicionar um novo valor ao slider
  Future<void> addSliderValor(SliderValor valor, String userId) async {
    try {
      final config = await getSliderConfig();
      if (config == null) {
        // Criar nova configuração
        await saveSliderConfig(
          SliderConfig(valores: [valor]),
          userId,
        );
      } else {
        // Adicionar ao array existente
        final novosValores = [...config.valores, valor];
        await saveSliderConfig(
          config.copyWith(valores: novosValores),
          userId,
        );
      }
    } catch (e) {
      print('Erro ao adicionar valor ao slider: $e');
      rethrow;
    }
  }

  // Atualizar um valor específico do slider
  Future<void> updateSliderValor(
    int index,
    SliderValor novoValor,
    String userId,
  ) async {
    try {
      final config = await getSliderConfig();
      if (config == null) {
        throw Exception('Configuração não encontrada');
      }

      final novosValores = List<SliderValor>.from(config.valores);
      novosValores[index] = novoValor;

      await saveSliderConfig(
        config.copyWith(valores: novosValores),
        userId,
      );
    } catch (e) {
      print('Erro ao atualizar valor do slider: $e');
      rethrow;
    }
  }

  // Remover um valor do slider
  Future<void> removeSliderValor(int index, String userId) async {
    try {
      final config = await getSliderConfig();
      if (config == null) {
        throw Exception('Configuração não encontrada');
      }

      final novosValores = List<SliderValor>.from(config.valores);
      novosValores.removeAt(index);

      await saveSliderConfig(
        config.copyWith(valores: novosValores),
        userId,
      );
    } catch (e) {
      print('Erro ao remover valor do slider: $e');
      rethrow;
    }
  }

  // Alternar status ativo/inativo de um valor
  Future<void> toggleSliderValorAtivo(
    int index,
    String userId,
  ) async {
    try {
      final config = await getSliderConfig();
      if (config == null) {
        throw Exception('Configuração não encontrada');
      }

      final novosValores = List<SliderValor>.from(config.valores);
      final valor = novosValores[index];
      novosValores[index] = valor.copyWith(ativo: !valor.ativo);

      await saveSliderConfig(
        config.copyWith(valores: novosValores),
        userId,
      );
    } catch (e) {
      print('Erro ao alternar status do valor: $e');
      rethrow;
    }
  }

  // Inicializar configuração com valores padrão
  Future<void> initializeDefaultConfig(String userId) async {
    try {
      final config = await getSliderConfig();
      if (config != null) {
        return; // Já existe configuração
      }

      // Valores padrão atuais do sistema
      final valoresPadrao = [
        SliderValor(
          consumoKwh: 250,
          investimentoTotal: 11500,
          valorParcela: 319.44, // 11500 / 36
          economiaAnual: 3000.00,
          paybackAnos: 3.8,
          ativo: true,
        ),
        SliderValor(
          consumoKwh: 500,
          investimentoTotal: 15500,
          valorParcela: 430.56, // 15500 / 36
          economiaAnual: 6000.00,
          paybackAnos: 2.6,
          ativo: true,
        ),
        SliderValor(
          consumoKwh: 800,
          investimentoTotal: 19500,
          valorParcela: 541.67, // 19500 / 36
          economiaAnual: 9600.00,
          paybackAnos: 2.0,
          ativo: true,
        ),
        SliderValor(
          consumoKwh: 1000,
          investimentoTotal: 25500,
          valorParcela: 708.33, // 25500 / 36
          economiaAnual: 12000.00,
          paybackAnos: 2.1,
          ativo: true,
        ),
      ];

      await saveSliderConfig(
        SliderConfig(valores: valoresPadrao),
        userId,
      );
    } catch (e) {
      print('Erro ao inicializar configuração padrão: $e');
      rethrow;
    }
  }
}
