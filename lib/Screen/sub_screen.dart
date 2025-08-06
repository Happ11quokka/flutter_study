import 'package:flutter/material.dart';

class SubScreen extends StatelessWidget {
  final String msg;

  const SubScreen({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // backbutton 없애기
        title: Text('서브화면: $msg'),
        actions: [
          Icon(Icons.ac_unit_outlined),
        ], // actions?
        elevation: 0, // elevation?
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text('서브화면입니다.')),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('뒤로가기'),
          ),
        ],
      ),
    );
  }
}