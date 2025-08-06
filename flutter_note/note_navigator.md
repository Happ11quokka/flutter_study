# Flutter 네비게이션과 라우팅

## 1. Navigator를 활용한 화면 간 이동과 객체 전달

### 1.1 Navigator 개요

Navigator는 Flutter에서 화면 전환을 관리하는 위젯입니다. 스택(Stack) 구조를 사용하여 화면을 관리하며, 새로운 화면을 push하거나 현재 화면을 pop하는 방식으로 동작합니다.

### 1.2 Named Routes 설정

#### MaterialApp에서 라우트 정의

```dart
MaterialApp(
  title: 'Flutter Demo',
  initialRoute: '/',
  routes: {
    '/': (context) => const SplashScreen(),
    '/main': (context) => const MyHomePage(title: 'Provider Counter'),
  },
  onGenerateRoute: (settings) {
    if (settings.name == '/sub') {
      if (settings.arguments is String) {
        final msg = settings.arguments as String;
        return MaterialPageRoute(builder: (context) => SubScreen(msg: msg));
      }
    }
    return null;
  },
)
```

**핵심 개념:**

- `initialRoute`: 앱이 시작될 때 표시할 초기 화면
- `routes`: 정적 라우트 정의 (간단한 경우)
- `onGenerateRoute`: 동적 라우트 생성 (매개변수 전달이 필요한 경우)

### 1.3 화면 이동 방법

#### 1) pushNamed - 매개변수와 함께 화면 이동

```dart
Navigator.pushNamed(context, '/sub', arguments: 'hello');
```

#### 2) pop - 이전 화면으로 돌아가기

```dart
Navigator.pop(context);
```

### 1.4 실습 코드 예제

#### SubScreen - 매개변수 받기

```dart
class SubScreen extends StatelessWidget {
  final String msg;  // 전달받을 매개변수

  const SubScreen({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // 자동 뒤로가기 버튼 제거
        title: Text('서브화면: $msg'),
        actions: [
          Icon(Icons.ac_unit_outlined),
        ],
        elevation: 0, // 그림자 효과 제거
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text('서브화면입니다.')),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 이전 화면으로 돌아가기
            },
            child: const Text('뒤로가기'),
          ),
        ],
      ),
    );
  }
}
```

#### MainScreen에서 화면 이동

```dart
TextButton(
  onPressed: () {
    Navigator.pushNamed(context, '/sub', arguments: 'hihi');
  },
  child: const Text('클릭하여 서브 화면으로 이동'),
),
```

## 2. 네비게이션 바, 탭 바, 드로어 사용법

### 2.1 TabBar (탭 바)

#### DefaultTabController로 탭 관리

```dart
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 탭의 개수
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.person), text: 'Profile'),
              Tab(icon: Icon(Icons.settings), text: 'Settings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMainContent(context, userName, userAge),
            const Center(child: Text('프로필 탭')),
            const Center(child: Text('설정 탭')),
          ],
        ),
      ),
    );
  }
}
```

**핵심 개념:**

- `DefaultTabController`: 탭의 상태를 자동으로 관리
- `TabBar`: 상단의 탭 버튼들
- `TabBarView`: 각 탭에 해당하는 화면 내용

### 2.2 Drawer (사이드 메뉴)

#### Drawer 구현

```dart
Scaffold(
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
            Navigator.pop(context); // Drawer 닫기
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () {
            Navigator.pop(context); // Drawer 닫기
          },
        ),
      ],
    ),
  ),
  body: // 본문 내용
)
```

**핵심 개념:**

- `Drawer`: Scaffold의 drawer 속성에 설정
- `DrawerHeader`: Drawer 상단의 헤더 영역
- `ListTile`: 메뉴 항목들
- `Navigator.pop(context)`: Drawer 닫기

### 2.3 AppBar 커스터마이징

#### AppBar 속성들

```dart
AppBar(
  automaticallyImplyLeading: false, // 자동 뒤로가기/메뉴 버튼 제거
  title: Text('서브화면: $msg'),
  actions: [
    Icon(Icons.ac_unit_outlined), // 우측 액션 버튼들
  ],
  elevation: 0, // 그림자 효과 (0 = 그림자 없음)
),
```

## 3. 주요 개념 정리

### 3.1 Navigator Stack

- Flutter의 화면 관리는 스택(Stack) 구조
- `push`: 새 화면을 스택 위에 추가
- `pop`: 현재 화면을 스택에서 제거

### 3.2 Route 종류

1. **Named Routes**: 문자열 이름으로 관리 (권장)
2. **Anonymous Routes**: MaterialPageRoute로 직접 생성

### 3.3 매개변수 전달

- `arguments` 속성을 사용하여 데이터 전달
- `onGenerateRoute`에서 arguments를 받아 처리

### 3.4 UI 네비게이션 패턴

1. **TabBar**: 같은 레벨의 여러 화면 전환
2. **Drawer**: 앱의 주요 기능들을 모은 사이드 메뉴
3. **BottomNavigationBar**: 하단 네비게이션 (실습에는 없음)

## 4. 실습 코드에서 배운 점

### 4.1 Provider와 네비게이션

- Provider 상태는 네비게이션을 통해 화면을 이동해도 유지됨
- `context.read<Provider>()`로 상태 변경 가능
- `context.select<Provider, Type>()`로 특정 값만 구독 가능

### 4.2 UI 구성 요소들

- `FloatingActionButton`: 주요 액션 버튼
- `Consumer`: Provider 상태 변화 감지
- `Switch`: 테마 전환 등에 활용
- `SafeArea`: 상태바, 노치 등을 고려한 안전 영역

## 5. 추가 팁

### 5.1 성능 고려사항

- `Consumer`는 필요한 부분에만 사용
- `select`를 활용하여 불필요한 rebuild 방지

### 5.2 사용자 경험

- `automaticallyImplyLeading: false`로 의도하지 않은 뒤로가기 방지
- `elevation: 0`으로 플랫 디자인 구현
- 적절한 `SizedBox`로 여백 확보

### 5.3 코드 구조

- 화면별로 파일 분리 (main_screen.dart, sub_screen.dart)
- Provider로 상태 관리 중앙화
- onGenerateRoute로 동적 라우팅 처리
