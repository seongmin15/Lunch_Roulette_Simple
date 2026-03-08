# Changelog

> 이 문서는 Claude가 릴리스 시마다 작성·관리합니다.

---

## [Unreleased]

<!-- Claude: §5.8 작업 완료 시 해당 변경을 [Unreleased]에 기록.
     분류 기준:
     - Added: 새 기능, 새 엔드포인트, 새 엔티티
     - Changed: 기존 동작 변경, 리팩터링
     - Fixed: 버그 수정
     - Removed: 기능/코드 삭제
     한 줄에 "무엇이 어떻게 변했는가"만 간결하게.
     릴리스 시 [Unreleased]를 버전 번호로 전환.
     형식: ## [X.Y.Z] - YYYY-MM-DD -->

### Added
- 프로젝트 초기 설정: README.md, .gitignore, git 저장소 초기화 및 원격 연결
- T001: Flutter 프로젝트 생성 및 feature-first 디렉토리 구조 설정
  - flutter_riverpod, dio, go_router, flutter_dotenv 의존성 추가
  - main.dart 부트스트랩 (ProviderScope + MaterialApp.router)
  - app/app.dart, app/router.dart, app/theme.dart 구성
  - features/ (home, filter, roulette, restaurant_detail, history) 구조 생성
  - .env.example 생성
- T002: 위치 권한 요청 및 현재 위치 조회 기능
  - geolocator, permission_handler, mockito, build_runner 의존성 추가
  - Android/iOS 플랫폼 위치 권한 설정
  - LocationService: 권한 확인/요청, GPS 활성화 확인, 현재 위치 조회
  - LocationState (sealed class): 6가지 상태 (Initial/Loading/Loaded/PermissionDenied/PermanentlyDenied/ServiceDisabled/Error)
  - LocationNotifier (Riverpod StateNotifier): 위치 조회 플로우 관리
  - HomeScreen: ConsumerStatefulWidget으로 변환, 모든 위치 상태별 UI 렌더링
  - 단위 테스트 17건 (LocationService 7건, LocationNotifier 9건, App 위젯 1건)
- T003: 카카오 로컬 API 연동 — 주변 식당 목록 조회 (ADR-4)
  - Restaurant 데이터 모델 (10개 필드: id, name, categoryName, phone, addressName, roadAddressName, latitude, longitude, distance, placeUrl)
  - RestaurantService: Dio 기반 카카오 키워드 검색 API 클라이언트 (카테고리 FD6, 거리순 정렬)
  - API 에러 처리: 타임아웃, 네트워크 오류, 401 인증 오류, 서버 오류
  - .env.example에 KAKAO_REST_API_KEY 추가
  - 단위 테스트 14건 (Restaurant 모델 5건, RestaurantService 9건)
- T004: 홈 화면 — 식당 목록 표시 UI
  - RestaurantListState (sealed class): 5가지 상태 (Initial/Loading/Loaded/Empty/Error)
  - RestaurantListNotifier (Riverpod StateNotifier): 식당 검색 플로우 관리
  - RestaurantListCard 위젯: 식당 이름, 카테고리, 주소, 거리 표시
  - HomeScreen 업데이트: 위치 획득 후 자동 식당 검색, ListView.builder + RefreshIndicator
  - 상태별 UI: 로딩/목록/빈결과/에러 + 재시도 버튼
  - 테스트 9건 (RestaurantListNotifier 6건, RestaurantListCard 3건)
- T005: 필터 화면 — 가격대·거리 필터 설정
  - FilterState + FilterNotifier (Riverpod StateNotifier): 거리/가격대 필터 상태 관리
  - FilterScreen: DistanceSlider (500m~3km), PriceRangeSelector (ChoiceChip)
  - 필터 변경 시 새 radius로 카카오 API 재호출
  - 홈 화면 AppBar에 필터 버튼 + Badge 표시
  - GoRouter /filter 라우트 추가
  - 테스트 12건 (FilterNotifier 5건 + FilterState 2건 + FilterScreen 5건)
- T006: 룰렛 화면 — 애니메이션 및 무작위 선택
  - RouletteWheel (CustomPainter): 원형 룰렛 시각화, 색상 섹션, 식당 이름 라벨, 화살표 마커
  - RouletteScreen: AnimationController + easeOutCubic 감속 애니메이션, 돌리기/다시 돌리기 버튼
  - ResultCard: 선택된 식당 강조 표시 (이름, 카테고리, 주소, 거리)
  - HistoryEntry 모델 + RouletteHistoryNotifier: 인메모리 히스토리 저장 (최대 10건)
  - 홈 화면에 "룰렛 돌리기" 버튼 추가, GoRouter /roulette 라우트
  - 테스트 11건 (RouletteHistory 6건 + ResultCard 2건 + RouletteScreen 3건)
- T007: 식당 상세 정보 화면
  - RestaurantDetailScreen: 이름, 카테고리, 주소(도로명+지번), 거리, 전화번호 표시
  - 길찾기 버튼 (카카오맵 우선, Google Maps 폴백), 전화하기, 카카오맵에서 보기
  - url_launcher 의존성 추가
  - 홈 화면 RestaurantListCard + 룰렛 ResultCard에서 상세 화면 네비게이션
  - GoRouter /restaurant-detail 라우트 추가
  - 테스트 6건
- T008: 히스토리 화면 — 최근 10건 룰렛 결과 관리
  - SharedPreferences 기반 히스토리 영속화 (JSON 직렬화/역직렬화)
  - Restaurant.toJson + fromJson 듀얼 키 지원 (API 키 + 로컬 저장 키)
  - HistoryEntry toJson/fromJson 추가
  - HistoryScreen: 빈 상태 UI, 목록 표시, Dismissible 스와이프 삭제, 전체 삭제 확인 다이얼로그
  - 홈 화면 AppBar에 히스토리 아이콘 버튼 추가
  - GoRouter /history 라우트 등록
  - 테스트 13건 (Restaurant toJson 2건 + HistoryEntry 3건 + HistoryScreen 8건)
- T009: 네비게이션 및 전체 화면 통합
  - StatefulShellRoute.indexedStack로 2탭 하단 NavigationBar 구현 (홈/히스토리)
  - _ScaffoldWithNavBar 쉘 위젯으로 탭 간 상태 유지
  - 필터/룰렛/상세는 parentNavigatorKey로 전체 화면 push (하단 바 숨김)
  - 홈 AppBar에서 히스토리 아이콘 제거 (하단 탭으로 이동)
  - 통합 테스트 6건 (NavigationBar 표시, 탭 전환, 탭 유지, 데이터 전달)
- T010: API 응답 캐싱 및 성능 최적화
  - RestaurantListNotifier에 인메모리 캐시 구현 (좌표+radius 키, 10분 TTL)
  - 캐시 히트 시 API 재호출 생략, TTL 만료 시 자동 갱신
  - forceRefresh 파라미터 추가 (pull-to-refresh, retry에서 사용)
  - clearCache 메서드 추가
  - ListView.builder 및 const 최적화 확인 완료
  - 캐시 테스트 4건 (캐시 히트, 캐시 미스, forceRefresh, clearCache)

- T018: 필터 값 영속화 (앱 재시작 시 유지)
  - FilterNotifier에 _load()/_save() 추가 (SharedPreferences JSON 직렬화)
  - setDistance/toggleCategory/reset 호출 시 자동 저장
  - 앱 시작 시 저장된 distance, selectedCategories 복원

### Fixed
- T019: 거리 필터 변경 시 카카오 API 재호출 안 되는 버그 수정
  - restaurantFetchTriggerProvider (Provider<void> + Future.microtask) 제거
  - restaurantListProvider에 ref.listen(locationProvider) + ref.listen(filterProvider) 콜백 추가
  - HomeScreen에서 ref.watch(restaurantFetchTriggerProvider) 제거
  - Provider 생성 시 이미 위치가 로드된 상태인 경우 즉시 fetch 트리거 추가
- T017: 카페 카테고리(CE7) 검색 결과 0건 반환 수정
  - FoodCategory enum에 categoryGroupCode 필드 추가 (cafe→CE7, 나머지→FD6)
  - RestaurantService.searchNearbyRestaurants에 categoryGroupCode 파라미터 추가
  - searchByAllCategories 시그니처를 Map<String, String> keywordToCategoryCode로 변경
- T011: 시스템 네비게이션 바와 앱 하단 버튼 겹침 수정
  - main.dart에 SystemChrome.setEnabledSystemUIMode(edgeToEdge) + 투명 시스템 바 설정
  - HomeScreen "룰렛 돌리기" 버튼, RouletteScreen 하단 버튼에 SafeArea 적용
- T014: 거리 필터 변경 시 식당 목록 미갱신 버그 수정
  - HomeScreen의 명령형 ref.listen을 반응형 restaurantFetchTriggerProvider로 리팩터링
  - location + filter를 모두 watch하여 어느 변경이든 자동 fetch 트리거

### Added
- T013: 룰렛 결과 공유 기능
- T015: 앱 디자인 모던화 (미니멀 + 그라디언트)
  - theme.dart 전면 리뉴얼 (primaryColor #FF6B35, 둥근 카드, appGradient/accentGradient)
  - 전체 화면 그라디언트 배경 적용 (Home, Roulette, History, Filter, Detail)
  - RestaurantListCard/HistoryListItem 모던 카드 스타일 (아이콘, 둥근 모서리, 부드러운 그림자)
  - ResultCard 오렌지 그라디언트 카드
  - NavigationBar 반투명 배경 + 그림자
  - CTA 버튼 accentGradient 적용
  - RouletteWheel 색상 팔레트 업데이트
  - withOpacity → withValues 마이그레이션 (22건)
  - share_plus ^10.1.4 의존성 추가
  - RouletteScreen에 공유 버튼 추가 (결과 선택 후 표시)
  - 공유 텍스트: [점심 룰렛 결과] + 식당명(카테고리) + 주소 + 거리 + placeUrl

### Added
- 커스텀 앱 아이콘 (슬롯머신 디자인) — Android/iOS 전체 사이즈 생성

### Changed
- 앱 테마 오렌지 → 딥 블루/인디고로 변경 (primary #3D5AF1, secondary #6B7FFF)
- 앱 아이콘 블루 테마로 재생성
- 거리 필터 슬라이더 100m 단위로 변경 (기존 500m 단위)
- T012: 가격대 필터를 음식 카테고리 필터로 교체
  - PriceRange enum 제거, FoodCategory enum 추가 (한식/중식/일식/양식/분식/치킨/피자/카페)
  - FilterChip 멀티셀렉트 UI로 카테고리 선택
  - filteredRestaurantsProvider로 categoryName 기반 클라이언트 사이드 필터링
  - OR 로직: 선택된 카테고리 중 하나라도 매칭되면 표시
- T016: 카테고리별 15개 식당 조회 + 슬롯머신 UI
  - RestaurantService에 query 파라미터 + searchByAllCategories() 추가 (8개 카테고리 병렬 호출, ID 중복 제거, 거리순 정렬)
  - RestaurantListNotifier가 FoodCategory 키워드로 searchByAllCategories() 호출
  - 원형 RouletteWheel을 SlotMachine으로 교체 (ListWheelScrollView 기반, 센터 하이라이트 바, 그라디언트 페이드)
