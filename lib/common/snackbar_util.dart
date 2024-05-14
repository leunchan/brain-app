import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text, [int duration = 2]) {
  // 스낵바 호출 유틸함수
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      duration: Duration(seconds: duration),
    ),
  );
}
