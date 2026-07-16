# Project Instructions

## Project Identity

`26_LM / LivingMansion`은 Godot 기반 저택 탐색 어드벤처다. 방 탐색, 단서 변화, 다음 선택으로 이어지는 첫 플레이 루프를 확정하는 것이 핵심이다.

## Authoritative Stack

- Godot `project.godot`, `scenes/`, `scripts/`, `resources/`, `autoloads/`, `assets/`를 기준으로 한다.
- `addons/gut`와 `tests/`는 Godot 테스트 기준으로 본다.
- package.json 부재는 결함이 아니라 Godot 프로젝트 특성으로 취급한다.

## Build And Verification

- Godot/GUT 테스트가 가능하면 `tests/` 아래 테스트를 우선 실행한다.
- 씬 변경 시 Godot 에디터 기준으로 로딩, 노드 참조, 리소스 경로를 확인한다.
- 빌드/릴리즈는 Godot export 기준을 확인한 뒤 마지막에 한 번만 수행한다.

## Documentation Rules

- `docs/LivingMansion_기획서.md`와 `docs/LivingMansion_기획서.html`을 함께 유지한다.
- `docs/next_improvement_instruction.md`는 첫 탐색 루프 개선 기준으로 유지한다.
- 단서, 방, 관계, 선택 흐름이 바뀌면 GDD와 HTML을 같이 갱신한다.

## Resource And Preview Rules

- 대표 이미지는 `docs/LivingMansion_gameplay_preview.png`와 `_workspace_docs/project_previews/26_LivingMansion_LivingMansion_gameplay_preview.png` 계열을 우선한다.
- 리소스 변경 시 `.import` 파일과 Godot 리소스 참조를 함께 확인한다.
- 방 탐색 UI는 단서 변화와 다음 선택이 즉시 보이게 한다.

## AI-Assisted Workflow

1. Plan: 플레이어가 확인할 방, 단서, 다음 선택을 먼저 정한다.
2. Split: 씬/스크립트/리소스/문서 작업을 분리한다.
3. Build: Godot 구조를 유지하며 좁게 수정한다.
4. Verify: GUT 테스트, 씬 로딩, GDD/HTML 동기화, 대표 이미지 참조를 확인한다.
5. Reflect: Godot 전용 예외는 이 파일에 남긴다.

## Do Not

- Godot 리소스 참조를 확인 없이 파일만 이동하지 않는다.
- npm/Vite 프로젝트처럼 재구성하지 않는다.
- 단서/선택 규칙을 문서와 구현 중 한쪽에만 바꾸지 않는다.
