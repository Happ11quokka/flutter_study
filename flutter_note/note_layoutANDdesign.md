# 레이아웃과 디자인

## Column, Row, Expanded

### Column

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,  // 세로축 정렬
  crossAxisAlignment: CrossAxisAlignment.start, // 가로축 정렬
  children: [
    const Text('hi'),
    const Text('danny'),
    // 다른 위젯들...
  ],
)
```

- **Column**: 위젯들을 세로로 배치
- `mainAxisAlignment`: 주축(세로) 정렬 방식
- `crossAxisAlignment`: 교차축(가로) 정렬 방식

### Row

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: const [Text('안녕'), Text('dissuade')],
)
```

- **Row**: 위젯들을 가로로 배치
- Row에서는 주축이 가로, 교차축이 세로

### Expanded

```dart
Row(
  children: const [
    Expanded(flex: 2, child: Text("daany")),  // 2배 크기
    Expanded(child: Text("daany")),          // 기본 크기
    Expanded(child: Text("daany")),          // 기본 크기
  ],
)
```

- **Expanded**: Row나 Column에서 남은 공간을 차지
- `flex`: 비율 설정 (기본값 1)

## Container, SizedBox

### Container

```dart
Container(
  width: 300,
  height: 200,
  alignment: Alignment.center,
  child: const Text('container'),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    color: Colors.blueAccent,
  ),
  margin: EdgeInsets.only(left: 10),
)
```

- **Container**: 가장 다용도로 사용되는 위젯
- `width`, `height`: 크기 설정
- `alignment`: 자식 위젯 정렬
- `decoration`: 꾸미기 (색상, 테두리, 그림자 등)
- `margin`: 외부 여백
- `padding`: 내부 여백

### SizedBox

```dart
// 주석 처리된 코드에서 확인 가능
SizedBox(
  width: 400,
  height: 200,
  child: Text('sizebox'),
)
```

- **SizedBox**: Container의 하위 개념 (실습 메모)
- 단순히 크기만 설정할 때 사용
- Container보다 가벼움
- `color` 속성 없음

## Text, Image, Icon

### Text

```dart
const Text('hi')

// 스타일 적용 예시 (주석 코드 참조)
Text(
  'sizebox',
  style: TextStyle(
    color: Colors.amberAccent,
    fontWeight: FontWeight.bold,
    fontSize: 50,  // 박스 사이즈를 넘어서면 줄 바꿈 발생
  ),
)
```

- **Text**: 텍스트 표시 위젯
- `TextStyle`로 스타일 설정

### Image

```dart
Image.asset('assets/quokka.png', width: 100, height: 100)
```

- **Image.asset**: 앱 내부 이미지 사용
- **중요**: assets 폴더 생성 및 pubspec.yaml 파일 수정 필요
- `width`, `height`로 크기 조절

### Icon

```dart
Icon(Icons.free_breakfast, size: 100)
```

- **Icon**: Flutter에서 기본 제공하는 아이콘
- `width`, `height`가 아닌 `size`로 크기 조절 (실습 메모)
- `Icons.` 으로 다양한 아이콘 사용 가능

## 주요 실습 포인트

1. **SizedBox**: Container의 하위 개념으로 단순한 크기 설정용
2. **Image 사용 시**: assets 폴더 생성 + pubspec.yaml 수정 필수
3. **Icon 크기 조절**: `width`, `height`가 아닌 `size` 사용
4. **텍스트 줄바꿈**: 박스 사이즈를 넘어서면 자동 줄바꿈 발생
