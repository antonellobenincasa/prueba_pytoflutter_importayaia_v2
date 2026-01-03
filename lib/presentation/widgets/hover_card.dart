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
              color: const Color(0xFF0A101D),
              borderRadius: borderRadius,
              border: Border.all(
                color: _isHovered && !widget.isLocked
                    ? widget.glowColor
                    : (widget.isLocked
                        ? Colors.grey.withValues(alpha: 0.2)
                        : widget.glowColor.withValues(alpha: 0.3)),
                width: _isHovered && !widget.isLocked ? 2 : 1,
              ),
              boxShadow: _isHovered && !widget.isLocked
                  ? [
                      BoxShadow(
                        color: widget.glowColor.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
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
                ? widget.color.withValues(alpha: 0.1)
                : const Color(0xFF0A101D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered && !widget.isLocked
                  ? widget.color
                  : (widget.isLocked
                      ? Colors.grey.withValues(alpha: 0.2)
                      : widget.color.withValues(alpha: 0.3)),
              width: _isHovered && !widget.isLocked ? 2 : 1,
            ),
            boxShadow: _isHovered && !widget.isLocked
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
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
                        color: widget.isLocked ? Colors.grey : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        color: Colors.grey[widget.isLocked ? 600 : 400],
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
                      : Colors.grey[600],
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
