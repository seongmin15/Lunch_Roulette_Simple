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
- **지도 API**: 카카오/네이버/Google Maps (미정)
- **로컬 저장**: SharedPreferences / Hive
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

```bash
# 의존성 설치
flutter pub get

# 환경변수 설정
cp .env.example .env
# .env 파일에 API 키 입력

# 실행
flutter run
```

## 프로젝트 문서

- `docs/common/` - 프로젝트 공통 문서 (요구사항, 아키텍처, 품질 계획 등)
- `docs/lunch-roulette-app/` - 앱 서비스별 문서 (모바일 디자인)
- `skills/` - 코딩 표준, Git 워크플로우, 테스트 가이드라인

## 라이선스

Private - 개인 사용 목적
