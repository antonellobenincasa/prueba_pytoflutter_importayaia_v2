import 'package:flutter/material.dart';

/// A card widget that glows and scales on hover (for web/desktop)
class HoverCard extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final VoidCallback? onTap;
  final bool isLocked;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;

  const HoverCard({
    super.key,
    required this.child,
    this.glowColor = Colors.cyan,
    this.onTap,
    this.isLocked = false,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(16);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dynamic colors based on theme
    final bgColor = isDark
        ? const Color(0xFF0A101D)
        : Colors.white; // White card in light mode

    final borderColorLocked = isDark
        ? Colors.grey.withAlpha(51) // ~0.2
        : Colors.grey.withAlpha(76); // ~0.3

    final borderColorDefault = isDark
        ? widget.glowColor.withAlpha(76) // ~0.3
        : widget.glowColor.withAlpha(128); // ~0.5 for better visibility

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.isLocked
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: _isHovered && !widget.isLocked
              ? (Matrix4.identity()
                ..setEntry(0, 0, 1.03)
                ..setEntry(1, 1, 1.03)
                ..setEntry(2, 2, 1.03))
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: widget.padding,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: borderRadius,
              border: Border.all(
                color: _isHovered && !widget.isLocked
                    ? widget.glowColor
                    : (widget.isLocked
                        ? borderColorLocked
                        : borderColorDefault),
                width: _isHovered && !widget.isLocked ? 2 : 1,
              ),
              boxShadow: _isHovered && !widget.isLocked
                  ? [
                      BoxShadow(
                        color: widget.glowColor.withAlpha(102), // ~0.4
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : [
                      // Subtle shadow for light mode cards to lift them off white bg
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withAlpha(13), // ~0.05
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                    ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// A feature list item with hover effect
class HoverListTile extends StatefulWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  final bool isLocked;

  const HoverListTile({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.color = Colors.cyan,
    this.onTap,
    this.isLocked = false,
  });

  @override
  State<HoverListTile> createState() => _HoverListTileState();
}

class _HoverListTileState extends State<HoverListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dynamic colors
    final bgColor = isDark ? const Color(0xFF0A101D) : Colors.white;
    final titleColor = widget.isLocked
        ? Colors.grey
        : (isDark ? Colors.white : Colors.black87);

    final subtitleColor = isDark
        ? Colors.grey[widget.isLocked ? 600 : 400]
        : Colors.grey[widget.isLocked ? 600 : 600];

    final arrowColorDefault = isDark ? Colors.grey[600] : Colors.grey[400];

    // Border logic
    final borderColorLocked =
        isDark ? Colors.grey.withAlpha(51) : Colors.grey.withAlpha(76);

    final borderColorDefault =
        isDark ? widget.color.withAlpha(76) : widget.color.withAlpha(128);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.isLocked
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHovered && !widget.isLocked
                ? widget.color.withAlpha(25) // ~0.1
                : bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered && !widget.isLocked
                  ? widget.color
                  : (widget.isLocked ? borderColorLocked : borderColorDefault),
              width: _isHovered && !widget.isLocked ? 2 : 1,
            ),
            boxShadow: _isHovered && !widget.isLocked
                ? [
                    BoxShadow(
                      color: widget.color.withAlpha(76), // ~0.3
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                  ]
                : [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                  ],
          ),
          child: Row(
            children: [
              widget.leading,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: _isHovered && !widget.isLocked
                      ? widget.color
                      : arrowColorDefault,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
