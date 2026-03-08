# 작업 이력

> 이 문서는 Claude가 개발 과정에서 작성·관리합니다.
> 상단 요약 테이블로 전체 흐름을 파악하고, 하단 상세 로그로 작업 간 맥락을 이어갑니다.

---

## 요약


<!-- Claude: §5.8 작업 완료, §5.12 작업 중단/취소 시 한 줄 추가.
     작업 내용은 "무엇을 왜" 중심 1줄 요약.
     상태: 진행중 | 완료 | 중단 | 취소 -->

| 날짜 | 작업 | 상태 | 요약 |
|------|------|------|------|
| 2026-03-08 | 프로젝트 Init | 완료 | Git 초기화, README/.gitignore 생성, remote 설정, 초기 태스크 작성 |
| 2026-03-08 | T001: Flutter 프로젝트 초기 생성 | 완료 | Flutter 3.41.4 프로젝트 생성, feature-first 구조, 핵심 의존성, 부트스트랩 코드 |
| 2026-03-08 | T002: 위치 권한 요청 및 현재 위치 조회 | 완료 | geolocator/permission_handler로 위치 서비스 레이어 구현 |
| 2026-03-08 | T003: 지도 API 연동 — 주변 식당 목록 조회 | 완료 | 카카오 로컬 API 기반 Restaurant 모델 + RestaurantService 구현 |
| 2026-03-08 | T004: 홈 화면 — 식당 목록 표시 UI | 완료 | 위치 획득 후 식당 목록 로딩/표시, RestaurantListCard, 상태별 UI |
| 2026-03-08 | T005: 필터 화면 — 가격대·거리 필터 설정 | 완료 | 거리 슬라이더 + 가격대 선택 필터, 기본 거리 1000m |
| 2026-03-08 | T006: 룰렛 화면 — 애니메이션 및 무작위 선택 | 완료 | RouletteWheel 애니메이션, 무작위 선택, ResultCard, 히스토리 저장 |
| 2026-03-08 | T007: 식당 상세 정보 화면 | 완료 | RestaurantDetailCard, 길찾기 연동(url_launcher), GoRouter 라우트 |

---

## 상세 로그

<!-- Claude: 작업 완료/중단/취소 시 아래 형식으로 추가.
     한 작업 = 한 엔트리. 세션 구분 불필요.
     "변경된 파일"은 docs/와 코드 모두 포함.
     "미완료/후속"은 다음 작업자(또는 다음 세션의 자신)가 즉시 이어갈 수 있는 수준으로. -->

<!--
### YYYY-MM-DD — 작업 제목

- **작업**: 무엇을 했는가
- **변경된 파일**: 어떤 docs/code가 변경되었는가
- **의사결정**: 내린 결정과 이유
- **미완료/후속**: 다음에 이어할 것
-->

### 2026-03-08 — 프로젝트 Init

- **작업**: Section 7 Init 프로토콜 실행. 전체 문서 리뷰, README.md 생성, .gitignore 생성, git init, 원격 저장소 연결, 초기 커밋 및 push, 07-workplan 초기 태스크 작성.
- **변경된 파일**: README.md (신규), .gitignore (신규), 07-workplan.md (태스크 추가), 09-working-log.md (Init 기록), 10-changelog.md (Init 기록)
- **의사결정**: branch 이름을 master → main으로 변경 (GitHub Flow 관례). remote: https://github.com/seongmin15/Lunch_Roulette_Simple.git
- **미완료/후속**: 07-workplan 태스크 리스트 승인 후 T001부터 작업 시작

### 2026-03-08 — T001: Flutter 프로젝트 초기 생성 및 기본 구조 설정

- **작업**: flutter create로 프로젝트 생성, feature-first 디렉토리 구조 설정, 핵심 의존성 추가, 부트스트랩 코드 작성
- **계획 범위**: 프로젝트 생성, lib/ 디렉토리 구조, pubspec.yaml 의존성, main.dart/app.dart/router.dart/theme.dart, .env.example, analysis_options.yaml
- **변경된 파일**: pubspec.yaml, lib/main.dart, lib/app/app.dart, lib/app/router.dart, lib/app/theme.dart, lib/features/home/screens/home_screen.dart, .env.example, .env, analysis_options.yaml, test/widget_test.dart, lib/features/*/에 .gitkeep 파일들
- **의사결정**: Flutter SDK를 C:/flutter에 설치 (시스템에 미설치 상태였음). 테마 seed color로 orange 선택 (음식 앱 컨셉). Material 3 사용.
- **미완료/후속**: T002 위치 권한 요청 및 현재 위치 조회 기능

### 2026-03-08 — T002: 위치 권한 요청 및 현재 위치 조회 기능

- **작업**: geolocator/permission_handler를 사용한 위치 서비스 레이어 구현. LocationService, LocationState(sealed class), LocationNotifier(StateNotifier), HomeScreen 업데이트, 단위 테스트 작성
- **계획 범위**: 의존성 추가, Android/iOS 권한 설정, LocationService, LocationState 모델, LocationProvider, HomeScreen 업데이트, 단위 테스트
- **변경된 파일**: pubspec.yaml, android/app/src/main/AndroidManifest.xml, ios/Runner/Info.plist, lib/services/location_service.dart (신규), lib/features/home/providers/location_state.dart (신규), lib/features/home/providers/location_provider.dart (신규), lib/features/home/screens/home_screen.dart, test/services/location_service_test.dart (신규), test/features/home/providers/location_provider_test.dart (신규), test/widget_test.dart
- **의사결정**: permission_handler를 aliased import로 사용하여 openAppSettings 이름 충돌 해결. MockLocationService를 직접 구현하여 mockito 코드 생성 없이 테스트 가능하게 함.
- **미완료/후속**: T003 지도 API 연동 — 주변 식당 목록 조회

### 2026-03-08 — T003: 지도 API 연동 — 주변 식당 목록 조회 (카카오 로컬 API)

- **작업**: 카카오 로컬 API를 사용하여 주변 식당 검색 서비스 레이어 구현
- **계획 범위**: Restaurant 데이터 모델, RestaurantService(Dio 기반), .env.example 업데이트, ADR-4 기록, 단위 테스트
- **변경된 파일**: lib/models/restaurant.dart (신규), lib/services/restaurant_service.dart (신규), test/models/restaurant_test.dart (신규), test/services/restaurant_service_test.dart (신규), .env.example (KAKAO_REST_API_KEY 추가), docs/common/02-architecture-decisions.md (ADR-4 추가), docs/common/07-workplan.md, docs/common/09-working-log.md, docs/common/10-changelog.md
- **의사결정**: 카카오 로컬 API 선택 (ADR-4). 카카오 API가 가격대/영업시간 필드를 직접 제공하지 않으므로 Restaurant 모델에 categoryName, phone, placeUrl로 대체. MockDio는 `implements Dio` + `noSuchMethod` 패턴으로 Dio 5.x 호환성 확보.
- **미완료/후속**: T004 홈 화면 — 식당 목록 표시 UI

### 2026-03-08 — T004: 홈 화면 — 식당 목록 표시 UI

- **작업**: 위치 획득 후 주변 식당 목록을 자동으로 로딩/표시하는 홈 화면 구현
- **계획 범위**: RestaurantListState, RestaurantListNotifier, RestaurantListCard 위젯, HomeScreen 업데이트, 위젯 테스트
- **변경된 파일**: lib/features/home/providers/restaurant_list_state.dart (신규), lib/features/home/providers/restaurant_list_provider.dart (신규), lib/features/home/widgets/restaurant_list_card.dart (신규), lib/features/home/screens/home_screen.dart (수정), test/features/home/providers/restaurant_list_provider_test.dart (신규), test/features/home/widgets/restaurant_list_card_test.dart (신규), docs/common/07-workplan.md, docs/common/09-working-log.md, docs/common/10-changelog.md
- **의사결정**: LocationLoaded 상태 감지 시 ref.listen으로 자동 식당 검색 트리거. _RestaurantListBody를 별도 ConsumerWidget으로 분리하여 식당 상태만 독립적으로 rebuild. RefreshIndicator로 pull-to-refresh 지원.
- **미완료/후속**: T005 필터 화면 — 가격대·거리 필터 설정

### 2026-03-08 — T005: 필터 화면 — 가격대·거리 필터 설정

- **작업**: 거리 슬라이더 + 가격대 ChoiceChip 필터 화면 구현, 필터 적용 시 홈 화면 식당 목록 재검색
- **계획 범위**: FilterState/FilterNotifier, FilterScreen (DistanceSlider + PriceRangeSelector), HomeScreen 필터 연동, GoRouter 라우트 추가, 위젯 테스트
- **변경된 파일**: lib/features/filter/providers/filter_state.dart (신규), lib/features/filter/providers/filter_provider.dart (신규), lib/features/filter/screens/filter_screen.dart (신규), lib/features/home/screens/home_screen.dart (수정 — 필터 버튼, ref.listen 연동), lib/features/home/providers/restaurant_list_provider.dart (수정 — radius 파라미터 추가), lib/app/router.dart (수정 — /filter 라우트), test/features/filter/ (신규 테스트 2파일), docs/
- **의사결정**: 거리 기본값 1000m (사용자 승인). 카카오 API가 가격 정보를 제공하지 않으므로 가격대 필터는 UI만 구현하고 안내 문구 표시. 필터 변경 시 ref.listen으로 감지하여 새 radius로 API 재호출. 홈 AppBar에 Badge 아이콘으로 필터 활성 상태 표시.
- **미완료/후속**: T006 룰렛 화면 — 애니메이션 및 무작위 선택

### 2026-03-08 — T006: 룰렛 화면 — 애니메이션 및 무작위 선택

- **작업**: RouletteWheel(CustomPainter) 애니메이션 + 무작위 선택 + ResultCard + 인메모리 히스토리 저장
- **계획 범위**: RouletteWheel, ResultCard, RouletteScreen, HistoryEntry 모델, RouletteHistoryNotifier, HomeScreen 룰렛 버튼, GoRouter /roulette 라우트, 테스트
- **변경된 파일**: lib/models/history_entry.dart (신규), lib/features/roulette/providers/roulette_history_provider.dart (신규), lib/features/roulette/widgets/roulette_wheel.dart (신규), lib/features/roulette/widgets/result_card.dart (신규), lib/features/roulette/screens/roulette_screen.dart (신규), lib/features/home/screens/home_screen.dart (수정), lib/app/router.dart (수정), test/features/roulette/ (신규 3파일)
- **의사결정**: CustomPainter로 원형 룰렛 구현 (외부 패키지 없이). easeOutCubic 감속 커브로 자연스러운 멈춤 효과. 히스토리는 인메모리 StateNotifier로 구현 (T008에서 영속화 예정). 식당 목록을 GoRouter extra로 전달.
- **미완료/후속**: T007 식당 상세 정보 화면

### 2026-03-08 — T007: 식당 상세 정보 화면

- **작업**: 식당 상세 화면 구현 (상세 카드 + 길찾기/전화/카카오맵 연동), 홈·룰렛에서 네비게이션 추가
- **계획 범위**: RestaurantDetailScreen, url_launcher 의존성, GoRouter /restaurant-detail 라우트, RestaurantListCard·RouletteScreen 네비게이션 연동, 위젯 테스트
- **변경된 파일**: lib/features/restaurant_detail/screens/restaurant_detail_screen.dart (신규), lib/features/home/widgets/restaurant_list_card.dart (수정 — InkWell 탭), lib/features/roulette/screens/roulette_screen.dart (수정 — 상세 버튼), lib/app/router.dart (수정), pubspec.yaml (url_launcher 추가), test/features/restaurant_detail/ (신규)
- **의사결정**: 길찾기는 카카오맵 앱 우선, 미설치 시 Google Maps 웹 폴백. url_launcher로 전화걸기/외부 URL 오픈 처리.
- **미완료/후속**: T008 히스토리 화면 — 최근 10건 룰렛 결과 관리
