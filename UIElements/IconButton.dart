import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class LiquidGlassIconButton extends StatefulWidget {
  double radius;
  Icon icon;
  Function func;
  bool inLayer;
  LiquidGlassSettings? liquidGlassSettings;

  LiquidGlassIconButton({
    super.key,
    required this.radius,
    required this.icon,
    required this.func,
    required this.inLayer,
    this.liquidGlassSettings,
  });

  @override
  State<LiquidGlassIconButton> createState() => _LiquidGlassIconButtonState();
}

class _LiquidGlassIconButtonState extends State<LiquidGlassIconButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          blurStyle: BlurStyle.normal
        )],
        color: Colors.transparent
      ),
      child: widget.inLayer
      ? LiquidGlass.inLayer(
        shape: LiquidRoundedSuperellipse(
          borderRadius: Radius.circular(widget.radius)
        ),
        glassContainsChild: false,
        child: IconButton(
          icon: widget.icon,
          onPressed: () => widget.func(),
        ),
      )
      : LiquidGlass(
        shape: LiquidRoundedSuperellipse(
          borderRadius: Radius.circular(widget.radius)
        ),
        glassContainsChild: false,
        settings: widget.liquidGlassSettings ?? LiquidGlassSettings(),
        child: IconButton(
          icon: widget.icon,
          onPressed: () => widget.func,
        ),
      ),
    );
  }
}