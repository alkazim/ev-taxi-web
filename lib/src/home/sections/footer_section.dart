import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF052014), // Deep forest green footer
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Text(
            'EV TAXI',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Premium taxi services for the God\'s Own Country.',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.white),
              ),
              const SizedBox(width: 20),
              IconButton(
                onPressed: () {},
                icon: const FaIcon(FontAwesomeIcons.instagram, color: Colors.white),
              ),
              const SizedBox(width: 20),
              IconButton(
                onPressed: () {},
                icon: const FaIcon(FontAwesomeIcons.twitter, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            '© 2026 EV Taxi. All rights reserved.',
            style: TextStyle(color: Colors.white24, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
