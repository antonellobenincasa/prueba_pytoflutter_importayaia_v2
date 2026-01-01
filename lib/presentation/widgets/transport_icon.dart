import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

enum TransportType { air, maritimeFCL, maritimeLCL, land }

class TransportIcon extends StatelessWidget {
  final TransportType type;
  final bool
      isGroundSegment; // If true, overrides type to show truck for last mile
  final Color primaryColor;
  final double size;

  const TransportIcon(
      {super.key,
      required this.type,
      this.isGroundSegment = false,
      this.primaryColor = const Color(0xFFA2F40B),
      this.size = 24});

  @override
  Widget build(BuildContext context) {
    if (isGroundSegment) {
      return _buildGroundIcon();
    }

    switch (type) {
      case TransportType.air:
        return _buildAirIcon();
      case TransportType.maritimeFCL:
        return _buildFCLIcon();
      case TransportType.maritimeLCL:
        return _buildLCLIcon();
      default:
        return _buildGroundIcon();
    }
  }

  Widget _buildWrapper(Widget icon, {bool pulse = false}) {
    Widget child = Container(
      padding: EdgeInsets.all(size * 0.4),
      decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(
              color: primaryColor.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: primaryColor.withValues(alpha: 0.2),
                blurRadius: size * 0.5)
          ]),
      child: icon,
    );

    if (pulse) {
      return Pulse(infinite: true, child: child);
    }
    return child;
  }

  Widget _buildAirIcon() {
    return _buildWrapper(
        Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.flight, color: primaryColor, size: size),
            Positioned(
                top: 0,
                right: 0,
                child: FadeInRight(
                    duration: const Duration(milliseconds: 1500),
                    child: Icon(Icons.air,
                        color: Colors.white.withValues(alpha: 0.5),
                        size: size * 0.5)))
          ],
        ),
        pulse: true);
  }

  Widget _buildFCLIcon() {
    return _buildWrapper(Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: size * 0.2),
          child: Icon(Icons.directions_boat, color: primaryColor, size: size),
        ),
        Positioned(
            top: -size * 0.1,
            child: SlideInDown(
                child: Icon(Icons.calendar_view_day,
                    color: Colors.blueAccent, size: size * 0.6)))
      ],
    ));
  }

  Widget _buildLCLIcon() {
    return _buildWrapper(Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: size * 0.2),
          child: Icon(Icons.directions_boat, color: primaryColor, size: size),
        ),
        Positioned(
            top: -size * 0.1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BounceInDown(
                    delay: const Duration(milliseconds: 100),
                    child: Icon(Icons.inventory_2,
                        color: Colors.orange, size: size * 0.4)),
                BounceInDown(
                    delay: const Duration(milliseconds: 300),
                    child: Icon(Icons.inventory_2,
                        color: Colors.orange, size: size * 0.4)),
              ],
            ))
      ],
    ));
  }

  Widget _buildGroundIcon() {
    return _buildWrapper(Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.local_shipping, color: primaryColor, size: size),
        Positioned(
            bottom: -size * 0.1,
            child: SlideInRight(
                duration: const Duration(milliseconds: 1000),
                child: Container(
                    width: size,
                    height: 2,
                    color: Colors.grey.withValues(alpha: 0.5))))
      ],
    ));
  }
}
