import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class LiquidGlassToggleSlider extends StatefulWidget {
  const LiquidGlassToggleSlider({
    super.key,
    this.width = 220,
    this.height = 56,
    this.trackHeight,
    this.padding = const EdgeInsets.all(6),
    this.activeColor = const Color(0xFF00B2FF),
    this.inactiveColor = const Color(0xFF2B2B2F),
    this.knobColor = Colors.white,
    this.knobGrowDuration = const Duration(milliseconds: 200),
    this.knobMoveDuration = const Duration(milliseconds: 200),
    this.backgroundDuration = const Duration(milliseconds: 10),
    this.knobGrowCurve = Curves.easeOutCubic,
    this.knobShrinkCurve = Curves.easeInCubic,
    this.knobMoveCurve = Curves.easeInOut,
    this.backgroundCurve = Curves.easeInOut,
    this.glassBlur = 8.0,
    this.glassThickness = 10.0,
    this.glassColor = const Color(0x1AFFFFFF),
    this.glassLightIntensity = 1.4,
    this.glassAmbientStrength = 0.35,
    this.glassOutlineIntensity = 0.5,
    this.initialValue = false,
    this.activeOnRight = true,
    this.knobMaxScale = 2.5,
    this.onChanged,
  });

  final double width;
  final double height;
  final double? trackHeight;
  final EdgeInsets padding;
  final Color activeColor;
  final Color inactiveColor;
  final Color knobColor;

  final Duration knobGrowDuration;
  final Duration knobMoveDuration;
  final Duration backgroundDuration;

  final Curve knobGrowCurve;
  final Curve knobShrinkCurve;
  final Curve knobMoveCurve;
  final Curve backgroundCurve;

  final double glassBlur;
  final double glassThickness;
  final Color glassColor;
  final double glassLightIntensity;
  final double glassAmbientStrength;
  final double glassOutlineIntensity;

  final bool initialValue;
  final bool activeOnRight;
  final double knobMaxScale;
  final ValueChanged<bool>? onChanged;

  @override
  State<LiquidGlassToggleSlider> createState() =>
      _LiquidGlassToggleSliderState();
}

class _LiquidGlassToggleSliderState extends State<LiquidGlassToggleSlider>
    with SingleTickerProviderStateMixin {
  late bool _value;
  late final AnimationController _c;
  late final Animation<double> _t;

  double? _dragStartX;
  double? _dragStartValue;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;

    final totalDuration = widget.knobGrowDuration +
        widget.knobMoveDuration +
        widget.knobGrowDuration;

    _c = AnimationController(
      vsync: this,
      duration: totalDuration,
      value: _value ? 1 : 0,
    );

    _t = CurvedAnimation(parent: _c, curve: Curves.linear);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _toggle() {
    _value = !_value;
    if (_value) {
      _c.forward();
    } else {
      _c.reverse();
    }
    widget.onChanged?.call(_value);
  }

  void _onDragStart(DragStartDetails details) {
    _isDragging = true;
    _dragStartX = details.localPosition.dx;
    _dragStartValue = _c.value;
    setState(() {});
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_dragStartX == null || _dragStartValue == null) return;
    final dx = details.localPosition.dx - _dragStartX!;
    final trackW = widget.width - widget.padding.horizontal;
    final knobTravel = trackW - (widget.trackHeight ?? widget.height * 0.6) * 0.7 * 2.0;
    final delta = dx / knobTravel;

    double newValue = (_dragStartValue! + (widget.activeOnRight ? delta : -delta))
        .clamp(0.0, 1.0);

    _c.value = newValue;
  }

  void _onDragEnd(DragEndDetails details) {
    _isDragging = false;
    final shouldBeOn = _c.value > 0.5;
    _value = shouldBeOn;
    if (shouldBeOn) {
      _c.forward();
    } else {
      _c.reverse();
    }
    widget.onChanged?.call(_value);
    _dragStartX = null;
    _dragStartValue = null;
  }

  @override
  Widget build(BuildContext context) {
    final trackH = widget.trackHeight ?? widget.height * 0.6;
    final trackRadius = BorderRadius.circular(trackH / 2);

    return GestureDetector(
      onTap: _toggle,
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _t,
        builder: (context, _) {
          final t = _t.value.clamp(0.0, 1.0);

          final bgColor =
              Color.lerp(widget.inactiveColor, widget.activeColor, t)!;

          final innerW = widget.width - widget.padding.horizontal;
          final knobBaseH = trackH * 0.7;
          final knobBaseW = knobBaseH * 2.0;

          double scale;
          double whiteOpacity;
          double glassOpacity;
          double moveT = 0;

          if (_isDragging) {
            scale = widget.knobMaxScale;
            whiteOpacity = 0.0;
            glassOpacity = 1.0;
            moveT = t;
          } else {
            final totalDuration = widget.knobGrowDuration +
                widget.knobMoveDuration +
                widget.knobGrowDuration;

            final growPhase =
                widget.knobGrowDuration.inMilliseconds / totalDuration.inMilliseconds;
            final movePhase =
                widget.knobMoveDuration.inMilliseconds / totalDuration.inMilliseconds;
            final shrinkPhase =
                widget.knobGrowDuration.inMilliseconds / totalDuration.inMilliseconds;

            double growT = 0;

            if (t <= growPhase) {
              growT =
                  widget.knobGrowCurve.transform((t / growPhase).clamp(0.0, 1.0));
              moveT = 0;
            } else if (t <= growPhase + movePhase) {
              growT = 1;
              moveT = widget.knobMoveCurve
                  .transform(((t - growPhase) / movePhase).clamp(0.0, 1.0));
            } else {
              growT = 1 -
                  widget.knobShrinkCurve.transform(
                      ((t - growPhase - movePhase) / shrinkPhase).clamp(0.0, 1.0));
              moveT = 1;
            }

            scale = _lerpDouble(1.0, widget.knobMaxScale, growT);
            whiteOpacity = (1.0 - growT).clamp(0.0, 1.0);
            glassOpacity = growT.clamp(0.0, 1.0);
          }

          final trackExtent = innerW - knobBaseW;
          double knobLeft;
          if (widget.activeOnRight) {
            knobLeft = widget.padding.left + trackExtent * moveT;
          } else {
            knobLeft = widget.padding.left + trackExtent * (1 - moveT);
          }

          final knobTop = (trackH - knobBaseH) / 2;

          final scaledW = knobBaseW * scale;
          final scaledH = knobBaseH * scale;

          final knobCenterX = knobLeft + knobBaseW / 2;
          final knobCenterY = knobTop + knobBaseH / 2;

          return SizedBox(
            width: widget.width,
            height: trackH,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: widget.backgroundDuration,
                  curve: widget.backgroundCurve,
                  width: widget.width,
                  height: trackH,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: trackRadius,
                  ),
                ),
                Positioned(
                  left: knobCenterX - scaledW / 2,
                  top: knobCenterY - scaledH / 2,
                  width: scaledW,
                  height: scaledH,
                  child: IgnorePointer(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: whiteOpacity,
                          child: Container(
                            width: knobBaseW,
                            height: knobBaseH,
                            decoration: BoxDecoration(
                              color: widget.knobColor,
                              borderRadius: BorderRadius.circular(knobBaseH / 2),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 12,
                                  offset: const Offset(0, 3),
                                  color: Colors.black.withOpacity(0.15),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: glassOpacity,
                          child: _LiquidGlassPill(
                            width: scaledW,
                            height: scaledH,
                            blur: widget.glassBlur,
                            thickness: widget.glassThickness,
                            glassColor: widget.glassColor,
                            lightIntensity: widget.glassLightIntensity,
                            ambientStrength: widget.glassAmbientStrength,
                            outlineIntensity: widget.glassOutlineIntensity,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

class _LiquidGlassPill extends StatelessWidget {
  const _LiquidGlassPill({
    required this.width,
    required this.height,
    required this.blur,
    required this.thickness,
    required this.glassColor,
    required this.lightIntensity,
    required this.ambientStrength,
    required this.outlineIntensity,
  });

  final double width;
  final double height;
  final double blur;
  final double thickness;
  final Color glassColor;
  final double lightIntensity;
  final double ambientStrength;
  final double outlineIntensity;

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      settings: LiquidGlassSettings(
        thickness: thickness,
        glassColor: glassColor,
        lightIntensity: lightIntensity,
        ambientStrength: ambientStrength,
        lightAngle: 2.5,
      ),
      shape: LiquidRoundedSuperellipse(
        borderRadius: Radius.circular(height / 2),
      ),
      child: SizedBox(width: width, height: height),
    );
  }
}
