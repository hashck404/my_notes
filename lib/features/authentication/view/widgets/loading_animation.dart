import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingAnimation extends StatelessWidget {
  const LoadingAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(80)),
        color: Color.fromARGB(174, 2, 2, 2),
      ),
      child: LoadingAnimationWidget.fallingDot(color: Colors.white, size: 30),
    );
  }
}
