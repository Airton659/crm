import 'dart:html' as html;
import 'dart:convert';

/// Classe para capturar e parsear parâmetros UTM da URL
class UtmParser {
  /// Captura todos os parâmetros UTM da URL atual
  static Map<String, String> captureUtmParameters() {
    final href = html.window.location.href;
    final search = html.window.location.search;

    // Debug logging
    print('🔍 DEBUG UTM - Full URL: $href');
    print('🔍 DEBUG UTM - Query String: $search');

    // Tentar pegar os parâmetros UTM do sessionStorage (salvos pelo index.html)
    final storedUtmJson = html.window.sessionStorage['utm_params'];
    print('🔍 DEBUG UTM - SessionStorage utm_params: $storedUtmJson');

    Map<String, dynamic> params = {};

    if (storedUtmJson != null && storedUtmJson.isNotEmpty) {
      // Parsear o JSON do sessionStorage
      try {
        final jsonData = json.decode(storedUtmJson) as Map<String, dynamic>;
        params = jsonData;
        print('🔍 DEBUG UTM - Parsed from sessionStorage: $params');
      } catch (e) {
        print('⚠️ DEBUG UTM - Error parsing sessionStorage: $e');
        // Fallback para URL
        final uri = Uri.parse(href);
        params = uri.queryParameters;
      }
    } else {
      // Fallback para URL
      final uri = Uri.parse(href);
      params = uri.queryParameters;
      print('🔍 DEBUG UTM - Parsed from URL: $params');
    }

    print('🔍 DEBUG UTM - utm_source: ${params['utm_source']}');
    print('🔍 DEBUG UTM - utm_medium: ${params['utm_medium']}');
    print('🔍 DEBUG UTM - utm_campaign: ${params['utm_campaign']}');

    final referrer = html.document.referrer;
    final uri = Uri.parse(href);

    return {
      'source': (params['utm_source'] as String?) ?? 'direto',
      'medium': (params['utm_medium'] as String?) ?? 'none',
      'campaign': (params['utm_campaign'] as String?) ?? '',
      'content': (params['utm_content'] as String?) ?? '',
      'term': (params['utm_term'] as String?) ?? '',
      'referrer': referrer.isNotEmpty ? referrer : '',
      'landing_page': uri.path,
    };
  }

  /// Captura informações adicionais do dispositivo
  static Map<String, String> captureDeviceInfo() {
    final userAgent = html.window.navigator.userAgent;

    return {
      'user_agent': userAgent,
      'device': _getDeviceType(userAgent),
      'browser': _getBrowser(userAgent),
      'os': _getOS(userAgent),
    };
  }

  static String _getDeviceType(String userAgent) {
    if (userAgent.contains('Mobile') || userAgent.contains('Android')) {
      return 'mobile';
    } else if (userAgent.contains('Tablet') || userAgent.contains('iPad')) {
      return 'tablet';
    }
    return 'desktop';
  }

  static String _getBrowser(String userAgent) {
    if (userAgent.contains('Chrome')) return 'Chrome';
    if (userAgent.contains('Firefox')) return 'Firefox';
    if (userAgent.contains('Safari')) return 'Safari';
    if (userAgent.contains('Edge')) return 'Edge';
    return 'Unknown';
  }

  static String _getOS(String userAgent) {
    if (userAgent.contains('Windows')) return 'Windows';
    if (userAgent.contains('Mac')) return 'MacOS';
    if (userAgent.contains('Linux')) return 'Linux';
    if (userAgent.contains('Android')) return 'Android';
    if (userAgent.contains('iOS') || userAgent.contains('iPhone')) return 'iOS';
    return 'Unknown';
  }

  /// Obtém a origem formatada para exibição
  static String getOrigemDisplay(String source) {
    switch (source.toLowerCase()) {
      case 'google':
        return 'Buscas (Google)';
      case 'instagram':
      case 'ig':
        return 'Instagram';
      case 'facebook':
      case 'fb':
        return 'Facebook';
      case 'indicacao':
      case 'referral':
        return 'Indicação';
      case 'direto':
      case 'direct':
        return 'Acesso Direto';
      default:
        return 'Outros';
    }
  }
}
