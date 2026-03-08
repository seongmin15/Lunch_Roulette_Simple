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
