import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// A reusable card widget that replicates the CSS `.ai-gradient-border` effect.
/// Features a dark container with a subtle glowing border animation.
class NeonCard extends StatelessWidget {
  final Widget child;
  final Color? glowColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double glowIntensity;
  final bool enableGlow;

  const NeonCard({
    super.key,
    required this.child,
    this.glowColor,
    this.borderRadius = 16.0,
    this.padding,
    this.margin,
    this.glowIntensity = 0.3,
    this.enableGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGlowColor = glowColor ?? AppColors.neonGreen;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? theme.cardColor;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        // Outer glow effect
        boxShadow: enableGlow
            ? [
                BoxShadow(
                  color:
                      effectiveGlowColor.withValues(alpha: glowIntensity * 0.4),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
                BoxShadow(
                  color:
                      effectiveGlowColor.withValues(alpha: glowIntensity * 0.2),
                  blurRadius: 40,
                  spreadRadius: -10,
                ),
              ]
            : null,
      ),
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: effectiveGlowColor.withValues(alpha: isDark ? 0.2 : 0.5),
            width: 1,
          ),
          // Subtle inner gradient for depth
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.cardSurface,
                    AppColors.surfaceDark,
                  ]
                : [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
          ),
        ),
        child: child,
      ),
    );
  }
}

/// An animated version of NeonCard with pulsing glow effect
class AnimatedNeonCard extends StatefulWidget {
  final Widget child;
  final Color? glowColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Duration animationDuration;

  const AnimatedNeonCard({
    super.key,
    required this.child,
    this.glowColor,
    this.borderRadius = 16.0,
    this.padding,
    this.margin,
    this.animationDuration = const Duration(seconds: 2),
  });

  @override
  State<AnimatedNeonCard> createState() => _AnimatedNeonCardState();
}

class _AnimatedNeonCardState extends State<AnimatedNeonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return NeonCard(
          glowColor: widget.glowColor,
          borderRadius: widget.borderRadius,
          padding: widget.padding,
          margin: widget.margin,
          glowIntensity: _glowAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// A variant of NeonCard for feature/action cards with icon and title
class NeonFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? accentColor;
  final VoidCallback? onTap;
  final bool isLocked;

  const NeonFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.accentColor,
    this.onTap,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = accentColor ?? AppColors.neonGreen;
    final displayColor = isLocked ? Colors.grey : effectiveColor;

    return GestureDetector(
      onTap: onTap,
      child: NeonCard(
        glowColor: displayColor,
        enableGlow: !isLocked,
        glowIntensity: 0.2,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: displayColor.withValues(alpha: isLocked ? 0.1 : 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    icon,
                    color: displayColor.withValues(alpha: isLocked ? 0.5 : 1),
                    size: 24,
                  ),
                  if (isLocked)
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Icon(
                        Icons.lock,
                        color: Colors.grey[600],
                        size: 14,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isLocked ? Colors.grey : AppColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: Colors.grey[isLocked ? 600 : 400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[600],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
