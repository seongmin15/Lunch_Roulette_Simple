# Work Plan

> This document is the single source of truth (SSOT) for project tasks.
> AI proposes tasks, and they are reflected after user approval.

## Operating Rules

- Status transitions require user approval.
- History must not be deleted.

## Status Flow

```
Backlog -> Ready -> In Progress -> Review -> Done
                        |    ^
                        v    |
                      Paused

Any active status -> Cancelled
```

- **Paused**: task is temporarily stopped. Only from In Progress.
- **Cancelled**: task is abandoned. Record reason in Result.

## Task Format

```
### T<NNN>: <title>
- Status: Backlog | Ready | In Progress | Review | Paused | Cancelled | Done
- Service: <service name>
- Origin: T<NNN> (optional, when derived from another task)
- Description: <description>
- Acceptance Criteria:
  - [ ] <criterion 1>
  - [ ] <criterion 2>
- Result: (recorded after completion)
```

### Origin Rules

- Record when a task is derived from issues found in another task's Result.
- Omit Origin for initial tasks.

### Result Rules

- Result must be recorded when Status becomes Done or Cancelled.
- All Acceptance Criteria items must be checked before transitioning to Done.
- If some items are split into other tasks, mark as "deferred to T<NNN>" on the original item.
- Include: created files, test results, discovered issues.
- Record issues resolved within the task as well.
- Issues exceeding 30 minutes should be split into a new task.
- Out-of-scope issues move to docs/common/05-roadmap.md.

---

## Tasks

> AI writes the initial task list at project start.

<!-- Claude: This is a hybrid document.
     Template Engine fills Operating Rules, Status Flow, Task Format.
     Claude fills the Tasks section during Init based on docs/common/05-roadmap.md.
     After Init, Claude updates task statuses with user approval.
     Rules:
     - Never delete task history.
     - Always get user approval before status transitions.
     - Keep tasks small (~30 min reviewable).
     - Record Result when Done. -->

### T001: Flutter 프로젝트 초기 생성 및 기본 구조 설정
- Status: Done
- Service: lunch-roulette-app
- Description: `flutter create`로 프로젝트를 생성하고, feature-first 디렉토리 구조(`lib/features/`, `lib/shared/`)를 잡는다. 핵심 의존성(Riverpod, Dio, GoRouter, flutter_dotenv 등)을 pubspec.yaml에 추가하고, main.dart 부트스트랩 코드를 작성한다.
- Acceptance Criteria:
  - [x] flutter create로 프로젝트 생성 완료
  - [x] lib/features/ 및 lib/shared/ 디렉토리 구조 생성
  - [x] pubspec.yaml에 핵심 의존성 추가 (flutter_riverpod, dio, go_router, flutter_dotenv)
  - [x] main.dart에 ProviderScope + MaterialApp.router 부트스트랩 코드 작성
  - [x] .env.example 파일 생성 (API 키 플레이스홀더)
  - [x] flutter analyze 통과
- Result: Flutter 3.41.4 프로젝트 생성 완료. Feature-first 구조(home/filter/roulette/restaurant_detail/history) 설정. flutter analyze 에러 0건.

### T002: 위치 권한 요청 및 현재 위치 조회 기능
- Status: Done
- Service: lunch-roulette-app
- Description: geolocator/permission_handler를 사용하여 위치 권한을 요청하고, 현재 GPS 좌표를 가져오는 서비스 레이어를 구현한다. 권한 거부 시 수동 주소 입력 폴백 UI도 포함한다.
- Acceptance Criteria:
  - [x] 위치 권한 요청 로직 구현 (permission_handler)
  - [x] 현재 위치(위도/경도) 조회 서비스 구현 (geolocator)
  - [x] 권한 거부 시 안내 다이얼로그 표시
  - [x] 위치 조회 실패 시 에러 처리
  - [x] 단위 테스트 작성
- Result: LocationService + LocationNotifier(Riverpod StateNotifier) + sealed LocationState 구현. HomeScreen에서 6가지 상태(Initial/Loading/Loaded/PermissionDenied/PermanentlyDenied/ServiceDisabled/Error) 모두 처리. 17개 테스트 전체 통과. flutter analyze 에러 0건.

### T003: 지도 API 연동 — 주변 식당 목록 조회
- Status: Done
- Service: lunch-roulette-app
- Description: 선택된 지도 API(카카오/네이버/Google)를 사용하여 현재 위치 주변의 식당 목록을 조회하는 Repository/Service 레이어를 구현한다. API 응답을 파싱하여 Restaurant 모델로 변환한다.
- Acceptance Criteria:
  - [x] Restaurant 데이터 모델 정의 (이름, 주소, 거리, 카테고리, 전화번호, 좌표, 카카오맵 URL)
  - [x] 지도 API 클라이언트 구현 (Dio 기반)
  - [x] API 응답 → Restaurant 모델 변환 로직
  - [x] API 키를 환경변수로 관리 (flutter_dotenv)
  - [x] API 호출 에러 처리 (타임아웃, 네트워크 오류)
  - [x] 단위 테스트 작성
- Result: 카카오 로컬 API 기반 RestaurantService 구현 (ADR-4). Restaurant 모델 10개 필드 (id, name, categoryName, phone, addressName, roadAddressName, latitude, longitude, distance, placeUrl). Dio 기반 API 클라이언트 + 에러 처리 (타임아웃/네트워크/401/서버오류). 14개 테스트 전체 통과. flutter analyze 에러 0건.

### T004: 홈 화면 — 식당 목록 표시 UI
- Status: Done
- Service: lunch-roulette-app
- Description: 앱 실행 시 자동으로 주변 식당을 로딩하여 리스트로 표시하는 홈 화면을 구현한다. 로딩/에러/빈 결과 상태를 처리한다.
- Acceptance Criteria:
  - [x] 홈 화면 위젯 구현 (RestaurantListCard 포함)
  - [x] Riverpod provider로 식당 목록 상태 관리
  - [x] 로딩 상태 표시 (CircularProgressIndicator)
  - [x] 빈 결과 상태 표시
  - [x] 에러 상태 표시 및 재시도 버튼
  - [x] GoRouter에 홈 화면 라우트 등록
  - [x] 위젯 테스트 작성
- Result: RestaurantListState(sealed class 5상태) + RestaurantListNotifier + RestaurantListCard 위젯 구현. HomeScreen에서 위치 획득 후 자동 식당 검색, ListView.builder + RefreshIndicator, 상태별 UI 처리. 테스트 9건 (Provider 6건 + Widget 3건), 전체 40건 통과. flutter analyze 에러 0건. GoRouter 라우트는 T001에서 이미 등록 완료.

### T005: 필터 화면 — 가격대·거리 필터 설정
- Status: Done
- Service: lunch-roulette-app
- Description: 거리(슬라이더)와 가격대(선택) 필터를 설정하는 화면을 구현한다. 필터 적용 시 식당 목록이 필터링된다.
- Acceptance Criteria:
  - [x] 필터 화면 위젯 구현 (DistanceSlider, PriceRangeSelector)
  - [x] 필터 상태 Riverpod provider 구현
  - [x] 필터 적용 시 홈 화면 식당 목록 필터링
  - [x] 필터 초기화 기능
  - [x] 위젯 테스트 작성
- Result: FilterState + FilterNotifier + FilterScreen 구현. 거리 슬라이더 (500m~3km, 기본 1000m), 가격대 ChoiceChip (전체/저렴/보통/비싼 — 카카오 API 미지원으로 UI만 구현). 필터 변경 시 새 radius로 API 재호출. 홈 화면 AppBar에 필터 버튼 (Badge 표시). 테스트 12건 (Provider 7건 + Widget 5건), 전체 52건 통과. flutter analyze 에러 0건.

### T006: 룰렛 화면 — 애니메이션 및 무작위 선택
- Status: Done
- Service: lunch-roulette-app
- Description: 필터링된 식당 목록을 기반으로 룰렛 휠 애니메이션을 실행하고, 무작위로 하나를 선택하여 결과를 표시하는 화면을 구현한다.
- Acceptance Criteria:
  - [x] 룰렛 휠 애니메이션 위젯 구현 (RouletteWheel)
  - [x] 무작위 선택 로직 구현
  - [x] 결과 카드 표시 (ResultCard)
  - [x] 룰렛 실행 후 결과를 히스토리에 저장
  - [x] 위젯 테스트 작성
- Result: RouletteWheel(CustomPainter + AnimationController, easeOutCubic 감속) + ResultCard + RouletteScreen 구현. Random으로 인덱스 선택 후 해당 섹션에 멈추는 애니메이션. RouletteHistoryNotifier로 인메모리 히스토리 저장 (최대 10건). 홈 화면에 "룰렛 돌리기" 버튼 추가. 테스트 11건 (History 6건 + ResultCard 2건 + Screen 3건), 전체 63건 통과. flutter analyze 에러 0건.

### T007: 식당 상세 정보 화면
- Status: Done
- Service: lunch-roulette-app
- Description: 선택된 식당의 상세 정보(이름, 주소, 거리, 영업시간)를 표시하고, 외부 지도 앱으로 길찾기를 연동하는 화면을 구현한다.
- Acceptance Criteria:
  - [x] 식당 상세 화면 위젯 구현 (RestaurantDetailCard)
  - [x] 길찾기 버튼 → 외부 지도 앱 연동 (url_launcher)
  - [x] GoRouter에 상세 화면 라우트 등록
  - [x] 위젯 테스트 작성
- Result: RestaurantDetailScreen 구현 (이름, 카테고리, 도로명/지번 주소, 거리, 전화번호). 길찾기(카카오맵→Google Maps 폴백), 전화하기, 카카오맵에서 보기 버튼. 홈 화면 RestaurantListCard + 룰렛 ResultCard에서 상세 화면 네비게이션 추가. url_launcher 의존성 추가. 테스트 6건, 전체 69건 통과. flutter analyze 에러 0건.

### T008: 히스토리 화면 — 최근 10건 룰렛 결과 관리
- Status: Done
- Service: lunch-roulette-app
- Description: 최근 룰렛 결과 10건을 로컬에 저장하고, 히스토리 화면에서 조회/삭제할 수 있는 기능을 구현한다. 10건 초과 시 오래된 항목을 자동 삭제한다.
- Acceptance Criteria:
  - [x] 히스토리 로컬 저장 구현 (SharedPreferences 또는 Hive)
  - [x] 10건 초과 시 자동 삭제 로직
  - [x] 히스토리 화면 위젯 구현 (HistoryListItem)
  - [x] 개별 히스토리 삭제 기능
  - [x] GoRouter에 히스토리 화면 라우트 등록
  - [x] 단위 테스트 + 위젯 테스트 작성
- Result: SharedPreferences 기반 히스토리 영속화 구현. Restaurant/HistoryEntry에 toJson/fromJson 추가 (Kakao API키 + 로컬 저장키 듀얼 지원). HistoryScreen: 빈 상태/목록/스와이프 삭제(Dismissible)/전체 삭제(확인 다이얼로그). 홈 AppBar에 히스토리 버튼 추가. GoRouter /history 라우트 등록. 테스트 13건 (Restaurant toJson 2건 + HistoryEntry 3건 + HistoryScreen 8건), 전체 82건 통과. flutter analyze 에러 0건.

### T009: 네비게이션 및 전체 화면 통합
- Status: Done
- Service: lunch-roulette-app
- Description: 모든 화면을 GoRouter로 연결하고, 하단 네비게이션 또는 탭 구조로 앱 전체 네비게이션을 완성한다. 화면 간 데이터 전달을 검증한다.
- Acceptance Criteria:
  - [x] GoRouter에 전체 라우트 구성 완료
  - [x] 하단 네비게이션 바 또는 앱바 네비게이션 구현
  - [x] 화면 간 데이터 전달 정상 동작 확인
  - [x] 통합 테스트 작성 (주요 플로우)
- Result: StatefulShellRoute.indexedStack로 2탭 NavigationBar 구현 (홈/히스토리). 필터/룰렛/상세는 parentNavigatorKey로 전체 화면 push. 홈 AppBar에서 히스토리 아이콘 제거 (탭으로 이동). 통합 테스트 6건 (NavigationBar 표시, 탭 전환, 탭 유지, 데이터 전달), 전체 88건 통과. flutter analyze 에러 0건.

### T010: API 응답 캐싱 및 성능 최적화
- Status: Done
- Service: lunch-roulette-app
- Description: 지도 API 응답을 로컬에 10분간 캐싱하여 중복 호출을 줄인다. ListView 가상화, const 위젯 최적화 등 성능 개선을 적용한다.
- Acceptance Criteria:
  - [x] API 응답 로컬 캐싱 구현 (10분 TTL)
  - [x] 캐시 만료 시 자동 갱신
  - [x] ListView.builder 사용 확인
  - [x] const 생성자 최적화 확인
- Result: RestaurantListNotifier에 인메모리 캐시 구현 (_CacheEntry, 좌표+radius 키, 10분 TTL). forceRefresh 파라미터로 수동 갱신 지원 (pull-to-refresh, retry). clearCache 메서드 추가. ListView.builder 확인 (홈/히스토리 모두 사용). const 최적화 확인 완료. 캐시 테스트 4건, 전체 92건 통과. flutter analyze 에러 0건.

### T011: 전체 화면 — 하단 시스템 바 겹침 수정
- Status: Done
- Service: lunch-roulette-app
- Description: 시스템 네비게이션 바(Android 제스처 바 / iOS 홈 인디케이터)가 앱 하단 버튼과 겹치는 문제를 수정한다.
- Acceptance Criteria:
  - [x] main.dart에 edge-to-edge 모드 및 투명 시스템 내비게이션 바 설정
  - [x] HomeScreen 하단 "룰렛 돌리기" 버튼에 SafeArea 적용
  - [x] RouletteScreen 하단 버튼 Row에 SafeArea 적용
  - [x] 기존 92개 테스트 전체 통과
  - [x] flutter analyze 에러 0건
- Result: main.dart에 SystemChrome.setEnabledSystemUIMode(edgeToEdge) + 투명 시스템 바 설정. HomeScreen/RouletteScreen 하단 버튼에 SafeArea 래핑. FilterScreen은 이미 SafeArea 적용 완료. RestaurantDetailScreen은 ListView body에 버튼이 있어 SafeArea 불필요. 전체 92건 통과, flutter analyze 에러 0건.

### T012: 가격대 필터를 카테고리 필터로 교체
- Status: Done
- Service: lunch-roulette-app
- Description: 카카오 API에서 가격 정보를 제공하지 않아 무의미한 가격대 필터를 제거하고, categoryName 기반 음식 카테고리 필터(한식/중식/일식/양식/분식/치킨/피자/카페)로 교체한다.
- Acceptance Criteria:
  - [x] PriceRange enum 제거, FoodCategory enum 추가 (8개 카테고리)
  - [x] FilterState에 Set<FoodCategory> selectedCategories 필드 추가
  - [x] FilterNotifier에 toggleCategory 메서드 추가
  - [x] FilterScreen에 FilterChip 기반 카테고리 선택 UI 구현
  - [x] filteredRestaurantsProvider 추가 (클라이언트 사이드 카테고리 필터링)
  - [x] HomeScreen에서 filteredRestaurantsProvider 사용
  - [x] 테스트 업데이트 (Provider 8건 + Screen 5건 + Filtered 4건)
  - [x] flutter analyze 에러 0건
- Result: PriceRange 제거, FoodCategory(8개 enum값, label+keyword) 추가. FilterChip 멀티셀렉트 UI. filteredRestaurantsProvider로 categoryName.contains() 매칭 (OR 로직). 전체 97건 통과 (+5건), flutter analyze 에러 0건.

### T014: 거리 필터 변경 시 식당 목록 미갱신 버그 수정
- Status: Done
- Service: lunch-roulette-app
- Description: 필터 화면에서 거리를 변경해도 식당 목록이 갱신되지 않는 버그를 수정한다.
- Acceptance Criteria:
  - [x] 거리 필터 변경 시 식당 목록 자동 갱신
  - [x] 위치 변경 시에도 정상적으로 식당 검색 트리거
  - [x] 기존 92개 테스트 전체 통과
  - [x] flutter analyze 에러 0건
- Result: HomeScreen의 명령형 ref.listen 방식을 반응형 restaurantFetchTriggerProvider로 리팩터링. location + filter를 모두 watch하여 어느 쪽이 변경되든 자동으로 fetchRestaurants 호출. 전체 92건 통과, flutter analyze 에러 0건.

### T013: 룰렛 결과 공유 기능
- Status: Done
- Service: lunch-roulette-app
- Description: 룰렛으로 선택된 식당 결과를 다른 사람에게 공유할 수 있는 기능을 추가한다.
- Acceptance Criteria:
  - [x] share_plus 의존성 추가
  - [x] RouletteScreen에 공유 버튼 추가 (결과 선택 후 표시)
  - [x] 공유 텍스트 포맷: 식당명, 카테고리, 주소, 거리, placeUrl
  - [x] 공유 버튼 표시 테스트 추가
  - [x] flutter analyze 에러 0건
- Result: share_plus ^10.1.4 추가. RouletteScreen에 IconButton.filledTonal 공유 버튼 추가 (결과 선택 후 표시). 공유 텍스트: [점심 룰렛 결과] + 식당명(카테고리) + 주소 + 거리 + placeUrl. 테스트 1건 추가, 전체 98건 통과. flutter analyze 에러 0건.

### T015: 앱 디자인 모던화 (미니멀 + 그라디언트)
- Status: Done
- Service: lunch-roulette-app
- Description: 기본 Material 3 디자인을 모던하고 미니멀한 스타일로 리뉴얼한다. 그라디언트 배경, 부드러운 카드, 세련된 색상 팔레트를 적용한다.
- Acceptance Criteria:
  - [x] theme.dart 리뉴얼 (커스텀 색상, 둥근 카드, 그라디언트 정의)
  - [x] 전체 화면에 그라디언트 배경 적용 (Home, Roulette, History, Filter, Detail)
  - [x] RestaurantListCard 모던 카드 스타일 (아이콘, 그림자, 뱃지)
  - [x] ResultCard 그라디언트 카드 스타일
  - [x] HistoryListItem 모던 카드 스타일
  - [x] NavigationBar 세련된 스타일 (반투명, 그림자)
  - [x] 주요 버튼 그라디언트 스타일 적용
  - [x] RouletteWheel 색상 팔레트 업데이트
  - [x] withOpacity → withValues 마이그레이션 (22건)
  - [x] 기존 98개 테스트 전체 통과
  - [x] flutter analyze 에러 0건
- Result: theme.dart 전면 리뉴얼 (primaryColor #FF6B35, 둥근 카드 16px, appGradient/accentGradient). 전 화면 그라디언트 배경. RestaurantListCard에 아이콘+거리 뱃지. ResultCard 그라디언트 카드. HistoryListItem 모던 카드. NavigationBar 반투명+그림자. 주요 CTA 버튼 accentGradient. withOpacity→withValues 22건 마이그레이션. 전체 98건 통과, flutter analyze 0건.

### T016: 카테고리별 15개 식당 조회 + 슬롯머신 UI
- Status: Done
- Service: lunch-roulette-app
- Description: 단일 '식당' 키워드로 15개만 가져오던 API 호출을 8개 카테고리별 15개씩 병렬 호출 (최대 120개, 중복 제거)로 변경하고, 원형 룰렛 휠을 슬롯머신 스타일 UI로 교체한다.
- Acceptance Criteria:
  - [x] RestaurantService에 query 파라미터 추가 및 searchByAllCategories() 메서드 구현
  - [x] RestaurantListNotifier에서 searchByAllCategories() 호출로 변경
  - [x] SlotMachine 위젯 구현 (ListWheelScrollView 기반)
  - [x] RouletteScreen에서 RouletteWheel을 SlotMachine으로 교체
  - [x] RouletteWheel 파일 삭제
  - [x] 테스트 업데이트 및 전체 통과
  - [x] flutter analyze 에러 0건
- Result: RestaurantService에 query 파라미터 + searchByAllCategories() 추가 (Future.wait 병렬 호출, ID 기반 중복 제거, 거리순 정렬). RestaurantListNotifier가 FoodCategory 8개 키워드로 searchByAllCategories() 호출. SlotMachine 위젯 (ListWheelScrollView.useDelegate + LoopingListDelegate, 센터 하이라이트 바, 상하 그라디언트 페이드). RouletteScreen에서 FixedExtentScrollController + animateToItem으로 슬롯머신 스핀. RouletteWheel 삭제. 전체 102건 통과 (+4건), flutter analyze 에러 0건.

### T017: 카페 카테고리 검색 수정 (CE7 지원)
- Status: Done
- Service: lunch-roulette-app
- Origin: T016
- Description: 카카오 로컬 API에서 카페(CE7)와 음식점(FD6)이 별도 카테고리 코드로 분리되어 있어 카페 검색 시 결과가 0건 반환되는 문제 수정. FoodCategory enum에 categoryGroupCode 필드를 추가하고, RestaurantService에서 카테고리별로 적절한 코드를 전달하도록 변경.
- Acceptance Criteria:
  - [x] FoodCategory enum에 categoryGroupCode 필드 추가 (cafe→CE7, 나머지→FD6)
  - [x] RestaurantService.searchNearbyRestaurants에 categoryGroupCode 파라미터 추가
  - [x] RestaurantService.searchByAllCategories 시그니처를 Map<String, String>으로 변경
  - [x] RestaurantListNotifier에서 keywordToCategoryCode Map 생성하여 전달
  - [x] 테스트 업데이트 및 CE7 전달 확인 테스트 추가
  - [x] flutter test 전체 통과
  - [x] flutter analyze 에러 0건
- Result: FoodCategory enum에 categoryGroupCode 필드 추가 (cafe→CE7, 나머지 7개→FD6). RestaurantService.searchNearbyRestaurants에 categoryGroupCode 파라미터 추가, searchByAllCategories를 Map<String, String> keywordToCategoryCode로 변경. RestaurantListNotifier에서 FoodCategory.values로 Map 생성. 테스트 2건 추가 (categoryGroupCode 파라미터 전달 + CE7 코드 확인), 전체 104건 통과. flutter analyze 에러 0건.
