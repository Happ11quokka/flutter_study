import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<String> lstHello = ['a', 'b', 'c', 'd', 'e'];
  TextEditingController idealcontroller = TextEditingController();
  String msg = '이 곳에 입력 값이 업데이트 됩니다.';
  ValueNotifier<int> counter = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main display')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context); // 닫기
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/sub', arguments: 'hihi');
                },
                child: const Text('클릭하여 서브 화면으로 이동'),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'ideal'),
                controller: idealcontroller,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    msg = idealcontroller.text.toString();
                  });
                  counter.value = 30;
                },
                child: const Text('입력 확인'),
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<int>(
                valueListenable: counter,
                builder: (context, value, child) {
                  return Text('count: $value');
                },
              ),
              const SizedBox(height: 20),
              Text(
                msg,
                style: const TextStyle(fontSize: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}