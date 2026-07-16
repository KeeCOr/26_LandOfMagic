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