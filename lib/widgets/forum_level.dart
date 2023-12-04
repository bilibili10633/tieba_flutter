import 'package:flutter/material.dart';
class ForumLevelWidget extends StatelessWidget {
  final int level;
  const ForumLevelWidget({Key? key, required this.level}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 10,
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
          color: level > 10
              ? const Color(0xfff5b546)
              : level>4?const Color(0xff6aa4f3)
              :const Color(0xff72e051)
      ),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          level.toString(),
          style: const TextStyle(
              color: Colors.white,
              fontSize: 7,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.26),
        ),
      ),
    );
  }
}
