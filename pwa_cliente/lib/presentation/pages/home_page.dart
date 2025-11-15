import 'package:flutter/material.dart';

import '../widgets/app_bar_widget.dart';
import '../widgets/simulation_section.dart';
import '../widgets/services_section.dart';
import '../widgets/testimonials_section.dart';
import '../widgets/faq_section.dart';
import '../widgets/contact_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Analytics já foi inicializado no main.dart
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1280),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Column(
              children: [
                SizedBox(height: 32),
                SimulationSection(),
                SizedBox(height: 48),
                ServicesSection(),
                SizedBox(height: 48),
                TestimonialsSection(),
                SizedBox(height: 48),
                FaqSection(),
                SizedBox(height: 48),
                ContactSection(),
                SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
