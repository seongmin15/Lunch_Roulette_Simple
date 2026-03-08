# 트러블슈팅 가이드

> 이 문서는 Claude가 개발·운영 과정에서 발견한 문제와 해결법을 기록합니다.
> 배포·운영 절차는 12-runbook.md를 참조하세요.

---

## 알려진 이슈 및 해결법

<!-- Claude: 아래 기준에 해당하면 기록:
     - 원인 파악에 10분 이상 걸린 이슈
     - 같은 원인이 반복될 가능성이 있는 이슈
     - 환경/설정 관련 이슈 (다른 개발자도 겪을 수 있음)
     단순 오타, 1회성 실수는 기록 불필요.
     카테고리 예시: [환경] [빌드] [런타임] [데이터] [배포] [외부서비스] -->

### [런타임] 거리 필터 변경 시 식당 목록 미갱신
- **증상**: 필터 화면에서 거리를 변경하고 적용해도 홈 화면의 식당 목록이 변경된 반경으로 갱신되지 않음
- **원인**: `Provider<void>` + `Future.microtask` 사이드이펙트 패턴이 비결정적. Riverpod의 Provider는 반환값이 변하지 않으면(void == void) 의존 위젯 재빌드를 트리거하지 않아 microtask 내 fetch가 실행되지 않을 수 있음
- **해결**: `restaurantFetchTriggerProvider` 제거. `restaurantListProvider` 생성 함수에서 `ref.listen(filterProvider)` 콜백으로 거리 변경 감지 후 직접 `fetchRestaurants()` 호출
- **예방**: Riverpod에서 사이드이펙트는 `Provider<void>` + `ref.watch` 대신 `ref.listen` 콜백 사용
- **발견일**: 2026-03-08
