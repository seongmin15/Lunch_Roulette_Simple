# 점심 룰렛 (Lunch Roulette)

매일 반복되는 '오늘 뭐 먹지?' 고민을 해결하는 모바일 앱

## 소개

현재 위치 기반으로 주변 식당을 자동 수집하고, 가격·거리 필터를 적용한 뒤 룰렛을 돌려 점심 메뉴를 즉시 결정해주는 1인용 모바일 앱입니다.

## 핵심 기능

- **주변 식당 자동 수집**: 앱 실행 시 현재 위치 기반으로 주변 식당 목록을 자동 표시 (30초 이내)
- **필터링**: 가격대·거리 조건 설정으로 원하는 식당만 선별
- **룰렛 실행**: 필터링된 식당 중 하나를 무작위 선택 (5초 이내)
- **히스토리**: 최근 룰렛 결과 10건 저장 및 조회
- **식당 상세 정보**: 이름, 주소, 거리, 영업시간 확인

## 기술 스택

- **Framework**: Flutter (Dart)
- **State Management**: Riverpod
- **HTTP Client**: Dio
- **지도 API**: 카카오 로컬 API (키워드 검색)
- **로컬 저장**: SharedPreferences
- **Routing**: GoRouter (StatefulShellRoute)
- **Target**: iOS 14.0+ / Android 8.0+ (API 26)

## 아키텍처

- **패턴**: Monolith (단일 Flutter 앱, 별도 백엔드 없음)
- **내부 구조**: Feature-first layered architecture (`lib/features/`)

## 화면 구성

| 화면 | 설명 |
|------|------|
| Home | 식당 목록 + 필터 칩 + 룰렛 시작 버튼 |
| Filter | 거리·가격대 설정 |
| Roulette | 룰렛 애니메이션 + 결과 표시 |
| Restaurant Detail | 식당 상세 정보 + 길찾기 |
| History | 최근 10건 룰렛 결과 |

## 시작하기

### 사전 요구사항

- Flutter SDK 3.41 이상 ([설치 가이드](https://docs.flutter.dev/get-started/install))
- Android Studio 또는 Xcode (플랫폼별)
- 카카오 REST API 키

### 1. 카카오 API 설정

이 앱은 주변 식당 검색을 위해 **카카오 로컬 API**를 사용합니다.

1. [Kakao Developers](https://developers.kakao.com/)에 로그인합니다.
2. **내 애플리케이션** > **애플리케이션 추가하기**를 클릭합니다.
3. 앱 이름과 사업자명을 입력하고 저장합니다.
4. 생성된 앱의 **앱 키** 탭에서 **REST API 키**를 복사합니다.
5. 프로젝트 루트에 `.env` 파일을 생성하고 API 키를 입력합니다:

```bash
cp .env.example .env
```

```
# .env
KAKAO_REST_API_KEY=여기에_복사한_REST_API_키_붙여넣기
```

> **참고**: `.env` 파일은 `.gitignore`에 포함되어 있어 Git에 커밋되지 않습니다.

### 2. 의존성 설치

```bash
flutter pub get
```

### 3. Android에서 실행

**요구사항**: Android Studio, Android SDK, 에뮬레이터 또는 실제 기기

```bash
# 연결된 기기/에뮬레이터 확인
flutter devices

# 디버그 모드 실행
flutter run

# 특정 기기 지정 실행
flutter run -d <device-id>
```

**실제 기기 사용 시**:
1. 기기에서 **설정** > **개발자 옵션** > **USB 디버깅**을 활성화합니다.
2. USB 케이블로 기기를 연결합니다.
3. `flutter run`을 실행합니다.

**위치 권한**: 앱 최초 실행 시 위치 권한 허용 팝업이 표시됩니다. "허용"을 선택해야 주변 식당 검색이 가능합니다.

### 4. iOS에서 실행

**요구사항**: macOS, Xcode 15 이상, CocoaPods

```bash
# CocoaPods 의존성 설치
cd ios && pod install && cd ..

# iOS 시뮬레이터에서 실행
flutter run

# 특정 시뮬레이터 지정
flutter run -d "iPhone 16"
```

**실제 기기 사용 시**:
1. Xcode에서 `ios/Runner.xcworkspace`를 엽니다.
2. **Signing & Capabilities**에서 개발 팀을 설정합니다.
3. Bundle Identifier를 고유한 값으로 변경합니다 (예: `com.yourname.lunchroulette`).
4. 기기를 연결하고 `flutter run`을 실행합니다.

> **참고**: iOS 실제 기기 배포에는 Apple Developer 계정이 필요합니다. 무료 계정으로도 개발 기기에서 테스트할 수 있습니다.

### 5. 테스트 실행

```bash
# 전체 테스트 실행
flutter test

# 정적 분석
flutter analyze
```

## 프로젝트 문서

- `docs/common/` - 프로젝트 공통 문서 (요구사항, 아키텍처, 품질 계획 등)
- `docs/lunch-roulette-app/` - 앱 서비스별 문서 (모바일 디자인)
- `skills/` - 코딩 표준, Git 워크플로우, 테스트 가이드라인

## 라이선스

Private - 개인 사용 목적
