import 'dart:html' as html;

import '../../domain/entities/lead.dart';

/// Classe para rastrear métricas de engajamento do usuário
class AnalyticsTracker {
  static DateTime? _pageLoadTime;
  static DateTime? _formStartTime;
  static double _maxScrollDepth = 0.0;
  static int _formInteractions = 0;
  static final Set<String> _interactedFields = {};

  // Flag para controlar se os listeners já foram registrados
  static bool _listenersRegistered = false;

  /// Inicializa o tracking quando a página carrega
  static void init() {
    print('🔄 INIT CHAMADO - ${DateTime.now()}');

    // LER A FLAG QUE O JAVASCRIPT CONFIGUROU NO INDEX.HTML
    String? mustReset;
    try {
      mustReset = html.window.sessionStorage['analytics_must_reset'];
    } catch (e) {
      print('⚠️ Erro ao ler analytics_must_reset: $e');
    }

    print('🔍 Flag analytics_must_reset: $mustReset');
    print('📊 Estado ANTES do reset - scroll: $_maxScrollDepth%, clicks: $_formInteractions, fields: ${_interactedFields.length}');

    // Se a flag é 'true', resetar TUDO
    if (mustReset == 'true') {
      print('🆕 NOVA NAVEGAÇÃO DETECTADA (flag=true) - Resetando TUDO');

      // RESET TOTAL E INCONDICIONAL
      _pageLoadTime = DateTime.now();
      _formStartTime = null;
      _maxScrollDepth = 0.0;
      _formInteractions = 0;
      _interactedFields.clear();

      // Marcar flag como consumida
      try {
        html.window.sessionStorage['analytics_must_reset'] = 'false';
      } catch (e) {
        print('⚠️ Erro ao atualizar flag: $e');
      }

      print('✅ RESET COMPLETO');
    } else {
      print('♻️ HOT RELOAD (flag=$mustReset) - Mantendo métricas');
    }

    print('📊 Estado DEPOIS do reset - scroll: $_maxScrollDepth%, clicks: $_formInteractions, fields: ${_interactedFields.length}');

    // Registrar listeners apenas uma vez
    if (!_listenersRegistered) {
      print('🎧 Registrando listeners');

      // Rastrear scroll depth
      html.window.onScroll.listen((_) {
        _trackScrollDepth();
      });

      // Rastrear quando usuário sai da página
      html.window.onBeforeUnload.listen((_) {
        _trackPageAbandon();
      });

      _listenersRegistered = true;
      print('✅ Listeners registrados');
    }
  }

  /// Marca quando o usuário começou a interagir com o formulário
  /// Aceita um fieldId opcional para contar apenas um clique por campo
  static void startFormTracking([String? fieldId]) {
    // Marca o início do form tracking
    if (_formStartTime == null) {
      _formStartTime = DateTime.now();
      print('📊 Usuário começou a preencher formulário em: $_formStartTime');
    }

    // Se não passou fieldId, incrementa (comportamento antigo)
    if (fieldId == null) {
      _formInteractions++;
      print('📊 Interação registrada: $_formInteractions total');
      return;
    }

    // Se passou fieldId, só incrementa se for a primeira interação com esse campo
    if (!_interactedFields.contains(fieldId)) {
      _interactedFields.add(fieldId);
      _formInteractions++;
      print('📊 Primeira interação com campo "$fieldId": $_formInteractions total');
    }
  }

  /// Calcula a profundidade de scroll (0-100%)
  /// Fórmula: scrollTop / (documentHeight - windowHeight) * 100
  /// Representa a % que o usuário rolou do conteúdo SCROLLÁVEL
  static void _trackScrollDepth() {
    final scrollTop = html.window.scrollY.toDouble();
    final windowHeight = html.window.innerHeight?.toDouble() ?? 0;
    final documentHeight = (html.document.body?.scrollHeight ??
                           html.document.documentElement?.scrollHeight ?? 0).toDouble();

    if (documentHeight == 0 || windowHeight == 0) return;

    // Altura scrollável = altura total - altura da viewport
    final scrollableHeight = documentHeight - windowHeight;

    // Se não há altura scrollável (página cabe toda na tela), scroll depth = 0
    if (scrollableHeight <= 0) {
      print('📊 Página não é scrollável (cabe toda na tela)');
      return;
    }

    // Scroll depth = posição do scroll / altura scrollável * 100
    final scrollDepth = (scrollTop / scrollableHeight * 100).clamp(0.0, 100.0);

    if (scrollDepth > _maxScrollDepth) {
      _maxScrollDepth = scrollDepth;
      print('📊 Novo max scroll: ${scrollDepth.toStringAsFixed(1)}% (scrollTop: ${scrollTop.toStringAsFixed(0)}px, viewport: ${windowHeight.toStringAsFixed(0)}px, doc: ${documentHeight.toStringAsFixed(0)}px, scrollable: ${scrollableHeight.toStringAsFixed(0)}px)');
    }
  }

  /// Registra quando o usuário abandona a página
  static void _trackPageAbandon() {
    if (_formStartTime != null && _pageLoadTime != null) {
      final timeOnForm = DateTime.now().difference(_formStartTime!).inSeconds;
      print('⚠️ Formulário abandonado após $timeOnForm segundos');
    }
  }

  /// Captura todas as métricas quando o formulário é enviado
  static AnalyticsData captureMetrics() {
    final now = DateTime.now();

    // Tempo total na página (segundos)
    final timeOnPage = _pageLoadTime != null
        ? now.difference(_pageLoadTime!).inSeconds
        : 0;

    // Tempo para preencher o formulário (segundos)
    final timeToFillForm = _formStartTime != null
        ? now.difference(_formStartTime!).inSeconds
        : 0;

    // Scroll depth final
    _trackScrollDepth();

    final analytics = AnalyticsData(
      timeOnPageSeconds: timeOnPage,
      timeToFillFormSeconds: timeToFillForm,
      scrollDepthPercent: _maxScrollDepth.round(),
      formInteractions: _formInteractions,
    );

    print('📊 Métricas capturadas: ${analytics.toJson()}');

    // Resetar DEPOIS de capturar para próxima submissão
    reset();

    return analytics;
  }

  /// Reset das métricas (útil para testes)
  static void reset() {
    _pageLoadTime = null;
    _formStartTime = null;
    _maxScrollDepth = 0.0;
    _formInteractions = 0;
    _interactedFields.clear();
  }
}
