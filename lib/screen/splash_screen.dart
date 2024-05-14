import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 1500,),() {
      // 1.5초 뒤에 실행될 로직 구현
      Navigator.popAndPushNamed(context, '/login');
    },);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo1.png',
              width: 480,
              height: 480,
            ),
            const SizedBox(height: 10),
            Text(
              '문제메이트',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}
