# LivingMansion Next Improvement Instruction

Date: 2026-07-02

## Goal
Close the remaining persona confidence gap by proving that the first-room loop is understandable to real players, not only technically functional.

## Current State
- Godot/GUT validation is live again: 2026-07-02 headless run passed 2 scripts / 10 tests / 21 asserts.
- Current GDD/update/persona docs were rewritten into readable UTF-8 Korean.
- Runtime feature work is not the next step until the first-room prototype test is observed.

## Next Batch Instructions
1. Run the 10-person first-room prototype test from `docs/first_room_prototype_test_rubric.md`.
2. Record whether each tester can explain the clue change, next-room reason, and replay interest.
3. If fewer than 7/10 testers understand the clue change, improve clue feedback copy before adding new rooms.
4. If fewer than 6/10 testers choose the next room for a clue/risk/reward reason, improve next-room cards before adding combat depth.

## Completion Rules
- Do not add new room content until the first-room loop passes the rubric.
- If runtime source changes, rerun Godot/GUT tests.
- If docs change, keep `LivingMansion_기획서.md/html`, update history, and persona feedback in sync.

## 2026-09-18 전체 프로젝트 공통 완료 조건

1. **첫 5분 핵심 루프**: 시작 10초 안에 목표가 읽히고, 5분 안에 첫 판단→실행→결과→보상/손실→다음 목표가 한 번 완결되어야 한다.
2. **판단 전후 피드백**: 선택 전 예상 이득·위험·비용, 실행 직후 성공·실패·상태 변화, 결과 화면의 원인·변화·다음 점검 행동을 같은 흐름으로 제공한다. 정답을 자동 추천하지 않는다.
3. **출시 증거 패키지**: 테스트·빌드·첫 5분 수동 확인·대표 실행 화면·로딩/빈 상태/오류/저장 복귀·버전과 검증 날짜를 기록한다. 수행하지 않은 항목은 미검증으로 표시한다.

공통 기준 원문: `C:\Development\_workspace_docs\전체_프로젝트_공통_개선기준_2026-09-18.md`

## 2026-09-18 프로젝트별 고유 개선 3개
> 아래 세 항목은 이 프로젝트의 고유 우선순위다. 구현 후에만 완료로 표시한다.

1. 단서 획득 직후 관계·사건·다음 방 선택 변화를 표시
2. 저택 지도에 미확인 위험과 조사 완료 근거를 구분
3. 한 방에서 단서·추론·인물 반응이 끝나는 대표 장면 완성
