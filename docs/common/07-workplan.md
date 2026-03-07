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
- Status: Ready
- Service: lunch-roulette-app
- Description: `flutter create`로 프로젝트를 생성하고, feature-first 디렉토리 구조(`lib/features/`, `lib/shared/`)를 잡는다. 핵심 의존성(Riverpod, Dio, GoRouter, flutter_dotenv 등)을 pubspec.yaml에 추가하고, main.dart 부트스트랩 코드를 작성한다.
- Acceptance Criteria:
  - [ ] flutter create로 프로젝트 생성 완료
  - [ ] lib/features/ 및 lib/shared/ 디렉토리 구조 생성
  - [ ] pubspec.yaml에 핵심 의존성 추가 (flutter_riverpod, dio, go_router, flutter_dotenv)
  - [ ] main.dart에 ProviderScope + MaterialApp.router 부트스트랩 코드 작성
  - [ ] .env.example 파일 생성 (API 키 플레이스홀더)
  - [ ] flutter analyze 통과
- Result:

### T002: 위치 권한 요청 및 현재 위치 조회 기능
- Status: Ready
- Service: lunch-roulette-app
- Description: geolocator/permission_handler를 사용하여 위치 권한을 요청하고, 현재 GPS 좌표를 가져오는 서비스 레이어를 구현한다. 권한 거부 시 수동 주소 입력 폴백 UI도 포함한다.
- Acceptance Criteria:
  - [ ] 위치 권한 요청 로직 구현 (permission_handler)
  - [ ] 현재 위치(위도/경도) 조회 서비스 구현 (geolocator)
  - [ ] 권한 거부 시 안내 다이얼로그 표시
  - [ ] 위치 조회 실패 시 에러 처리
  - [ ] 단위 테스트 작성
- Result:

### T003: 지도 API 연동 — 주변 식당 목록 조회
- Status: Ready
- Service: lunch-roulette-app
- Description: 선택된 지도 API(카카오/네이버/Google)를 사용하여 현재 위치 주변의 식당 목록을 조회하는 Repository/Service 레이어를 구현한다. API 응답을 파싱하여 Restaurant 모델로 변환한다.
- Acceptance Criteria:
  - [ ] Restaurant 데이터 모델 정의 (이름, 주소, 거리, 가격대, 영업시간, 좌표)
  - [ ] 지도 API 클라이언트 구현 (Dio 기반)
  - [ ] API 응답 → Restaurant 모델 변환 로직
  - [ ] API 키를 환경변수로 관리 (flutter_dotenv)
  - [ ] API 호출 에러 처리 (타임아웃, 네트워크 오류)
  - [ ] 단위 테스트 작성
- Result:

### T004: 홈 화면 — 식당 목록 표시 UI
- Status: Ready
- Service: lunch-roulette-app
- Description: 앱 실행 시 자동으로 주변 식당을 로딩하여 리스트로 표시하는 홈 화면을 구현한다. 로딩/에러/빈 결과 상태를 처리한다.
- Acceptance Criteria:
  - [ ] 홈 화면 위젯 구현 (RestaurantListCard 포함)
  - [ ] Riverpod provider로 식당 목록 상태 관리
  - [ ] 로딩 상태 표시 (CircularProgressIndicator)
  - [ ] 빈 결과 상태 표시
  - [ ] 에러 상태 표시 및 재시도 버튼
  - [ ] GoRouter에 홈 화면 라우트 등록
  - [ ] 위젯 테스트 작성
- Result:

### T005: 필터 화면 — 가격대·거리 필터 설정
- Status: Ready
- Service: lunch-roulette-app
- Description: 거리(슬라이더)와 가격대(선택) 필터를 설정하는 화면을 구현한다. 필터 적용 시 식당 목록이 필터링된다.
- Acceptance Criteria:
  - [ ] 필터 화면 위젯 구현 (DistanceSlider, PriceRangeSelector)
  - [ ] 필터 상태 Riverpod provider 구현
  - [ ] 필터 적용 시 홈 화면 식당 목록 필터링
  - [ ] 필터 초기화 기능
  - [ ] 위젯 테스트 작성
- Result:

### T006: 룰렛 화면 — 애니메이션 및 무작위 선택
- Status: Ready
- Service: lunch-roulette-app
- Description: 필터링된 식당 목록을 기반으로 룰렛 휠 애니메이션을 실행하고, 무작위로 하나를 선택하여 결과를 표시하는 화면을 구현한다.
- Acceptance Criteria:
  - [ ] 룰렛 휠 애니메이션 위젯 구현 (RouletteWheel)
  - [ ] 무작위 선택 로직 구현
  - [ ] 결과 카드 표시 (ResultCard)
  - [ ] 룰렛 실행 후 결과를 히스토리에 저장
  - [ ] 위젯 테스트 작성
- Result:

### T007: 식당 상세 정보 화면
- Status: Ready
- Service: lunch-roulette-app
- Description: 선택된 식당의 상세 정보(이름, 주소, 거리, 영업시간)를 표시하고, 외부 지도 앱으로 길찾기를 연동하는 화면을 구현한다.
- Acceptance Criteria:
  - [ ] 식당 상세 화면 위젯 구현 (RestaurantDetailCard)
  - [ ] 길찾기 버튼 → 외부 지도 앱 연동 (url_launcher)
  - [ ] GoRouter에 상세 화면 라우트 등록
  - [ ] 위젯 테스트 작성
- Result:

### T008: 히스토리 화면 — 최근 10건 룰렛 결과 관리
- Status: Ready
- Service: lunch-roulette-app
- Description: 최근 룰렛 결과 10건을 로컬에 저장하고, 히스토리 화면에서 조회/삭제할 수 있는 기능을 구현한다. 10건 초과 시 오래된 항목을 자동 삭제한다.
- Acceptance Criteria:
  - [ ] 히스토리 로컬 저장 구현 (SharedPreferences 또는 Hive)
  - [ ] 10건 초과 시 자동 삭제 로직
  - [ ] 히스토리 화면 위젯 구현 (HistoryListItem)
  - [ ] 개별 히스토리 삭제 기능
  - [ ] GoRouter에 히스토리 화면 라우트 등록
  - [ ] 단위 테스트 + 위젯 테스트 작성
- Result:

### T009: 네비게이션 및 전체 화면 통합
- Status: Ready
- Service: lunch-roulette-app
- Description: 모든 화면을 GoRouter로 연결하고, 하단 네비게이션 또는 탭 구조로 앱 전체 네비게이션을 완성한다. 화면 간 데이터 전달을 검증한다.
- Acceptance Criteria:
  - [ ] GoRouter에 전체 라우트 구성 완료
  - [ ] 하단 네비게이션 바 또는 앱바 네비게이션 구현
  - [ ] 화면 간 데이터 전달 정상 동작 확인
  - [ ] 통합 테스트 작성 (주요 플로우)
- Result:

### T010: API 응답 캐싱 및 성능 최적화
- Status: Backlog
- Service: lunch-roulette-app
- Description: 지도 API 응답을 로컬에 10분간 캐싱하여 중복 호출을 줄인다. ListView 가상화, const 위젯 최적화 등 성능 개선을 적용한다.
- Acceptance Criteria:
  - [ ] API 응답 로컬 캐싱 구현 (10분 TTL)
  - [ ] 캐시 만료 시 자동 갱신
  - [ ] ListView.builder 사용 확인
  - [ ] const 생성자 최적화 확인
- Result:
