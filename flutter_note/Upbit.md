# Upbit 데이터 처리 노트

---

## 1. 데이터 모델 정의

### 1.1 CoinTicker 모델 구조

```dart
class CoinTicker {
  // 기본 시장 정보
  final String market;           // "KRW-BTC", "USDT-ETH" 등
  final String change;           // "RISE", "FALL", "EVEN"

  // 가격 정보
  final double tradePrice;       // 현재가
  final double openingPrice;     // 시가
  final double highPrice;        // 고가
  final double lowPrice;         // 저가
  final double prevClosingPrice; // 전일 종가

  // 변동 정보
  final double changePrice;      // 변동가격 (절대값)
  final double changeRate;       // 변동률 (0.01 = 1%)
  final double signedChangePrice; // 부호 포함 변동가격
  final double signedChangeRate;  // 부호 포함 변동률

  // 거래 정보
  final double tradeVolume;      // 최근 거래량
  final double accTradePrice;    // 누적 거래대금
  final double accTradePrice24h; // 24시간 누적 거래대금
  final double accTradeVolume;   // 누적 거래량
  final double accTradeVolume24h; // 24시간 누적 거래량

  // 52주 정보
  final double highest52WeekPrice; // 52주 최고가
  final String highest52WeekDate;  // 52주 최고가 날짜
  final double lowest52WeekPrice;  // 52주 최저가
  final String lowest52WeekDate;   // 52주 최저가 날짜

  // 시간 정보
  final String tradeDate;        // 거래일 (YYYYMMDD)
  final String tradeTime;        // 거래시간 (HHMMSS)
  final String tradeDateKst;     // 한국시간 거래일
  final String tradeTimeKst;     // 한국시간 거래시간
  final int tradeTimestamp;      // 거래 타임스탬프
  final int timestamp;           // 응답 타임스탬프
}
```

### 1.2 데이터 파싱 및 변환

```dart
// JSON → CoinTicker 객체 변환
factory CoinTicker.fromJson(Map<String, dynamic> json) {
  return CoinTicker(
    market: json['market'] ?? '',
    change: json['change'] ?? 'EVEN',
    tradePrice: (json['trade_price'] ?? 0.0).toDouble(),
    changeRate: (json['change_rate'] ?? 0.0).toDouble(),
    // ... 모든 필드 파싱
  );
}

// 계산된 속성들
String get baseCurrency => market.split('-')[0];     // "KRW", "BTC", "USDT"
String get coinSymbol => market.split('-')[1];       // "BTC", "ETH", "XRP"
bool get isPositiveChange => change == 'RISE';
bool get isNegativeChange => change == 'FALL';
bool get isEvenChange => change == 'EVEN';
```

### 1.3 데이터 포맷팅

```dart
// 가격 포맷팅 (화폐별 맞춤)
String get formattedPrice {
  if (baseCurrency == 'KRW') {
    if (tradePrice >= 1000) {
      return '${_formatNumber(tradePrice)} KRW';      // "1,234,567 KRW"
    } else {
      return '${tradePrice.toStringAsFixed(4)} KRW';  // "0.1234 KRW"
    }
  } else if (baseCurrency == 'BTC') {
    return '${tradePrice.toStringAsFixed(8)} BTC';    // "0.00001234 BTC"
  }
  // USDT, 기타 화폐 처리...
}

// 변동률 포맷팅
String get formattedChangeRate {
  if (isEvenChange) return '0.00%';
  final sign = isPositiveChange ? '+' : '';
  return '$sign${(signedChangeRate * 100).toStringAsFixed(2)}%';
}
```

---

## 2. API 서비스 구조

### 2.1 ApiService 싱글톤 패턴

```dart
class ApiService {
  // 싱글톤 인스턴스
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // HTTP 클라이언트 (Dio)
  late final Dio _dio;
  BuildContext? _context;
}
```

### 2.2 HTTP API 엔드포인트

```dart
// 서버 URL
baseUrl: 'http://ec2-4~~~~~amazonaws.com:8080'

// API 엔드포인트들
GET  /market/ticker/all        // 전체 코인 시세
GET  /market/ticker/{market}   // 개별 코인 시세
```

### 2.3 REST API 데이터 로딩

```dart
// 전체 코인 시세 가져오기
Future<List<CoinTicker>> getAllTickers() async {
  try {
    final response = await _dio.get('/market/ticker/all');

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => CoinTicker.fromJson(json)).toList();
    }
    return [];
  } catch (e) {
    debugPrint('전체 시세 가져오기 실패: $e');
    return [];
  }
}

// 특정 코인 시세 가져오기
Future<CoinTicker?> getTickerByMarket(String market) async {
  try {
    final response = await _dio.get('/market/ticker/$market');

    if (response.statusCode == 200) {
      return CoinTicker.fromJson(response.data);
    }
    return null;
  } catch (e) {
    debugPrint('개별 시세 가져오기 실패: $e');
    return null;
  }
}
```

---

### 3 상태 업데이트 패턴

```dart
// 안전한 상태 업데이트 패턴
void _updateData(List<CoinTicker> newTickers) {
  if (mounted) {  // Widget이 여전히 활성 상태인지 확인
    setState(() {
      _allTickers = newTickers;
      _filterTickers();  // 필터 적용
    });
  }
}

// 에러 상태 업데이트
void _setError(String error) {
  if (mounted) {
    setState(() {
      _errorMessage = error;
      _isLoading = false;
    });
  }
}
```

### 4 라이프사이클 관리

```dart
@override
void dispose() {
  _tabController.dispose();           // TabController 정리
  _searchController.dispose();        // TextEditingController 정리
  super.dispose();
}
```

---

## 5. 데이터 로딩 및 새로고침

### 5.1 초기 데이터 로딩

```dart
Future<void> _loadInitialData() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    // 병렬로 여러 API 호출
    final futures = await Future.wait([
      _apiService.getAllTickers(),
      _apiService.getTickerByMarket('KRW-BTC'),
    ]);

    final tickers = futures[0] as List<CoinTicker>;
    final btcTicker = futures[1] as CoinTicker?;

    setState(() {
      _allTickers = tickers;
      _btcTicker = btcTicker;
      _isLoading = false;
      _filterTickers();
    });
  } catch (e) {
    setState(() {
      _isLoading = false;
      _errorMessage = '데이터 로드 실패: $e';
    });
  }
}
```

### 5.2 수동 새로고침

```dart
// Pull to Refresh 패턴
Future<void> _manualRefresh() async {
  try {
    setState(() {
      _errorMessage = null;
    });

    final tickers = await _apiService.getAllTickers();
    final btcTicker = await _apiService.getTickerByMarket('KRW-BTC');

    setState(() {
      _allTickers = tickers;
      _btcTicker = btcTicker;
      _filterTickers();
    });
  } catch (e) {
    setState(() {
      _errorMessage = '새로고침 실패: $e';
    });
  }
}

// 새로고침 버튼
IconButton(
  onPressed: _isLoading ? null : _manualRefresh,
  icon: _isLoading
      ? SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      : ButtonIcon.refresh(color: AppColors.white100),
)
```

### 5.3 자동 새로고침 (타이머 기반)

```dart
Timer? _refreshTimer;

@override
void initState() {
  super.initState();
  _loadInitialData();
  _startAutoRefresh();
}

void _startAutoRefresh() {
  _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
    if (mounted && !_isLoading) {
      _loadInitialData();
    }
  });
}

@override
void dispose() {
  _refreshTimer?.cancel();
  super.dispose();
}
```

---

## 6. 에러 처리 전략

### 6.1 계층별 에러 처리

```dart
// 1. API 레벨 에러 처리
Future<List<CoinTicker>> getAllTickers() async {
  try {
    final response = await _dio.get('/market/ticker/all');
    if (response.statusCode == 200) {
      return parseData(response.data);
    }
    return [];  // 빈 배열 반환 (앱 크래시 방지)
  } catch (e) {
    debugPrint('API 에러: $e');
    return [];  // 실패해도 빈 배열
  }
}

// 2. UI 레벨 에러 처리
Future<void> _loadInitialData() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;  // 이전 에러 초기화
  });

  try {
    final tickers = await _apiService.getAllTickers();
    setState(() {
      _allTickers = tickers;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _isLoading = false;
      _errorMessage = '데이터 로드 실패: $e';
    });
  }
}
```

### 6.2 사용자 친화적 에러 표시

```dart
// 데이터 없음 상태
if (_errorMessage != null && _allTickers.isEmpty) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 64, color: AppColors.danger500),
        const SizedBox(height: 16),
        Text('데이터를 불러올 수 없습니다', style: FontStyles.s1),
        Text(_errorMessage!, style: FontStyles.b3),
        const SizedBox(height: 24),
        BasicButton(
          text: '다시 시도',
          onPressed: _manualRefresh,  // 복구 액션 제공
        ),
      ],
    ),
  );
}

// 일시적 에러 알림 (데이터는 있지만 새로고침 실패)
if (_errorMessage != null && _allTickers.isNotEmpty) {
  Container(
    padding: const EdgeInsets.all(12.0),
    decoration: BoxDecoration(
      color: AppColors.warning500.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(Icons.warning_amber, color: AppColors.warning500),
        Expanded(child: Text(_errorMessage!)),
        TextButton(
          onPressed: () => setState(() => _errorMessage = null),
          child: Text('닫기'),
        ),
      ],
    ),
  );
}
```

### 6.3 네트워크 에러 처리

```dart
// Dio Interceptor에서 네트워크 에러 처리
@override
void onError(DioException err, ErrorInterceptorHandler handler) async {
  final context = ApiService()._context;

  if (err.response?.statusCode == 500) {
    // 서버 오류
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.')),
      );
    }
  } else if (err.type == DioExceptionType.connectionTimeout ||
             err.type == DioExceptionType.receiveTimeout) {
    // 네트워크 타임아웃
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 연결을 확인해주세요.')),
      );
    }
  }

  return handler.next(err);
}
```

---

## 7. 데이터 필터링 및 검색

### 7.1 필터링 로직

```dart
void _filterTickers() {
  List<CoinTicker> filtered = _allTickers;

  // 1. 검색어 필터링 (대소문자 무시)
  if (_searchController.text.isNotEmpty) {
    final searchTerm = _searchController.text.toLowerCase();
    filtered = filtered.where((ticker) =>
      ticker.market.toLowerCase().contains(searchTerm) ||      // "krw-btc"
      ticker.coinSymbol.toLowerCase().contains(searchTerm)     // "btc"
    ).toList();
  }

  // 2. 카테고리 필터링
  if (selectedFilter != '전체') {
    filtered = filtered.where((ticker) =>
      ticker.baseCurrency == selectedFilter  // "KRW", "BTC", "USDT"
    ).toList();
  }

  // 3. 정렬 (거래량 순)
  filtered.sort((a, b) => b.accTradePrice24h.compareTo(a.accTradePrice24h));

  setState(() {
    _filteredTickers = filtered;
  });
}
```

### 7.2 실시간 검색

```dart
// 검색창에서 텍스트 변경 시 즉시 필터링
BasicInput(
  controller: _searchController,
  placeholder: '코인 검색 (예: BTC, ETH)',
  onChanged: (value) {
    _filterTickers();  // 즉시 필터링 적용
  },
)

// 필터 버튼 클릭 시
void _onFilterButtonPressed(String filter) {
  setState(() {
    selectedFilter = filter;
  });
  _filterTickers();  // 필터 변경 후 즉시 적용
}
```

### 7.3 정렬 옵션

```dart
enum SortOption {
  marketCap,     // 시가총액순
  priceHigh,     // 가격 높은순
  priceLow,      // 가격 낮은순
  changeHigh,    // 상승률 높은순
  changeLow,     // 하락률 높은순
  volumeHigh,    // 거래량 높은순
}

void _sortTickers(SortOption option) {
  _filteredTickers.sort((a, b) {
    switch (option) {
      case SortOption.priceHigh:
        return b.tradePrice.compareTo(a.tradePrice);
      case SortOption.changeHigh:
        return b.changeRate.compareTo(a.changeRate);
      case SortOption.volumeHigh:
        return b.accTradePrice24h.compareTo(a.accTradePrice24h);
      default:
        return 0;
    }
  });

  setState(() {
    _filteredTickers = _filteredTickers;
  });
}
```

---

## 8. UI 연동 방식

### 8.1 데이터 → UI 바인딩

```dart
Widget _buildCoinItem(CoinTicker ticker) {
  // 1. 데이터에서 표시 정보 추출
  final changeColor = ticker.isPositiveChange
      ? AppColors.danger500    // 상승 = 빨강
      : ticker.isNegativeChange
          ? AppColors.info500  // 하락 = 파랑
          : AppColors.grey400; // 보합 = 회색

  // 2. 코인별 색상 할당 (해시 기반)
  final colors = [AppColors.primary500, AppColors.warning500, ...];
  final logoColor = colors[ticker.coinSymbol.hashCode % colors.length];

  return ListTile(
    // 3. 로고 (코인 심볼 첫 글자들)
    leading: CircleAvatar(
      backgroundColor: logoColor.withValues(alpha: .2),
      child: Text(
        ticker.coinSymbol.length > 4
            ? ticker.coinSymbol.substring(0, 4)  // "DOGE" → "DOGE"
            : ticker.coinSymbol,                 // "BTC" → "BTC"
        style: FontStyles.c2.copyWith(color: logoColor),
      ),
    ),

    // 4. 코인 이름 및 마켓
    title: Text(ticker.coinSymbol, style: FontStyles.s2),
    subtitle: Text(ticker.market, style: FontStyles.b3),

    // 5. 가격 및 변동률
    trailing: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(ticker.formattedChangeRate, style: TextStyle(color: changeColor)),
        Text(ticker.formattedPrice, style: FontStyles.b3),
      ],
    ),

    onTap: () => _showCoinDetail(ticker),
  );
}
```

### 8.2 BTC 특별 표시 카드

```dart
if (_btcTicker != null)
  Container(
    margin: const EdgeInsets.all(16.0),
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: AppColors.grey900,
      borderRadius: BorderRadius.circular(12),
      // 변동률에 따른 테두리 색상
      border: Border.all(
        color: _btcTicker!.isPositiveChange
            ? AppColors.danger500.withValues(alpha: 0.3)
            : _btcTicker!.isNegativeChange
                ? AppColors.info500.withValues(alpha: 0.3)
                : AppColors.grey700,
        width: 1,
      ),
    ),
    child: Row(
      children: [
        // BTC 아이콘
        CircleAvatar(
          backgroundColor: AppColors.warning500.withValues(alpha: .2),
          child: Text('BTC', style: FontStyles.c2),
        ),

        // 가격 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bitcoin (KRW)', style: FontStyles.s2),
              Text(_btcTicker!.formattedPrice, style: FontStyles.b2),
            ],
          ),
        ),

        // 변동 정보
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(_btcTicker!.formattedChangeRate, style: changeStyle),
            if (_btcTicker!.formattedChangePrice != '0')
              Text(_btcTicker!.formattedChangePrice, style: changeStyle),
          ],
        ),
      ],
    ),
  )
```

### 8.3 로딩 및 빈 상태 UI

```dart
// 로딩 상태
if (_isLoading && _allTickers.isEmpty) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: AppColors.primary500),
        const SizedBox(height: 16),
        Text('코인 시세를 불러오는 중...', style: FontStyles.b2),
      ],
    ),
  );
}

// 검색 결과 없음
if (_filteredTickers.isEmpty) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off, size: 48, color: AppColors.grey500),
        const SizedBox(height: 16),
        Text(
          selectedFilter == '전체'
              ? '검색 결과가 없습니다'
              : '$selectedFilter 코인이 없습니다',
          style: FontStyles.s2.copyWith(color: AppColors.grey500),
        ),
        if (_searchController.text.isNotEmpty)
          Text(
            '"${_searchController.text}" 검색 결과',
            style: FontStyles.c2.copyWith(color: AppColors.grey400),
          ),
      ],
    ),
  );
}
```

### 8.4 Pull to Refresh 구현

```dart
RefreshIndicator(
  onRefresh: _manualRefresh,
  child: ListView.builder(
    itemCount: _filteredTickers.length,
    itemBuilder: (context, index) {
      final ticker = _filteredTickers[index];
      return _buildCoinItem(ticker);
    },
  ),
)
```

---

## 9. 성능 최적화

### 9.1 메모리 관리

```dart
// 1. 적절한 dispose 처리
@override
void dispose() {
  _tabController.dispose();      // TabController 정리
  _searchController.dispose();   // TextEditingController 정리
  _refreshTimer?.cancel();       // Timer 정리
  super.dispose();
}

// 2. mounted 체크로 메모리 누수 방지
void _updateData(List<CoinTicker> newData) {
  if (mounted) {  // Widget이 여전히 트리에 있는지 확인
    setState(() {
      _allTickers = newData;
    });
  }
}
```

### 9.2 ListView 최적화

```dart
// ListView.builder로 필요한 항목만 렌더링
ListView.builder(
  itemCount: _filteredTickers.length,
  itemBuilder: (context, index) {
    final ticker = _filteredTickers[index];
    return _buildCoinItem(ticker);  // 화면에 보이는 항목만 빌드
  },
)

// 대용량 데이터의 경우 추가 최적화
ListView.builder(
  itemCount: _filteredTickers.length,
  cacheExtent: 500,  // 캐시 범위 조정
  addAutomaticKeepAlives: false,  // 자동 keep alive 비활성화
  itemBuilder: (context, index) {
    // ...
  },
)
```

### 9.3 네트워크 최적화

```dart
// HTTP 클라이언트 설정
_dio = Dio(
  BaseOptions(
    connectTimeout: const Duration(seconds: 10),    // 연결 타임아웃
    receiveTimeout: const Duration(seconds: 10),    // 수신 타임아웃
    sendTimeout: const Duration(seconds: 10),       // 송신 타임아웃
  ),
);

// 병렬 API 호출로 로딩 시간 단축
final futures = await Future.wait([
  _apiService.getAllTickers(),
  _apiService.getTickerByMarket('KRW-BTC'),
]);
```

### 9.4 데이터 캐싱

```dart
class CacheManager {
  static final Map<String, CachedData> _cache = {};
  static const Duration _cacheExpiry = Duration(minutes: 1);

  static void setCache(String key, dynamic data) {
    _cache[key] = CachedData(data, DateTime.now());
  }

  static T? getCache<T>(String key) {
    final cached = _cache[key];
    if (cached != null &&
        DateTime.now().difference(cached.timestamp) < _cacheExpiry) {
      return cached.data as T?;
    }
    return null;
  }
}

class CachedData {
  final dynamic data;
  final DateTime timestamp;

  CachedData(this.data, this.timestamp);
}

// API 호출 시 캐시 확인
Future<List<CoinTicker>> getAllTickers() async {
  // 캐시 확인
  final cached = CacheManager.getCache<List<CoinTicker>>('all_tickers');
  if (cached != null) {
    return cached;
  }

  // API 호출
  final response = await _dio.get('/market/ticker/all');
  final tickers = parseData(response.data);

  // 캐시 저장
  CacheManager.setCache('all_tickers', tickers);

  return tickers;
}
```
