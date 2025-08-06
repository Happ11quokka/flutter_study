# 상태 관리 기초

## setState 메서드로 위젯 업데이트 하기

Flutter에서 위젯의 상태를 업데이트하려면 `setState()` 메서드를 사용해야 합니다. 이 메서드를 통해 위젯의 상태가 변경되었음을 Flutter 프레임워크에 알리고, UI를 다시 그리도록 요청합니다.

### 기본 개념

1. **StatefulWidget**: 상태를 가지는 위젯으로, 데이터가 변경될 때 화면이 업데이트되어야 하는 경우 사용합니다.
2. **State 클래스**: 위젯의 상태를 관리하며, `setState()` 메서드를 통해 상태 변경을 처리합니다.
3. **setState()**: UI에 표시되는 값을 변경할 때 반드시 이 메서드 내에서 변경해야 합니다.

### 코드 예제

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
  String msg = '이 곳에 입력 값이 업데이트 됩니다.';
  ValueNotifier<int> counter = ValueNotifier<int>(0);

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
                setState(() {
                  // widget update
                  msg = idealcontroller.text.toString(); // 밖에서 있어도 되지만 비효율적
                });
                counter.value = 30;
                // 클릭시 동작 구현
                // msg = idealcontroller.text.toString(); 이러면 안됨 그래서 setstate 사용
              },
              child: Text('입력 확인'),
            ),
            ValueListenableBuilder<int>(valueListenable: counter, builder: (context, value, child){
              return Text('count: $value');
            }),
            Text(msg, style: TextStyle(fontSize: 30)),
          ],
        ),
      ),
    );
  }
}
```

### setState() 메서드의 중요성

`setState()` 메서드는 Flutter 프레임워크에 위젯의 내부 상태가 변경되었음을 알려주는 역할을 합니다. 이 메서드를 호출하면:

1. State 객체에 변경이 있음을 Flutter에 알립니다.
2. Flutter는 해당 State와 연결된 위젯의 `build()` 메서드를 다시 호출합니다.
3. UI가 새로운 상태를 반영하여 다시 렌더링됩니다.

```dart
// 잘못된 방법 - UI가 업데이트되지 않음
onPressed: () {
  msg = idealcontroller.text.toString();  // UI에 반영되지 않음
}

// 올바른 방법 - setState() 내에서 상태 변경
onPressed: () {
  setState(() {
    msg = idealcontroller.text.toString();  // UI에 반영됨
  });
}
```

### 주의사항

- `setState()`를 호출하면 전체 `build()` 메서드가 다시 실행되므로, 필요한 부분만 업데이트하는 것이 성능상 유리합니다.
- 모든 상태 변경이 `setState()` 내에서 이루어져야 하는 것은 아닙니다. UI에 영향을 주지 않는 내부 로직 변경은 `setState()` 없이도 가능합니다.
- `setState()` 내에서는 가능한 최소한의 상태 변경만 수행하는 것이 좋습니다.

## 고급 상태 관리: ValueNotifier와 ValueListenableBuilder

위 예제에서는 `setState()` 외에도 또 다른 상태 관리 방식을 사용하고 있습니다.

### ValueNotifier

`ValueNotifier`는 값의 변경을 감지하고 이를 구독자에게 알릴 수 있는 클래스입니다.

```dart
ValueNotifier<int> counter = ValueNotifier<int>(0);  // 초기값 0
```

값을 변경할 때는 다음과 같이 합니다:

```dart
counter.value = 30;  // 값 변경
```

### ValueListenableBuilder

`ValueListenableBuilder`는 `ValueNotifier`의 값 변경을 감지하고 UI를 업데이트하는 위젯입니다.

```dart
ValueListenableBuilder<int>(
  valueListenable: counter,  // 감시할 ValueNotifier
  builder: (context, value, child) {
    return Text('count: $value');  // 변경된 값으로 UI 구성
  }
)
```

### setState와 ValueNotifier 비교

| 특성      | setState            | ValueNotifier                 |
| --------- | ------------------- | ----------------------------- |
| 범위      | 전체 위젯           | 특정 값만                     |
| 재빌드    | 전체 build() 메서드 | ValueListenableBuilder 내부만 |
| 사용 상황 | 간단한 상태 관리    | 특정 값만 관찰할 때           |
| 성능      | 상대적으로 낮음     | 상대적으로 높음               |

## 상태 관리 모범 사례

1. **적절한 위치에서 상태 관리**: 상태를 사용하는 가장 가까운 공통 조상 위젯에서 상태를 관리합니다.
2. **최소 상태 원칙**: 필요한 최소한의 상태만 관리하고, 나머지는 계산하여 사용합니다.
3. **성능 고려**: 빈번한 상태 변경이 있는 경우 `setState()`보다 `ValueNotifier`나 다른 상태 관리 솔루션을 고려합니다.
4. **상태 격리**: 독립적인 상태는 서로 분리하여 관리합니다.

## 기타 상태 관리 솔루션

Flutter에서는 복잡한 애플리케이션을 위한 다양한 상태 관리 솔루션을 제공합니다:

- **Provider**: 간단하고 효율적인 의존성 주입 및 상태 관리 라이브러리
- **Bloc/Cubit**: 비즈니스 로직과 UI를 분리하는 패턴
- **GetX**: 상태 관리, 라우팅, 의존성 주입을 포함한 경량 솔루션
- **Riverpod**: Provider의 개선된 버전
- **Redux**: 예측 가능한 상태 컨테이너

이러한 고급 상태 관리 솔루션은 애플리케이션이 복잡해질수록 더 유용해집니다.

## 정리

- UI를 업데이트하려면 `setState()`를 사용하여 상태 변경을 Flutter에 알려야 합니다.
- 모든 상태 변경을 `setState()` 내에서 할 필요는 없지만, UI에 반영되어야 하는 변경은 반드시 `setState()` 내에서 해야 합니다.
- 특정 값만 관찰하려면 `ValueNotifier`와 `ValueListenableBuilder`를 사용하는 것이 효율적입니다.
- 애플리케이션이 복잡해지면 고급 상태 관리 솔루션을 고려해야 합니다.
  </artifact>

제가 Flutter의 상태 관리에 대한 마크다운 노트를 작성했습니다. 귀하께서 제공해 주신 코드와 설명을 모두 포함했으며, 추가적인 중요 정보와 개념들을 더했습니다.

노트에는 다음과 같은 내용이 포함되어 있습니다:

1. **setState 메서드의 기본 개념과 중요성**

   - 왜 직접 변수를 변경하는 것이 아닌 setState를 사용해야 하는지
   - 코드에서 언급된 "이러면 안됨 그래서 setstate 사용"에 대한 자세한 설명

2. **ValueNotifier와 ValueListenableBuilder**

   - 코드에서 사용된 counter 변수와 ValueListenableBuilder 위젯에 대한 설명
   - setState와 ValueNotifier의 차이점과 장단점 비교표

3. **상태 관리 모범 사례**

   - 효율적인 상태 관리를 위한 권장 사항

4. **추가 상태 관리 솔루션**
   - Flutter에서 사용할 수 있는 다른 상태 관리 방법들 소개

마크다운 형식으로 정리하여 코드 블록, 표, 제목 등을 적절히 사용했습니다. 혹시 더 추가하거나 수정하고 싶은 내용이 있으시면 말씀해 주세요!
