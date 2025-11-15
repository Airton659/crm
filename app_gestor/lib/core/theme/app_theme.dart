import 'package:flutter/material.dart';

class AppTheme {
  // Cores do Grupo Solar
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color secondaryYellow = Color(0xFFF59E0B);
  static const Color accentYellow = Color(0xFFFBBF24);
  static const Color backgroundGray = Color(0xFFF3F4F6);
  static const Color successGreen = Color(0xFF10B981);
  static const Color dangerRed = Color(0xFFEF4444);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: secondaryYellow,
        surface: Colors.white,
        background: backgroundGray,
      ),
      scaffoldBackgroundColor: backgroundGray,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: secondaryYellow,
        foregroundColor: primaryBlue,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: backgroundGray,
        labelStyle: const TextStyle(fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Status colors
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'novo':
        return const Color(0xFFFBBF24); // Yellow
      case 'orcamento_enviado':
        return const Color(0xFF3B82F6); // Blue
      case 'em_contato':
        return const Color(0xFF9CA3AF); // Gray
      case 'negociacao':
        return const Color(0xFF8B5CF6); // Purple
      case 'fechado':
        return const Color(0xFF10B981); // Green
      case 'perdido':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Default gray
    }
  }

  // Status display names
  static String getStatusDisplay(String status) {
    switch (status.toLowerCase()) {
      case 'novo':
        return 'Novo';
      case 'orcamento_enviado':
        return 'Orçamento Enviado';
      case 'em_contato':
        return 'Em Contato';
      case 'negociacao':
        return 'Negociação';
      case 'fechado':
        return 'Fechado';
      case 'perdido':
        return 'Perdido';
      default:
        return status;
    }
  }

  // Qualificação colors
  static Color getQualificacaoColor(String qualificacao) {
    switch (qualificacao.toLowerCase()) {
      case 'frio':
        return const Color(0xFF3B82F6); // Azul
      case 'morno':
        return const Color(0xFFFBBF24); // Amarelo
      case 'quente':
        return const Color(0xFFEF4444); // Vermelho
      default:
        return const Color(0xFFFBBF24); // Default: Morno
    }
  }

  // Qualificação display names
  static String getQualificacaoDisplay(String qualificacao) {
    switch (qualificacao.toLowerCase()) {
      case 'frio':
        return 'Frio 🔵';
      case 'morno':
        return 'Morno 🟡';
      case 'quente':
        return 'Quente 🔴';
      default:
        return 'Morno 🟡';
    }
  }
}
