import 'dart:math';
import 'package:vector_math/vector_math.dart' as Vector;
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class DemoBody extends StatefulWidget {
  final Size size;
  final int xOffset;
  final int yOffset;
  final Color color;

  const DemoBody({
    Key? key,
    required this.size,
    this.xOffset = 0,
    this.yOffset = 0,
    required this.color,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DemoBodyState();
}

class _DemoBodyState extends State<DemoBody> with TickerProviderStateMixin {
  late AnimationController animationController;
  List<Offset> animList1 = [];

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    animationController.addListener(() {
      animList1.clear();

      for (int i = -2 - widget.xOffset;
      i <= widget.size.width.toInt() + 2;
      i++) {
        animList1.add(
          Offset(
            i.toDouble() + widget.xOffset,
            sin(
              (animationController.value * 360 - i) %
                  360 *
                  Vector.degrees2Radians,
            ) *
                10 +
                30 +
                widget.yOffset,
          ),
        );
      }
      setState(() {}); // 화면 갱신 필요
    });

    animationController.repeat();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: AnimatedBuilder(
        animation: CurvedAnimation(
          parent: animationController,
          curve: Curves.easeInOut,
        ),
        builder: (context, child) => ClipPath(
          clipper: WaveClipper(animationController.value, animList1),
          child: Container(
            width: widget.size.width,
            height: widget.size.height,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  final double animation;
  final List<Offset> waveList1;

  WaveClipper(this.animation, this.waveList1);

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.addPolygon(waveList1, false);

    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) =>
      animation != oldClipper.animation;
}
