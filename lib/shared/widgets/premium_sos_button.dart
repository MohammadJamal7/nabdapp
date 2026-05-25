import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumSosButton extends StatefulWidget {
  final VoidCallback onPressed;
  final double size;

  const PremiumSosButton({
    super.key,
    required this.onPressed,
    this.size = 96,
  });

  @override
  State<PremiumSosButton> createState() => _PremiumSosButtonState();
}

class _PremiumSosButtonState extends State<PremiumSosButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) {
        final value = _pulseController.value;
        final scale = 1.0 + (value * 0.06);
        final glowOpacity = 0.3 - (value * 0.2);

        return GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.danger.withAlpha((glowOpacity * 255).round()),
                  blurRadius: 24 + value * 16,
                  spreadRadius: 4 + value * 8,
                ),
              ],
            ),
            child: Transform.scale(
              scale: scale,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.sosGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.danger.withAlpha(120),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SOS',
                      style: TextStyle(
                        fontSize: widget.size * 0.24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                    ),
                    Text(
                      'طوارئ',
                      style: TextStyle(
                        fontSize: widget.size * 0.12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
