# Dart 프로그래밍 노트

## 1. Hello World와 기본 구조

Dart 프로그램의 시작점은 `main()` 함수입니다. 모든 Dart 애플리케이션은 이 함수에서 실행이 시작됩니다.

```dart
void main() {
print('Hello, World!');
}
```

- `void`: 반환 값이 없음을 의미합니다.
- `main()`: 프로그램의 진입점(entry point)입니다.
- `print()`: 콘솔에 텍스트를 출력하는 함수입니다.

## 2. 변수와 자료형

Dart는 다양한 자료형을 제공합니다. 정적 타입과 동적 타입 모두 지원합니다.

### String

문자열을 나타내는 데이터 타입입니다. 작은따옴표(')나 큰따옴표(")를 사용하여 선언할 수 있습니다.

```dart
String name = 'Dart';
String greeting = "Hello $name"; // 문자열 보간(String interpolation)
```

### int

정수를 나타내는 데이터 타입입니다.

```dart
int age = 30;
int hexValue = 0xDEADBEEF; // 16진수
```

### var

변수의 타입을 명시적으로 선언하지 않고, 초기값에 따라 타입이 자동으로 결정됩니다.

```dart
var name = 'Dart'; // String 타입으로 추론
var age = 30;      // int 타입으로 추론
```

### bool

불리언 값(true/false)을 나타내는 데이터 타입입니다.

```dart
bool isActive = true;
bool isCompleted = false;
```

### double

부동 소수점 숫자를 나타내는 데이터 타입입니다.

```dart
double price = 10.99;
double scientificNotation = 1.42e5; // 142000.0
```

### dynamic type

동적 타입으로, 어떤 타입의 값도 저장할 수 있습니다. 타입이 런타임에 결정됩니다.

```dart
dynamic value = 'Hello';
value = 42;       // 문자열에서 정수로 타입 변경 가능
value = true;     // 정수에서 불리언으로 타입 변경 가능
```

## 3. Null Safety

Dart 2.12부터 도입된 Null Safety는 null 참조 오류를 컴파일 시점에서 방지하는 기능입니다.

### 기본 사용법

- 기본적으로 변수는 null이 될 수 없으며, null을 허용하려면 타입 뒤에 `?`를 붙여야 합니다.

```dart
String name = 'Dart';     // null이 될 수 없음
String? nullableName = 'Flutter'; // null이 될 수 있음
nullableName = null;      // 가능
```

### null 접근

- Null이 될 수 있는 변수의 메서드나 프로퍼티에 접근할 때 `?`를 사용합니다.

```dart
String? name = 'Dart';
print(name?.length);  // name이 null이 아니면 길이를 출력, null이면 null 출력
```

### 널 합류 연산자 (`??`)

- 값이 null인 경우 대체 값을 제공합니다.

```dart
String? name;
String displayName = name ?? 'Guest'; // name이 null이면 'Guest' 사용
```

### late 키워드

- 변수를 선언할 때 초기화하지 않고, 나중에 값을 할당할 수 있게 합니다.
- 사용 전에 반드시 초기화해야 합니다.

```dart
late String username;
// 이후 로직에서
username = 'dart_user'; // 초기화
print(username); // 정상 작동
```

## 4. final과 const

### final

- 한 번 값이 할당되면 변경할 수 없는 변수를 선언합니다.
- 런타임에 값이 결정될 수 있습니다.

```dart
final String name = 'Dart';
// name = 'Flutter'; // 오류: final 변수는 한 번만 할당 가능

final currentTime = DateTime.now(); // 런타임에 값 결정 가능
```

### const

- 컴파일 시점에 값이 결정되는 상수를 선언합니다.
- 반드시 선언과 동시에 초기화해야 합니다.

```dart
const double pi = 3.14159;
// pi = 3.14; // 오류: const 변수는 한 번만 할당 가능

// const currentTime = DateTime.now(); // 오류: 컴파일 시점에 값을 알 수 없음
const daysInWeek = 7; // 컴파일 시점에 값을 알 수 있는 상수
```

## 5. 연산자와 표현식

Dart는 다양한 연산자를 제공합니다. 연산 시 데이터 타입에 주의해야 합니다.

### 산술 연산자

- 기본적인 수학 연산을 수행합니다.

```dart
int a = 10;
int b = 3;

print(a + b);  // 덧셈: 13
print(a - b);  // 뺄셈: 7
print(a * b);  // 곱셈: 30
print(a / b);  // 나눗셈: 3.3333333333333335 (결과는 double)
print(a ~/ b); // 정수 나눗셈: 3 (소수점 버림)
print(a % b);  // 나머지: 1
```

### 비교 연산자

- 두 값을 비교하여 불리언 값을 반환합니다.

```dart
int a = 10;
int b = 5;

print(a == b); // 같음: false
print(a != b); // 다름: true
print(a > b);  // 초과: true
print(a < b);  // 미만: false
print(a >= b); // 이상: true
print(a <= b); // 이하: false
```

### 논리 연산자

- 불리언 값을 조합합니다.

```dart
bool x = true;
bool y = false;

print(x && y); // AND: false (둘 다 true일 때만 true)
print(x || y); // OR: true (하나라도 true면 true)
print(!x);     // NOT: false (불리언 값 반전)
```

### 할당 연산자

- 변수에 값을 할당합니다.

```dart
int a = 10;
a += 5; // a = a + 5와 동일: 15
a -= 3; // a = a - 3와 동일: 12
a *= 2; // a = a * 2와 동일: 24
a ~/= 4; // a = a ~/ 4와 동일: 6 (정수 나눗셈)
```

### 조건 연산자 (3항 연산자)

- 조건에 따라 다른 값을 반환합니다.

```dart
int a = 10;
int b = 5;

String result = a > b ? 'a가 더 큽니다' : 'b가 더 크거나 같습니다';
print(result); // "a가 더 큽니다"

int min = a < b ? a : b;
print(min); // 5
```

## 6. 제어문 - 조건문, 반복문

### if-else 문

- 조건에 따라 코드 블록을 실행합니다.

```dart
int score = 85;

if (score >= 90) {
print('A 등급');
} else if (score >= 80) {
print('B 등급'); // 이 코드 블록이 실행됨
} else if (score >= 70) {
print('C 등급');
} else {
print('D 등급');
}
```

### switch 문

- 표현식의 값에 따라 다른 코드 블록을 실행합니다.

```dart
String grade = 'B';

switch (grade) {
case 'A':
print('우수한 성적입니다.');
break;
case 'B':
print('좋은 성적입니다.'); // 이 코드 블록이 실행됨
break;
case 'C':
print('평균적인 성적입니다.');
break;
default:
print('잘못된 등급입니다.');
}
```

### for 반복문

- 일정한 범위 내에서 반복 작업을 수행합니다.

```dart
// 기본 for 반복문
for (int i = 0; i < 5; i++) {
print('반복 $i'); // String interpolation 사용
}

// 리스트를 순회하는 for-in 반복문
List<String> fruits = ['사과', '바나나', '체리'];
for (String fruit in fruits) {
print('과일: $fruit');
}
```

### while 반복문

- 조건이 참인 동안 반복해서 코드 블록을 실행합니다.

```dart
// while 반복문
int count = 0;
while (count < 3) {
print('count: $count');
count++;
}

// do-while 반복문 (조건 확인 전에 최소 한 번은 실행)
int num = 0;
do {
print('num: $num');
num++;
} while (num < 3);
```

## 7. List와 Map

### List

- 순서가 있는 데이터 컬렉션으로, 인덱스를 통해 요소에 접근할 수 있습니다.

```dart
// 빈 리스트 생성
List<int> numbers = [];

// 데이터가 있는 리스트
List<int> numbers2 = [1, 2, 3, 4, 5];

// 리스트 요소 접근
print(numbers2[0]); // 첫 번째 요소: 1
print(numbers2[2]); // 세 번째 요소: 3

// 리스트 요소 추가
numbers.add(10);
numbers.add(20);
print(numbers); // [10, 20]

// 리스트 요소 제거
numbers.removeAt(0); // 인덱스 0의 요소(10) 제거
print(numbers); // [20]

// 리스트 순회
List<String> fruits = ['사과', '바나나', '체리'];
for (int i = 0; i < fruits.length; i++) {
print('과일 $i: ${fruits[i]}');
}

// forEach를 사용한 리스트 순회
fruits.forEach((fruit) {
print('과일: $fruit');
});
```

### Map

- 키(key)와 값(value)으로 구성된 데이터 컬렉션입니다.

```dart
// 빈 Map 생성
Map<String, int> scoreMap = {};

// 데이터가 있는 Map
Map<String, int> scores = {
'수학': 90,
'영어': 85,
'과학': 95,
};

// Map 요소 접근
print(scores['수학']); // 90

// Map 요소 추가/수정
scoreMap['국어'] = 88;
scoreMap['영어'] = 92;
print(scoreMap); // {국어: 88, 영어: 92}

// Map 요소 제거
scores.remove('영어');
print(scores); // {수학: 90, 과학: 95}

// Map 순회 - forEach 사용
scores.forEach((subject, score) {
print('$subject: $score점');
});

// Map 순회 - entries 사용
for (var entry in scores.entries) {
print('${entry.key}: ${entry.value}점');
}

// Map의 키만 순회
for (var subject in scores.keys) {
print('과목: $subject');
}

// Map의 값만 순회
for (var score in scores.values) {
print('점수: $score');
}
```

## 8. 함수와 메서드

### 함수(Function)

- 코드의 논리를 분리하고 재사용성을 높이는 기능입니다.
- 함수는 이름, 파라미터, 반환 타입으로 구성됩니다.

```dart
// 기본 함수
int add(int a, int b) {
return a + b;
}

// 함수 호출
int result = add(5, 3);
print(result); // 8

// 반환 값이 없는 함수
void greet(String name) {
print('안녕하세요, $name님!');
}

// 함수 호출
greet('다트'); // "안녕하세요, 다트님!"

// 화살표 함수(Arrow Function) - 한 줄로 표현 가능한 함수
int multiply(int a, int b) => a * b;
print(multiply(4, 5)); // 20
```

### 메서드(Method)

- 클래스 내부에서 정의된 함수를 메서드라고 합니다.

```dart
class Calculator {
// 메서드
int add(int a, int b) {
return a + b;
}

// 화살표 메서드
int subtract(int a, int b) => a - b;
}

// 클래스 인스턴스 생성
Calculator calc = Calculator();

// 메서드 호출
print(calc.add(10, 5));     // 15
print(calc.subtract(10, 5)); // 5
```

## 9. Positional Parameter와 Named Parameter

### Positional Parameter

- 함수 호출 시 인자의 순서에 따라 파라미터에 값이 할당됩니다.

```dart
// Positional Parameter를 사용하는 함수
String formatName(String firstName, String lastName) {
return '$lastName $firstName';
}

// 함수 호출
print(formatName('길동', '홍')); // "홍 길동"

// 선택적 Positional Parameter ([] 사용)
String greet(String name, [String title = '']) {
return '안녕하세요, ${title.isEmpty ? '' : '$title '}$name님!';
}

print(greet('길동'));        // "안녕하세요, 길동님!"
print(greet('길동', '과장')); // "안녕하세요, 과장 길동님!"
```

### Named Parameter

- 함수 호출 시 파라미터 이름을 명시적으로 지정합니다.
- 순서에 관계없이 인자를 전달할 수 있습니다.

```dart
// Named Parameter를 사용하는 함수 ({} 사용)
String formatPerson({String? name, int? age}) {
return '이름: $name, 나이: $age';
}

// 함수 호출
print(formatPerson(name: '홍길동', age: 30)); // "이름: 홍길동, 나이: 30"
print(formatPerson(age: 25, name: '김철수')); // "이름: 김철수, 나이: 25"

// required 키워드를 사용한 필수 Named Parameter
String introduceUser({required String name, required int age}) {
return '$name은(는) $age세입니다.';
}

print(introduceUser(name: '홍길동', age: 30)); // "홍길동은(는) 30세입니다."
// print(introduceUser(name: '홍길동')); // 오류: 'age' 파라미터가 필요합니다.
```

## 10. Class와 상속

### Class

- 객체를 생성하기 위한 템플릿 또는 설계도입니다.
- 상태(멤버 변수), 생성자, 행동(메서드)으로 구성됩니다.

```dart
class Person {
// 멤버 변수(상태)
String name;
int age;

// 생성자
Person(this.name, this.age);

// 메서드(행동)
void introduce() {
print('안녕하세요, 저는 $name이고 $age세입니다.');
}

String getDescription() {
return '$name, $age세';
}
}

// 클래스 인스턴스 생성
Person person = Person('홍길동', 30);

// 멤버 변수 접근
print(person.name); // "홍길동"
print(person.age);  // 30

// 메서드 호출
person.introduce();   // "안녕하세요, 저는 홍길동이고 30세입니다."
print(person.getDescription()); // "홍길동, 30세"
```

### 상속

- 기존 클래스의 특성을 다른 클래스에서 재사용하고 확장하는 메커니즘입니다.
- 상위 클래스(부모 클래스)와 하위 클래스(자식 클래스) 간에 상속 관계가 형성됩니다.

```dart
// 부모 클래스
class Animal {
String name;

Animal(this.name);

void makeSound() {
print('동물 소리');
}

String getInfo() {
return '이 동물의 이름은 $name입니다.';
}
}

// 자식 클래스
class Dog extends Animal {
String breed;

// super를 사용하여 부모 클래스의 생성자 호출
Dog(String name, this.breed) : super(name);

// 메서드 오버라이드
@override
void makeSound() {
print('멍멍!');
}

@override
String getInfo() {
return '${super.getInfo()} 품종은 $breed입니다.';
}

// 자식 클래스에만 있는 메서드
void fetch() {
print('$name이(가) 공을 가져옵니다.');
}
}

// 인스턴스 생성
Animal animal = Animal('일반동물');
Dog dog = Dog('바둑이', '진돗개');

// 메서드 호출
animal.makeSound(); // "동물 소리"
dog.makeSound();    // "멍멍!"

print(animal.getInfo()); // "이 동물의 이름은 일반동물입니다."
print(dog.getInfo());    // "이 동물의 이름은 바둑이입니다. 품종은 진돗개입니다."

dog.fetch(); // "바둑이이(가) 공을 가져옵니다."
```

## 11. 생성자와 선택적 매개변수

### 생성자(Constructor)

- 클래스의 인스턴스를 초기화하는 특별한 메서드입니다.
- 클래스가 생성될 때 가장 먼저 호출됩니다.

```dart
class User {
String username;
int age;

// 기본 생성자
User(this.username, this.age);

// 기본 생성자는 생략 가능하며, 자동으로 생성됩니다.
// 그 이유는 Dart가 자동으로 매개변수 없는 생성자를 제공하기 때문입니다.
}

// 인스턴스 생성
User user = User('user123', 25);
```

### 여러 형태의 생성자

```dart
class Product {
String name;
double price;
String? description;

// 기본 생성자
Product(this.name, this.price, [this.description]);

// Named 생성자
Product.withoutDescription(this.name, this.price) : description = null;

// Named 파라미터를 사용하는 생성자
Product.fromMap({
required this.name,
required this.price,
this.description,
});

// 팩토리 생성자
factory Product.create(String name, double price) {
return Product(name, price, '새 제품');
}
}

// 다양한 방식으로 인스턴스 생성
Product p1 = Product('노트북', 1200000, '고성능 노트북');
Product p2 = Product.withoutDescription('키보드', 80000);
Product p3 = Product.fromMap(name: '마우스', price: 35000, description: '무선 마우스');
Product p4 = Product.create('모니터', 350000);
```

### 선택적 매개변수

- Named 파라미터를 활용한 선택적 매개변수

```dart
class Car {
String brand;
String model;
int? year;
String? color;

// Named 파라미터와 required 키워드 활용
Car({
required this.brand,
required this.model,
this.year,
this.color,
});

String getInfo() {
return '$year년식 $color $brand $model';
}
}

// 인스턴스 생성
Car car1 = Car(
brand: '현대',
model: '아반떼',
year: 2023,
color: '검정',
);

Car car2 = Car(
brand: '기아',
model: 'K5',
// year와 color는 선택적 파라미터이므로 생략 가능
);

print(car1.getInfo()); // "2023년식 검정 현대 아반떼"
print(car2.getInfo()); // "null년식 null 기아 K5"
```

## 12. Enum 타입

### 열거형(Enum)

- 미리 정의된 값만 가질 수 있는 특별한 타입입니다.
- 상수 그룹을 정의할 때 자주 사용됩니다.

```dart
// 기본 enum 정의
enum Color {
red,
green,
blue,
yellow,
}

// enum 사용
Color selectedColor = Color.blue;

// switch와 함께 사용
switch (selectedColor) {
case Color.red:
print('빨간색 선택됨');
break;
case Color.green:
print('초록색 선택됨');
break;
case Color.blue:
print('파란색 선택됨'); // 이 코드 블록이 실행됨
break;
case Color.yellow:
print('노란색 선택됨');
break;
}

// enum의 values 속성으로 모든 값 접근
for (var color in Color.values) {
print(color);
}
```

### Enum Class (Dart 2.17 이상)

- 향상된 enum 기능을 제공합니다.

```dart
// Dart 2.17 이상에서 지원하는 향상된 enum
enum Status {
pending(0, '대기 중'),
inProgress(1, '진행 중'),
completed(2, '완료됨'),
cancelled(3, '취소됨');

// 속성
final int code;
final String description;

// 생성자
const Status(this.code, this.description);

// 메서드
bool isFinished() {
return this == Status.completed || this == Status.cancelled;
}
}

// 사용 예시
Status currentStatus = Status.inProgress;
print(currentStatus.code);        // 1
print(currentStatus.description); // "진행 중"
print(currentStatus.isFinished()); // false

// 완료 상태로 변경
currentStatus = Status.completed;
print(currentStatus.isFinished()); // true
```

## 13. Future, await를 활용한 비동기 프로그래밍

### 동기와 비동기

- 동기(Synchronous): 작업이 순차적으로 실행됩니다.
- 비동기(Asynchronous): 작업이 순차적으로 실행되지 않으며, 동시에 여러 작업이 실행될 수 있습니다.

```dart
// 동기 코드 예시
void syncExample() {
print('시작');
// 5초 동안 실행을 멈춤 (동기 방식)
// sleep(Duration(seconds: 5)); // 실제로는 'dart:io' 임포트 필요
print('5초 후');
print('종료');
}

// 비동기 코드 예시
Future<void> asyncExample() async {
print('시작');
// 5초 동안 대기 (비동기 방식)
await Future.delayed(Duration(seconds: 5));
print('5초 후');
print('종료');
}
```

### Future, async, await

- `Future<T>`: 비동기 작업의 결과를 나타내는 클래스입니다.
- `async`: 함수가 비동기 함수임을 선언합니다.
- `await`: Future 작업이 완료될 때까지 기다립니다.

```dart
// Future를 반환하는 함수
Future<String> fetchUserData() {
return Future.delayed(Duration(seconds: 2), () {
return '{"name": "홍길동", "age": 30}';
});
}

// async와 await를 사용하는 함수
Future<void> processUserData() async {
print('사용자 데이터 요청 중...');

// await로 Future 작업이 완료될 때까지 기다림
String userData = await fetchUserData();

print('사용자 데이터 수신: $userData');

// 추가 비동기 작업
await Future.delayed(Duration(seconds: 1));
print('데이터 처리 완료');
}

// 비동기 함수 호출
void main() async {
print('프로그램 시작');
await processUserData();
print('프로그램 종료');
}
```

### then을 사용한 비동기 처리

```dart
// then을 사용한 비동기 처리
void usingThen() {
print('데이터 요청 중...');

fetchUserData().then((userData) {
print('사용자 데이터 수신: $userData');
return Future.delayed(Duration(seconds: 1));
}).then((_) {
print('데이터 처리 완료');
}).catchError((error) {
print('오류 발생: $error');
}).whenComplete(() {
print('작업 완료 (성공 또는 실패)');
});

print('요청 후 즉시 실행됨');
}
```

### 여러 비동기 작업 처리

```dart
Future<void> multipleAsyncTasks() async {
print('여러 비동기 작업 시작');

// 순차적 실행
String data1 = await fetchData('데이터1');
String data2 = await fetchData('데이터2');
print('순차 실행 결과: $data1, $data2');

// 병렬 실행
List<String> results = await Future.wait([
fetchData('병렬1'),
fetchData('병렬2'),
fetchData('병렬3'),
]);

print('병렬 실행 결과: $results');
}

Future<String> fetchData(String name) {
return Future.delayed(
Duration(seconds: 1),
() => '${name}의 데이터',
);
}
```

### 오류 처리

```dart
Future<void> errorHandlingExample() async {
try {
print('비동기 작업 시작');
String result = await fetchWithError();
print('결과: $result'); // 이 코드는 실행되지 않음
} catch (e) {
print('오류 발생: $e');
} finally {
print('항상 실행되는 코드');
}
}

Future<String> fetchWithError() {
return Future.delayed(
Duration(seconds: 2),
() => throw Exception('네트워크 오류 발생'),
);
}
```
