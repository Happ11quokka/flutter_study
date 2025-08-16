# Flutter 라우팅 노트: Navigator vs GoRouter

## 🎯 Navigator (기본 라우터)

### 정의

- Flutter가 기본으로 제공하는 명령형(Imperative) 라우팅 시스템
- Stack 구조로 화면을 관리 (push/pop 방식)
- MaterialApp의 내장 기능

### 기본 사용법

```dart
// 1. 간단한 이동 (push)
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => SecondScreen()),
);

// 2. 뒤로 가기 (pop)
Navigator.pop(context);

// 3. Named Routes 사용
// main.dart에서 정의
MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => HomeScreen(),
    '/details': (context) => DetailsScreen(),
  },
);

// 사용
Navigator.pushNamed(context, '/details');
```

### 특징

- **장점**
  - Flutter 기본 제공 (추가 패키지 불필요)
  - 간단한 앱에 적합
  - 직관적인 push/pop 메커니즘
- **단점**
  - 복잡한 라우팅 로직 구현 어려움
  - 딥링크 지원 제한적
  - 웹 URL 동기화 어려움
  - 중첩 라우팅 복잡함

---

## GoRouter

### 정의

- 선언적(Declarative) 라우팅 패키지
- URL 기반 라우팅 지원
- Flutter 팀이 공식 권장하는 라우팅 솔루션

### 설치

```yaml
dependencies:
  go_router: ^14.0.0
```

### 기본 사용법

```dart
// 1. 라우터 설정
final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/profile/:id',  // 파라미터 지원
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProfileScreen(userId: id);
      },
    ),
  ],
);

// 2. MaterialApp 연결
MaterialApp.router(
  routerConfig: router,
);

// 3. 네비게이션
context.go('/profile/123');     // 직접 이동
context.push('/settings');       // 스택에 추가
context.pop();                   // 뒤로 가기
```

---

## 🔍 주요 차이점 비교

| 특징              | Navigator           | GoRouter             |
| ----------------- | ------------------- | -------------------- |
| **라우팅 방식**   | 명령형 (Imperative) | 선언적 (Declarative) |
| **URL 지원**      | 제한적              | 완벽 지원            |
| **딥링크**        | 복잡한 설정 필요    | 기본 지원            |
| **웹 지원**       | URL 동기화 어려움   | 자동 URL 동기화      |
| **중첩 라우팅**   | 복잡함              | 간단한 구조          |
| **리다이렉트**    | 수동 구현           | 내장 지원            |
| **쿼리 파라미터** | 수동 파싱           | 자동 파싱            |
| **경로 파라미터** | 지원 안함           | 지원 (`/user/:id`)   |
| **타입 안전성**   | 낮음                | 높음                 |
| **테스트**        | 어려움              | 쉬움                 |

---

## GoRouter 고급 기능

### 1. 인증 기반 리다이렉트

```dart
GoRouter(
  redirect: (context, state) async {
    final isLoggedIn = await checkAuthStatus();
    final isLoginPage = state.matchedLocation == '/login';

    if (!isLoggedIn && !isLoginPage) {
      return '/login';
    }
    if (isLoggedIn && isLoginPage) {
      return '/home';
    }
    return null; // 리다이렉트 불필요
  },
);
```

### 2. 중첩 라우팅 (Nested Routes)

```dart
GoRoute(
  path: '/example',
  routes: [  // 하위 라우트
    GoRoute(
      path: 'button',  // /example/button
      builder: (context, state) => ButtonScreen(),
    ),
    GoRoute(
      path: 'input',   // /example/input
      builder: (context, state) => InputScreen(),
    ),
  ],
);
```

### 3. 쿼리 파라미터 처리

```dart
// URL: /signup?email=test@test.com&name=John
GoRoute(
  path: '/signup',
  builder: (context, state) {
    final params = state.uri.queryParameters;
    final email = params['email'] ?? '';
    final name = params['name'] ?? '';
    return SignupScreen(email: email, name: name);
  },
);
```

### 4. 에러 처리

```dart
GoRouter(
  errorBuilder: (context, state) => ErrorScreen(
    error: state.error,
  ),
);
```

---

## 언제 무엇을 사용해야 할까?

### Navigator를 사용해야 할 때

- ✅ 매우 간단한 앱 (2-3개 화면)
- ✅ 프로토타입 또는 MVP
- ✅ 웹 지원이 필요 없는 경우
- ✅ 추가 패키지를 피하고 싶을 때

### GoRouter를 사용해야 할 때

- ✅ 중대형 규모 앱
- ✅ 웹 지원이 필요한 경우
- ✅ 딥링크 지원 필요
- ✅ 복잡한 라우팅 로직 (인증, 권한 등)
- ✅ URL 기반 네비게이션 필요
- ✅ 테스트가 중요한 경우

---

## 실제 프로젝트 적용 예시

### 코드에서 본 GoRouter 활용 패턴

```dart
final router = GoRouter(
  // 1. 초기 경로 설정 (테스트 모드 지원)
  initialLocation: isTestMode ? '/' : '/login',

  // 2. 인증 기반 리다이렉트
  redirect: (context, state) async {
    final authStatus = await AuthService.checkAuthStatus();
    // 인증 로직...
  },

  // 3. 라우트 정의
  routes: [
    // 일반 라우트
    GoRoute(path: '/home', builder: ...),

    // 파라미터가 있는 라우트
    GoRoute(
      path: '/coin/:market',
      builder: (context, state) {
        final market = state.pathParameters['market']!;
        return CoinDetailScreen(market: market);
      },
    ),

    // 중첩 라우트 (예제 섹션)
    GoRoute(
      path: '/example',
      redirect: (_, state) {
        if (state.matchedLocation == '/example/') {
          return '/example/button';  // 기본 하위 페이지
        }
        return null;
      },
      routes: [ /* 하위 라우트들 */ ],
    ),
  ],

  // 4. 에러 처리
  errorBuilder: (context, state) => ErrorScreen(),
);
```

---

## 마이그레이션 가이드

### Navigator → GoRouter 전환 시 체크리스트

1. **패키지 설치**

   ```yaml
   dependencies:
     go_router: ^14.0.0
   ```

2. **MaterialApp → MaterialApp.router**

   ```dart
   // 변경 전
   MaterialApp(
     home: HomeScreen(),
     routes: {...},
   )

   // 변경 후
   MaterialApp.router(
     routerConfig: router,
   )
   ```

3. **네비게이션 코드 변경**

   ```dart
   // 변경 전
   Navigator.pushNamed(context, '/profile');

   // 변경 후
   context.go('/profile');
   ```

4. **파라미터 전달 방식 변경**

   ```dart
   // 변경 전 (arguments 사용)
   Navigator.pushNamed(
     context,
     '/profile',
     arguments: {'id': 123},
   );

   // 변경 후 (URL 파라미터)
   context.go('/profile/123');
   // 또는 쿼리 파라미터
   context.go('/profile?id=123');
   ```

---

## 🔗 참고 자료

- [GoRouter 공식 문서](https://pub.dev/packages/go_router)
- [Flutter Navigation 공식 가이드](https://docs.flutter.dev/development/ui/navigation)
- [GoRouter 마이그레이션 가이드](https://docs.flutter.dev/ui/navigation/go-router-migration)
