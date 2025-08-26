# Flutter BuildContext Async Gap 문제 및 해결 방안

## 문제 설명: Don't use 'BuildContext's across async gaps

Flutter에서는 BuildContext를 async 함수 내에서 **await 뒤에 사용하는 것**을 지양합니다.

### 발생 원인

- `await` 이후에 위젯 트리가 바뀔 수 있습니다 (예: 해당 위젯이 dispose됨)
- 이 상태에서 BuildContext를 사용하면 **정의되지 않은 동작(undefined behavior)** 또는 **crash**가 발생할 수 있습니다

### 잘못된 예시

```dart
// ❌ 위험한 사용법
onPressed: () async {
  await Future.delayed(Duration(seconds: 1));
  ScaffoldMessenger.of(context).showSnackBar(...); // 위험!
}
```

---

## Flutter 권장 해결 방식

Flutter 공식 Lint(`use_build_context_synchronously`)는 **await 작업 전에 context 관련 객체를 미리 캡처**하는 방식을 권장합니다.

### 패턴 1: ScaffoldMessenger 사용 시

```dart
onPressed: () async {
  final messenger = ScaffoldMessenger.of(context); // ✅ await 전에 캡처
  await Future.delayed(Duration(seconds: 1));
  if (!mounted) return; // mounted 체크
  messenger.showSnackBar(
    SnackBar(content: Text('작업 완료!')),
  );
}
```

### 패턴 2: GoRouter를 통한 이동 시

```dart
onPressed: () async {
  final goRouter = GoRouter.of(context); // ✅ await 전에 캡처
  await Future.delayed(Duration(seconds: 1));
  if (!mounted) return; // mounted 체크
  goRouter.go('/login');
}
```

### 패턴 3: Navigator 사용 시

```dart
onPressed: () async {
  final navigator = Navigator.of(context); // ✅ await 전에 캡처
  await someAsyncOperation();
  if (!mounted) return; // mounted 체크
  navigator.pop();
}
```

---

## 실제 적용 사례

### Before (문제 있는 코드)

```dart
onChanged: (value) async {
  await SettingsService.setPushNotifications(value);
  if (mounted) {
    // ❌ async gap 이후 context 사용
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('설정이 저장되었습니다')),
    );
  }
}
```

### After (수정된 코드)

```dart
onChanged: (value) async {
  final messenger = ScaffoldMessenger.of(context); // ✅ 먼저 캡처
  await SettingsService.setPushNotifications(value);
  if (!mounted) return; // mounted 체크
  messenger.showSnackBar(
    SnackBar(content: Text('설정이 저장되었습니다')),
  ); // ✅ 안전하게 사용
}
```

---

## 왜 이렇게 해야 하는가?

| 이유                    | 설명                                                                              |
| ----------------------- | --------------------------------------------------------------------------------- |
| **위젯 생명 주기 보호** | `await` 동안 해당 위젯이 dispose될 수 있기 때문에, 이후 context 사용은 위험함     |
| **안정적인 UI 동작**    | context가 유효하지 않은 상태에서의 접근은 런타임 오류 가능성이 높음               |
| **Linter 경고 해결**    | `use_build_context_synchronously` Lint를 준수하면 더 안전한 코드를 작성할 수 있음 |
| **메모리 누수 방지**    | 이미 dispose된 위젯에서 context를 사용하는 것을 방지                              |

---

## 체크리스트

async 함수에서 BuildContext를 사용할 때 다음을 확인하세요:

- [ ] `await` 전에 필요한 context 관련 객체들을 캡처했는가?
- [ ] `await` 후에 `mounted` 체크를 했는가?
- [ ] context 대신 캡처한 객체를 사용하고 있는가?
- [ ] Linter 경고가 해결되었는가?

---

## 추가 팁

### 1. StatefulWidget에서 mounted 속성 활용

```dart
if (!mounted) return; // 위젯이 여전히 활성 상태인지 확인
```

### 2. 복잡한 경우 별도 메서드로 분리

```dart
Future<void> _handleAsyncOperation() async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);

  await someAsyncOperation();

  if (!mounted) return;

  messenger.showSnackBar(...);
  navigator.pop();
}
```

### 3. 에러 처리도 함께 고려

```dart
onPressed: () async {
  final messenger = ScaffoldMessenger.of(context);

  try {
    await riskyAsyncOperation();
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(content: Text('성공!')));
  } catch (e) {
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(content: Text('오류: $e')));
  }
}
```

---

## 참고 자료

- [Flutter 공식 문서: use_build_context_synchronously](https://dart-lang.github.io/linter/lints/use_build_context_synchronously.html)
- [Flutter 위젯 생명주기](https://docs.flutter.dev/development/ui/widgets-intro#widget-lifecycle)
- [StatefulWidget mounted 속성](https://api.flutter.dev/flutter/widgets/State/mounted.html)
