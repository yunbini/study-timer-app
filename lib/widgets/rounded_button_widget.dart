import 'package:flutter/material.dart';

class RoundedButton extends StatefulWidget {
  final String text;

  const RoundedButton({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  _RoundedButtonState createState() => _RoundedButtonState();
}

class _RoundedButtonState extends State<RoundedButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140.0,
      height: 140.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26, // 너무 진해서 약간 연하게 변경 추천
            blurRadius: 5.0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.text,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
