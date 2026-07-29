import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;

  const Background({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        Container(
          color: const Color(0xffF7F1EB),
        ),

        Positioned(
          right: -90,
          top: -90,
          child: Container(
            width: 180,
            height: 180,
            decoration: const BoxDecoration(
              color: Color(0xff8B7AA8),
              shape: BoxShape.circle,
            ),
          ),
        ),

        Positioned(
          left: -90,
          bottom: -90,
          child: Container(
            width: 180,
            height: 180,
            decoration: const BoxDecoration(
              color: Color(0xffF0C38E),
              shape: BoxShape.circle,
            ),
          ),
        ),

        SafeArea(child: child),
      ],
    );
  }
}