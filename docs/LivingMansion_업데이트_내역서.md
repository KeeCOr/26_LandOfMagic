# LivingMansion 업데이트 내역서

## 2026-07-16 v0.1.2 Release Hygiene
- 현재 Codex 세션에서는 Godot 실행 파일이 PATH와 일반 설치 경로에서 발견되지 않아 GUT 테스트와 export를 새로 실행하지 못했다.
- 기존 `LivingMansion_v0.1.2_portable.exe` 산출물의 root/release/Drive 배치를 확인하고, 예전 v0.1.1 실행파일은 Git 추적에서 제거하는 방향으로 정리했다.
- 산출물은 Git이 아니라 로컬 프로젝트 루트, `release/`, Google Drive 실행파일 폴더에 유지한다.
## 2026-07-02 v0.1.2 Persona Retest And GUT Repair
- Re-ran Godot 4.7 headless GUT tests for the current persona retest wave.
- Initial result: 8/10 passing; two `level_up_triggered` signal tests failed because the tests used local-variable closures that did not reliably capture signal callbacks.
- Updated `tests/test_game_state.gd` to use a test-instance counter receiver for `level_up_triggered`.
- Final result: 2 scripts / 10 tests / 21 asserts passing.
- Rewrote the current GDD/update/persona docs into readable UTF-8 Korean and added a 10-person first-room prototype rubric.

## 2026-06-29 v0.1.2 Mansion Runtime Art Refresh
- Replaced `assets/art/environment/mansion.png` at the existing runtime path.
- Preserved the 192x160 source dimensions and existing Godot `.import` file/UID so Castle.gd continues loading the same resource without scene rewiring.
- Visual intent: clearer haunted mansion silhouette, lit windows, moonlit defensive-base read, and stronger contrast at in-game sprite scale.
- Validation: PNG dimensions verified as 192x160; `mansion.png.import` still points to the same source file. Godot 4.7 CLI and Windows export templates were installed; `LivingMansion_v0.1.2_portable.exe` was exported successfully on 2026-06-30.
