# Flutter 프레임워크 기초 노트

## 위젯(Widget)의 개념

위젯이란 Flutter 애플리케이션의 모든 구성요소를 나타내는 기본 단위입니다. 화면에 그려지는 모든 것을 위젯으로 표현할 수 있으며, 다양한 종류와 계층구조로 구성되어 있습니다.

### 주요 위젯 타입

#### 1. StatelessWidget (STL)

- 상태가 없는 위젯으로, 한번 생성되면 내부 데이터나 상태를 변경할 수 없습니다.
- UI를 그리기 위한 정보만을 가집니다.
- 성능이 좋고 단순한 UI 요소에 적합합니다.

```dart
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("나의 첫 앱")),
      body: Text("안녕하세요")
    );
  }
}
```

#### 2. StatefulWidget (STF)

- 상태를 가지는 위젯으로, 사용자 상호 작용 또는 다른 이벤트에 따라 상태를 변경할 수 있습니다.
- 두 개의 클래스로 구성됩니다:
  1. StatefulWidget 클래스: 위젯의 설정과 구성을 정의
  2. State 클래스: 위젯의 상태와 UI 로직을 관리

```dart
class MainScreen2 extends StatefulWidget {
  const MainScreen2({super.key});

  @override
  State<MainScreen2> createState() => _MainScreen2State();
}

class _MainScreen2State extends State<MainScreen2> {
  String msg = 'Danny';

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        msg = ' good bye ';
      });
    },);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("나의 첫 앱")),
      body: Text(msg)
    );
  }
}
```

> **왜 StatefulWidget이 두 클래스로 나누어져 있나요?**
>
> 1. 관심사 분리: 위젯 구성과 상태 관리를 분리하여 코드를 더 명확하게 합니다.
> 2. 효율성: 위젯이 다시 빌드되더라도 State 객체는 유지되어 상태가 보존됩니다.
> 3. 유연성: 위젯 트리가 재구성될 때 State를 다른 위젯에 재할당할 수 있습니다.

### Scaffold 위젯

Material Design 스타일의 앱을 개발할 때 기본적인 앱의 레이아웃 구조를 제공하는 위젯입니다. 주요 기본 UI 요소를 제공하는 중요한 위젯으로, 다음과 같은 구성요소를 포함할 수 있습니다:

- AppBar: 상단 앱 바
- Body: 주 콘텐츠 영역
- BottomNavigationBar: 하단 탐색 바
- Drawer: 측면 메뉴
- FloatingActionButton: 플로팅 액션 버튼
- SnackBar: 알림 메시지

### build 메서드

모든 위젯은 `build` 메서드를 가지고 있으며, 이 메서드는 위젯이 화면에 어떻게 표시될지를 정의합니다. Flutter는 위젯의 상태가 변경되거나 부모 위젯이 재구성될 때 이 메서드를 호출합니다.

```dart
@override
Widget build(BuildContext context) {
  // 여기서 UI 구성 요소를 반환
  return Widget(...);
}
```

## 라우팅(Route)

Flutter에서 라우팅은 앱의 다양한 화면 간 이동을 관리하는 시스템입니다.

### 주요 라우팅 개념

#### 1. initialRoute

앱이 시작될 때 처음으로 표시할 라우트를 지정합니다.

```dart
MaterialApp(
  initialRoute: '/',
  // ...
)
```

#### 2. routes

앱에서 사용할 수 있는 모든 화면(라우트)의 맵을 정의합니다. 각 라우트는 문자열 키와 해당 화면을 생성하는 빌더 함수로 구성됩니다.

```dart
MaterialApp(
  routes: {
    '/': (context) => SplashScreen(),
    '/main': (context) => MainScreen(),
  },
  // ...
)
```

#### 3. Navigator

화면 간 이동을 관리하는 클래스로, 스택 구조로 화면을 관리합니다.

```dart
// 새 화면으로 이동
Navigator.pushNamed(context, '/main');

// 이전 화면으로 돌아가기
Navigator.pop(context);
```

## 실습 코드 구조

### 1. main.dart

애플리케이션의 진입점으로, `runApp()`을 통해 루트 위젯을 실행합니다.

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // home: const MainScreen2(), // 애플을 실행할때 최초로 실행되는 놈
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/main': (context) => MainScreen(),
      },
    );
  }
}
```

### 2. splash_screen.dart

앱 시작 시 잠시 표시되는 시작 화면을 정의합니다.

```dart
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
```

### 3. main_screen.dart

앱의 메인 화면을 정의합니다.

```dart
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('is main!'),),);
  }
}
```

## 추가 팁과 정보

### 상태 관리 메서드

- **initState()**: 위젯이 생성될 때 한 번만 호출되며, 초기 상태를 설정하는 데 사용됩니다.
- **setState()**: 위젯의 상태를 변경하고 UI를 업데이트하는 데 사용됩니다.
- **dispose()**: 위젯이 제거될 때 호출되며, 리소스를 정리하는 데 사용됩니다.

### Future와 비동기 프로그래밍

Flutter에서는 `Future`를 사용하여 비동기 작업을 처리합니다.

```dart
Future.delayed(
  Duration(seconds: 2),
  () {
    // 지연 후 실행할 코드
  },
);
```

### 자동 정렬 단축키

코드의 가독성을 높이기 위한 자동 정렬: `command + option + L`

### 위젯 트리 구성 패턴

Flutter 앱은 위젯 트리로 구성되며, 각 위젯은 자식 위젯을 가질 수 있습니다. 이러한 구조는 UI를 체계적으로 구성하고 관리하는 데 도움이 됩니다.

```
MaterialApp
  └── Scaffold
       ├── AppBar
       │    └── Text
       └── Body
            └── Center
                 └── Text
```
