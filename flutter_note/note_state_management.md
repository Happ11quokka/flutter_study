# 상태 관리 심화

## Counter 앱으로 쉽게 배우는 Provider 상태관리 라이브러리

### Provider란?

Provider는 Flutter에서 가장 인기 있는 상태 관리 라이브러리 중 하나로, InheritedWidget을 기반으로 만들어진 라이브러리입니다.

### Provider의 주요 특징

- **간단한 구문**: 복잡한 보일러플레이트 코드 없이 상태 관리 가능
- **성능 최적화**: 필요한 위젯만 리빌드되도록 최적화
- **타입 안전성**: 컴파일 타임에 타입 검사 가능
- **의존성 주입**: 앱 전체에서 상태를 공유할 수 있음

### ChangeNotifierProvider 사용법

```dart
// 1. ChangeNotifier를 상속받은 Provider 클래스 생성
class CounterProvider extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners(); // 상태 변경을 알림
  }
}

// 2. main.dart에서 Provider 등록
ChangeNotifierProvider(create: (_) => CounterProvider())
```

### Consumer 위젯 사용법

Consumer는 Provider의 상태가 변경될 때만 해당 부분을 리빌드하는 위젯입니다.

```dart
Consumer<CounterProvider>(
  builder: (context, value, child) => Text(
    '${value.count}',
    style: Theme.of(context).textTheme.headlineMedium,
  ),
)
```

## 테마 변경 기능으로 쉽게 배우는 Multi Provider

### MultiProvider란?

여러 개의 Provider를 한 번에 등록할 수 있는 위젯입니다. 앱이 복잡해지면서 여러 상태를 관리해야 할 때 사용합니다.

### MultiProvider 설정

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CounterProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
```

### 테마 Provider 구현 예시

```dart
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
```

### MaterialApp에서 테마 적용

```dart
Widget build(BuildContext context) {
  final themeProvider = context.watch<ThemeProvider>();

  return MaterialApp(
    theme: themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
    // ... 기타 설정
  );
}
```

## read VS watch VS select 차이점

Provider에서 상태에 접근하는 세 가지 주요 방법이 있으며, 각각 다른 용도로 사용됩니다.

### 1. context.read<T>()

- **용도**: 상태를 읽기만 하고 리빌드가 필요 없는 경우
- **특징**: 상태가 변경되어도 위젯이 리빌드되지 않음
- **사용 시기**: 이벤트 핸들러(onPressed, onChanged 등)에서 상태를 변경할 때

```dart
ElevatedButton(
  onPressed: () => context.read<CounterProvider>().increment(),
  child: const Text('증가'),
)
```

### 2. context.watch<T>()

- **용도**: 상태를 읽고 상태가 변경될 때 위젯을 리빌드해야 하는 경우
- **특징**: 상태가 변경되면 해당 위젯이 자동으로 리빌드됨
- **사용 시기**: build 메서드에서 상태 값을 UI에 표시할 때

```dart
Widget build(BuildContext context) {
  final themeProvider = context.watch<ThemeProvider>();
  return MaterialApp(
    theme: themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
  );
}
```

### 3. context.select<T, R>()

- **용도**: Provider의 특정 속성만 관찰하고 해당 속성이 변경될 때만 리빌드
- **특징**: 성능 최적화에 매우 유용 (불필요한 리빌드 방지)
- **사용 시기**: Provider의 일부 속성만 필요한 경우

```dart
Widget build(BuildContext context) {
  final userAge = context.select<UserProvider, int>((user) => user.age);
  final userName = context.select<UserProvider, String>((user) => user.name);

  return Column(
    children: [
      Text('Name: $userName'), // name이 변경될 때만 리빌드
      Text('Age: $userAge'),   // age가 변경될 때만 리빌드
    ],
  );
}
```

## 성능 최적화 팁

### 1. Consumer vs context.watch

- **Consumer**: 특정 부분만 리빌드하고 싶을 때 사용
- **context.watch**: 전체 build 메서드를 리빌드해야 할 때 사용

### 2. select 활용

```dart
// ❌ 비효율적: UserProvider의 모든 변경사항에 반응
final user = context.watch<UserProvider>();
Text('Age: ${user.age}')

// ✅ 효율적: age 속성 변경시에만 반응
final userAge = context.select<UserProvider, int>((user) => user.age);
Text('Age: $userAge')
```

### 3. 적절한 Provider 분리

- 서로 다른 기능의 상태는 별도의 Provider로 분리
- 예: CounterProvider, ThemeProvider, UserProvider

## 라우팅과 Provider

### Context 문제 해결

라우팅에서 Provider를 사용할 때 context 문제가 발생할 수 있습니다.

```dart
// ❌ 문제가 될 수 있는 코드
'/main': (context) => MyHomePage(title: 'Provider Counter'),

// ✅ Builder로 감싸서 해결
'/main': (context) => Builder(
  builder: (newContext) => MyHomePage(title: 'Provider Counter'),
),
```

## 주요 위젯 및 메서드 정리

| 위젯/메서드              | 설명                | 리빌드 여부 |
| ------------------------ | ------------------- | ----------- |
| `ChangeNotifierProvider` | Provider 등록       | -           |
| `MultiProvider`          | 여러 Provider 등록  | -           |
| `Consumer<T>`            | 상태 변경시 리빌드  | ✅          |
| `context.read<T>()`      | 상태 읽기만         | ❌          |
| `context.watch<T>()`     | 상태 관찰 및 리빌드 | ✅          |
| `context.select<T, R>()` | 특정 속성만 관찰    | ✅ (조건부) |
| `notifyListeners()`      | 상태 변경 알림      | -           |

## 실습 코드에서 배운 핵심 개념

1. **MultiProvider 구조**: 여러 상태를 체계적으로 관리
2. **테마 토글 기능**: 다크/라이트 모드 전환
3. **사용자 정보 관리**: name, age 속성을 별도로 관찰
4. **성능 최적화**: select를 사용한 부분 리빌드
5. **이벤트 처리**: read를 사용한 상태 변경

이러한 패턴들을 익히면 복잡한 Flutter 앱에서도 효율적인 상태 관리가 가능합니다.
