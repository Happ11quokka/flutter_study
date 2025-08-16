# Flutter JWT 인증 구현 완벽 가이드

---

## 1. JWT 이론 및 개념

### 1.1 JWT(JSON Web Token) 정의

JWT는 **사용자 간 정보를 안전하게 JSON 객체로 전송하기 위한 컴팩트하고 독립적인 방식**을 정의하는 개방형 표준(RFC 7519)입니다.

```
xxxxx.yyyyy.zzzzz
  │     │      │
  │     │      └─► Signature (서명)
  │     └────────► Payload (데이터)
  └──────────────► Header (헤더)
```

### 1.2 JWT 구조

#### Header (헤더)

```json
{
  "alg": "HS256", // 서명 알고리즘
  "typ": "JWT" // 토큰 타입
}
```

#### Payload (페이로드)

```json
{
  "sub": "limdongxian1207@gmail.com", // subject (사용자)
  "iat": 1755001537, // issued at (발급 시간)
  "exp": 1755087937, // expiration (만료 시간)
  "memberId": 4, // 커스텀 클레임
  "name": "임동현"
}
```

#### Signature (서명)

```javascript
HMACSHA256(base64UrlEncode(header) + "." + base64UrlEncode(payload), secret);
```

### 1.3 Bearer Token

**Bearer Token**은 HTTP Authorization 헤더에서 사용하는 인증 스키마입니다.

```http
Authorization: Bearer <token>
```

- **Bearer**: "소지자"라는 의미로, 이 토큰을 가진 사람이 리소스에 접근할 수 있음을 나타냄
- **사용 이유**:
  - 표준화된 방식
  - 다양한 인증 방식과 구분 가능 (Basic, Digest, OAuth 등)
  - 서버가 토큰 타입을 쉽게 식별

### 1.4 JWT 장단점

#### 장점

- **Stateless**: 서버가 세션을 저장할 필요 없음
- **확장성**: 마이크로서비스 아키텍처에 적합
- **자가 수용적**: 필요한 모든 정보를 자체 포함
- **크로스 도메인**: CORS 문제 해결 용이

#### 단점

- **토큰 크기**: 세션 ID보다 큼
- **강제 만료 어려움**: 발급된 토큰을 즉시 무효화하기 어려움
- **정보 노출**: Payload가 디코딩 가능 (암호화 X, 인코딩 O)

---

## 2. Flutter에서 JWT 구현

### 2.1 필요한 패키지

```yaml
# pubspec.yaml
dependencies:
  # 보안 저장소
  flutter_secure_storage: ^9.0.0

  # HTTP 클라이언트 (인터셉터 지원)
  dio: ^5.4.0

  # 라우팅
  go_router: ^14.0.0

  # Google 로그인 (선택사항)
  google_sign_in: ^6.2.0
```

### 2.2 구현 아키텍처

```
┌─────────────────────────────────────────┐
│             Flutter App                 │
├─────────────────────────────────────────┤
│         main.dart (초기화)                │
│              ↓                          │
│         ApiService                      │
│         (Dio + Interceptor)             │
│              ↓                          │
│         TokenManager                    │
│         (Secure Storage)                │
├────────────────────────────────────────-┤
│         각 화면 (Screens)                 │
│    - LoginScreen                        │
│    - ProfileScreen                      │
│    - ExploreScreen 등                   │
└─────────────────────────────────────────┘
```

---

## 3. 프로젝트 구조 설정

### 3.1 폴더 구조

```
lib/
├── main.dart
├── routes/
│   └── routes.dart
├── service/
│   ├── api_service.dart      # API 클라이언트 + 인터셉터
│   ├── auth_service.dart      # 인증 관련 API
│   └── token_manager.dart     # 토큰 관리
├── presentation/
│   └── screens/
│       ├── login_screen.dart
│       ├── profile_screen.dart
│       └── ...
```

---

## 4. 실제 구현 코드

### 4.1 TokenManager - 토큰 관리

```dart
// lib/service/token_manager.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static const storage = FlutterSecureStorage();

  // JWT 토큰 관리
  static Future<void> saveToken(String token) async {
    await storage.write(key: 'jwt_token', value: token);
  }

  static Future<String?> getToken() async {
    return await storage.read(key: 'jwt_token');
  }

  static Future<void> deleteToken() async {
    await storage.delete(key: 'jwt_token');
  }

  // 사용자 정보 관리
  static Future<void> saveMemberId(String memberId) async {
    await storage.write(key: 'member_id', value: memberId);
  }

  static Future<String?> getMemberId() async {
    return await storage.read(key: 'member_id');
  }

  static Future<void> saveUserEmail(String email) async {
    await storage.write(key: 'user_email', value: email);
  }

  static Future<String?> getUserEmail() async {
    return await storage.read(key: 'user_email');
  }

  // 로그인 상태 확인
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // 전체 데이터 삭제 (로그아웃)
  static Future<void> clearAll() async {
    await storage.deleteAll();
  }
}
```

### 4.2 ApiService - API 클라이언트 설정

```dart
// lib/service/api_service.dart
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:market_follower/service/token_manager.dart';
import 'package:flutter/material.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;
  BuildContext? _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://your-api.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // 인터셉터 추가
    _dio.interceptors.add(AuthInterceptor());
  }

  Dio get dio => _dio;
}

// 인터셉터 클래스
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler
  ) async {
    // 인증이 필요없는 엔드포인트 제외
    if (options.path.contains('/login') ||
        options.path.contains('/auth/google')) {
      return handler.next(options);
    }

    // 토큰 자동 첨부
    final token = await TokenManager.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler
  ) async {
    // 401 Unauthorized - 토큰 만료
    if (err.response?.statusCode == 401) {
      await TokenManager.clearAll();

      final context = ApiService()._context;
      if (context != null && context.mounted) {
        context.go('/login');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인이 만료되었습니다. 다시 로그인해주세요.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    return handler.next(err);
  }
}
```

### 4.3 로그인 화면 - 토큰 저장

```dart
// lib/presentation/screens/login_screen.dart
Future<void> _handleGoogleLogin() async {
  try {
    // Google 로그인
    final GoogleSignInAccount? account = await _googleSignIn.signIn();

    if (account != null) {
      final GoogleSignInAuthentication auth = await account.authentication;

      // 백엔드 서버로 토큰 전달
      final response = await AuthService.sendTokenToServer(auth.accessToken);

      if (response['success']) {
        final data = response['data'];

        // JWT 토큰 저장
        if (data['status'] == 'REGISTERED' && data['jwtToken'] != null) {
          await TokenManager.saveToken(data['jwtToken']);

          // 추가 정보 저장
          if (data['memberId'] != null) {
            await TokenManager.saveMemberId(data['memberId'].toString());
          }
          if (data['email'] != null) {
            await TokenManager.saveUserEmail(data['email']);
          }

          // 홈 화면으로 이동
          if (mounted) {
            context.go('/');
          }
        }
      }
    }
  } catch (error) {
    // 에러 처리
  }
}
```

### 4.4 main.dart - 라우트 보호

```dart
// lib/main.dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // API Service 초기화
  ApiService().init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _initializeRouter();
  }

  void _initializeRouter() {
    _router = GoRouter(
      initialLocation: '/',
      redirect: (context, state) async {
        final location = state.matchedLocation;
        final isLoggedIn = await TokenManager.isLoggedIn();

        // 보호된 경로들
        final protectedRoutes = [
          '/home', '/explore', '/profile', '/benefits', '/settings'
        ];

        final isProtectedRoute = protectedRoutes.any(
          (route) => location.startsWith(route)
        );

        // 로그인되지 않은 상태에서 보호된 페이지 접근 시
        if (!isLoggedIn && isProtectedRoute) {
          return '/login?redirect=${Uri.encodeComponent(location)}';
        }

        // 이미 로그인된 상태에서 로그인 페이지 접근 시
        if (isLoggedIn && location == '/login') {
          final redirectTo = state.uri.queryParameters['redirect'];
          return redirectTo != null ?
            Uri.decodeComponent(redirectTo) : '/home';
        }

        return null;
      },
      routes: [...],
    );
  }
}
```

---

## 5. 화면별 적용 예시

### 5.1 프로필 화면 - 사용자 정보 활용

```dart
class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userName;
  String? _userEmail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    // 1. 로컬 저장소에서 빠르게 로드
    final email = await TokenManager.getUserEmail();
    setState(() {
      _userEmail = email;
    });

    // 2. API에서 최신 정보 가져오기 (토큰 자동 첨부)
    try {
      final response = await ApiService().dio.get('/api/user/profile');

      if (response.statusCode == 200) {
        setState(() {
          _userName = response.data['name'];
          _userEmail = response.data['email'];
          _isLoading = false;
        });
      }
    } catch (e) {
      // 에러 처리 (401일 경우 자동으로 로그인 화면으로)
      setState(() {
        _isLoading = false;
      });
    }
  }
}
```

### 5.2 다른 화면에서 API 호출

```dart
// 어떤 화면에서든 간단하게 사용
class ExploreScreen extends StatelessWidget {
  Future<void> loadData() async {
    // 토큰 걱정 없이 그냥 호출!
    final response = await ApiService().dio.get('/api/posts');
    // 401 에러 시 자동으로 로그인 화면으로 이동
  }
}
```

### 5.3 로그아웃 처리

```dart
Future<void> _logout() async {
  try {
    // 1. 서버에 로그아웃 요청 (선택사항)
    await ApiService().dio.post('/api/auth/logout');

    // 2. 로컬 토큰 삭제
    await TokenManager.clearAll();

    // 3. Google 로그아웃 (선택사항)
    await GoogleSignIn().signOut();

    // 4. 로그인 화면으로 이동
    if (mounted) {
      context.go('/login');
    }
  } catch (e) {
    // 에러 처리
  }
}
```

---

## 6. 보안 고려사항

### 6.1 Flutter Secure Storage 사용 이유

| 저장 방식                  | 보안 수준 | 사용 케이스            |
| -------------------------- | --------- | ---------------------- |
| **SharedPreferences**      | 낮음      | 일반 설정값, 테마      |
| **Flutter Secure Storage** | 높음      | 토큰, 비밀번호, API 키 |

Flutter Secure Storage는 다음을 사용합니다:

- **iOS**: Keychain Services
- **Android**: Android Keystore
- **암호화**: AES 암호화 자동 적용

### 6.2 토큰 보안 베스트 프랙티스

```dart
// 좋은 예
await storage.write(key: 'jwt_token', value: token);

// 나쁜 예
SharedPreferences prefs = await SharedPreferences.getInstance();
prefs.setString('jwt_token', token);  // 암호화되지 않음!
```

### 6.3 토큰 만료 시간 설정

```dart
// 서버에서 토큰 발급 시
{
  "exp": Math.floor(Date.now() / 1000) + (60 * 60 * 24)  // 24시간
}

// 클라이언트에서 만료 체크 (선택사항)
bool isTokenExpired(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return true;

  final payload = json.decode(
    utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
  );

  final exp = payload['exp'] as int?;
  if (exp == null) return false;

  return DateTime.now().millisecondsSinceEpoch > exp * 1000;
}
```

### 6.4 Refresh Token 구현 (선택사항)

```dart
class TokenPair {
  final String accessToken;
  final String refreshToken;

  TokenPair({required this.accessToken, required this.refreshToken});
}

// 토큰 갱신 로직
Future<void> refreshAccessToken() async {
  final refreshToken = await TokenManager.getRefreshToken();

  final response = await dio.post('/api/auth/refresh',
    data: {'refreshToken': refreshToken}
  );

  if (response.statusCode == 200) {
    await TokenManager.saveToken(response.data['accessToken']);
  }
}
```

---

## 7. 트러블슈팅

### 7.1 자주 발생하는 문제와 해결책

#### 문제 1: Context가 null일 때

```dart
// 문제
ApiService().setContext(context);  // context가 아직 없음

// 해결
WidgetsBinding.instance.addPostFrameCallback((_) {
  ApiService().setContext(context);
});
```

#### 문제 2: 순환 리다이렉션

```dart
// 문제: 무한 루프
if (!isLoggedIn) return '/login';
if (isLoggedIn && location == '/login') return '/';

// 해결: 명확한 조건 설정
if (!isLoggedIn && isProtectedRoute) {
  return '/login';
}
```

#### 문제 3: 토큰이 헤더에 추가되지 않음

```dart
// 문제: http 패키지 사용
import 'package:http/http.dart' as http;
final response = await http.get(...);  // 인터셉터 작동 안 함

// 해결: Dio 사용
final response = await ApiService().dio.get(...);
```

### 7.2 디버깅 팁

```dart
// 1. 토큰 확인
Future<void> debugToken() async {
  final token = await TokenManager.getToken();
  print('Current token: $token');

  if (token != null) {
    final parts = token.split('.');
    final payload = json.decode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
    );
    print('Token payload: $payload');
  }
}

// 2. 인터셉터 로깅
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(options, handler) async {
    print('> Request: ${options.method} ${options.path}');
    print('> Headers: ${options.headers}');
    handler.next(options);
  }

  @override
  void onResponse(response, handler) {
    print('> Response: ${response.statusCode}');
    handler.next(response);
  }

  @override
  void onError(err, handler) {
    print('> Error: ${err.response?.statusCode} - ${err.message}');
    handler.next(err);
  }
}
```

---

## !체크리스트!

구현 완료 시 확인사항:

- [x] Flutter Secure Storage 패키지 설치
- [x] TokenManager 클래스 구현
- [x] ApiService 및 Interceptor 설정
- [ ] main.dart에서 ApiService 초기화
- [ ] 라우트 보호 로직 구현
- [ ] 로그인 화면에서 토큰 저장
- [ ] 로그아웃 시 토큰 삭제
- [ ] 401 에러 시 자동 리다이렉션
- [ ] 각 화면에서 API 호출 테스트
- [ ] 토큰 만료 시나리오 테스트

---

## 🔗 참고 자료

- [JWT 공식 사이트](https://jwt.io/)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [Dio 패키지](https://pub.dev/packages/dio)
- [GoRouter 패키지](https://pub.dev/packages/go_router)
- [RFC 7519 - JWT 표준](https://datatracker.ietf.org/doc/html/rfc7519)
- [OAuth 2.0 Bearer Token](https://datatracker.ietf.org/doc/html/rfc6750)
