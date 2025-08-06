import 'package:flutter/cupertino.dart';

class CounterProvider extends ChangeNotifier{
  int _count = 0;

  int get count => _count;

  void increment(){
    _count++;
    notifyListeners(); // 구독하고 있는 대상 위젯들에게 데이터가 변경되었다고 알림!
  }
}