import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isModern = context.isModernStyle;
    final isYellow = context.isYellowTheme;
    final yellow = const Color(0xFFF59E0B);
    final green = isModern ? const Color(0xFF16A34A) : AppTheme.primaryColor;
    // Use yellow only when Yellow Theme is active; green for Green V2 theme
    final accent = isYellow ? yellow : green;
    final screenWidth = MediaQuery.of(context).size.width;
    final hPad = screenWidth < 600
        ? 20.0
        : screenWidth < 1024
        ? 40.0
        : 60.0;

    return Container(
      color: const Color(0xFF052014),
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 50),
      child: Column(
        children: [
          // Logo row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.bolt,
                  color: isYellow ? Colors.black87 : Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'E-CABBZ',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Driving the Future of Mobility',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 32),
          // Divider
          Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
          const SizedBox(height: 24),
          // Social icons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialIcon(
                icon: Icons.facebook,
                isYellow: isYellow,
                accent: accent,
              ),
              const SizedBox(width: 16),
              _SocialIcon(
                icon: Icons.telegram,
                isYellow: isYellow,
                accent: accent,
              ),
              const SizedBox(width: 16),
              _SocialIcon(
                icon: Icons.mail_outline,
                isYellow: isYellow,
                accent: accent,
              ),
              const SizedBox(width: 16),
              _SocialIcon(
                icon: Icons.phone_outlined,
                isYellow: isYellow,
                accent: accent,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '© 2025 E-CABBZ PRIVATE LIMITED. All rights reserved.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatefulWidget {
  final IconData icon;
  final bool isYellow;
  final Color accent;

  const _SocialIcon({
    required this.icon,
    required this.isYellow,
    required this.accent,
  });

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _hovered
              ? widget.accent
              : Colors.white.withValues(alpha: 0.08),
          border: Border.all(
            color: _hovered
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Icon(
          widget.icon,
          color: _hovered
              ? (widget.isYellow ? Colors.black87 : Colors.white)
              : Colors.white.withValues(alpha: 0.5),
          size: 20,
        ),
      ),
    );
  }
}
