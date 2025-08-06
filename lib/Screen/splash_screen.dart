import 'package:flutter/material.dart';

//시작 화면 splashscreen
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(
      Duration(seconds: 2),
          () {
        // 화면 이동
        Navigator.pushNamed(context, '/main');
      },
    );
    /// 자동 정렬 -> command + option + L
    return Scaffold(body: Center(child: Text('start display')));
  }
}
