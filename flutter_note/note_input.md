# 사용자 입력과 상호작용

Flutter에서 사용자 입력과 상호 작용을 처리하는 주요 위젯은 다음과 같습니다:

- **ElevatedButton**: 사용자가 누를 수 있는 버튼
- **ListView**: 스크롤 가능한 목록 표시
- **TextField**: 텍스트 입력 필드

모든 예제는 `StatefulWidget`을 사용하여 상태 변화를 관리합니다.

## ElevatedButton

ElevatedButton은 사용자가 클릭할 수 있는 기본적인 상호작용 위젯입니다.

### 주요 속성

- `onPressed`: 버튼이 클릭되었을 때 실행할 콜백 함수
- `style`: 버튼의 스타일 지정
- `child`: 버튼에 표시할 위젯 (보통 Text)

### 스타일 지정 방법

```dart
ElevatedButton(
  onPressed: () {
    // 클릭되었을 때 동작
    debugPrint("버튼이 클릭되었습니다!"); // print → debugPrint 권장
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,    // 버튼 배경색
    foregroundColor: Colors.yellow,   // 버튼 텍스트/아이콘 색상
    elevation: 0,                     // 그림자 높이
  ),
  child: Text('눌러보세요'),
)
```

### 참고사항

- 버튼 크기를 조절하려면 `Container`로 감싸서 사용합니다.
- 디버깅 메시지는 `print()` 대신 `debugPrint()`를 권장합니다.

## ListView

ListView는 스크롤 가능한 목록을 표시하는 위젯입니다.

### ListView.builder

데이터 목록이 있을 때 효율적으로 목록을 생성하는 방법입니다.

```dart
List lstHello = ['a', 'b', 'c', 'd', 'e'];

ListView.builder(
  itemBuilder: (context, index) {
    return ListTile(
      title: Text('${lstHello[index]}'),
      subtitle: Text("nom"),
    );
  },
  itemCount: lstHello.length,
)
```

### 주요 속성

- `itemBuilder`: 각 항목을 빌드하는 함수
- `itemCount`: 총 항목 수
- `ListTile`: 목록의 각 항목을 표시하는 편리한 위젯
  - `title`: 주 텍스트
  - `subtitle`: 부 텍스트

## TextField

TextField는 사용자로부터 텍스트 입력을 받는 위젯입니다.

### 주요 속성

- `decoration`: 입력 필드의 디자인 (레이블, 힌트 등)
- `controller`: 입력 값을 제어하고 접근하는 컨트롤러

### 사용 예제

```dart
TextEditingController idealcontroller = TextEditingController();

TextField(
  decoration: InputDecoration(labelText: 'ideal'),
  controller: idealcontroller,
)

// 값 가져오기
String value = idealcontroller.text;
```

### 입력 값 활용하기

```dart
ElevatedButton(
  onPressed: () {
    debugPrint('입력된 값: ${idealcontroller.text}');
  },
  child: Text('입력 확인'),
)
```

## 전체 코드 예제

### ListView 예제

```dart
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List lstHello = ['a', 'b', 'c', 'd','e'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Main display')),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('${lstHello[index]}'),
            subtitle: Text("nom"),
          );
        },
        itemCount: lstHello.length,
      ),
    );
  }
}
```

### ElevatedButton 예제

```dart
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Main display')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton( // 크기 조절은 container을 활용
              onPressed: () {
                // 클릭되었을 때 동작
                debugPrint("버튼이 클릭되었습니다!"); // print → debugPrint 권장
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.yellow,
                elevation: 0,
              ),
              child: Text('눌러보세요'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### TextField 예제

```dart
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<String> lstHello = ['a', 'b', 'c', 'd', 'e'];
  TextEditingController idealcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Main display')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'ideal'),
              controller: idealcontroller,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                debugPrint('입력된 값: ${idealcontroller.text}');
              },
              child: Text('입력 확인'),
            ),
          ],
        ),
      ),
    );
  }
}
```

</artifact>
