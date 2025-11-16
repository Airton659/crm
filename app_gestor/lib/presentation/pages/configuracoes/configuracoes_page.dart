import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import 'slider_config_section.dart';
import 'campanhas_section.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({Key? key}) : super(key: key);

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações do Sistema'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.tune),
              text: 'Slider de Potência',
            ),
            Tab(
              icon: Icon(Icons.link),
              text: 'Campanhas',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Aba 1: Slider de Potência
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SliderConfigSection(userId: user?.uid ?? ''),
            ),
          ),

          // Aba 2: Campanhas
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: CampanhasSection(userId: user?.uid ?? ''),
            ),
          ),
        ],
      ),
    );
  }
}
