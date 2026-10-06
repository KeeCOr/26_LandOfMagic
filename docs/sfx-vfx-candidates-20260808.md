# SFX/VFX Candidates - 2026-08-08

Shared catalog source: G:\내 드라이브\00_지원자료\50_SFX_VFX_공용_리소스_20260808\manifest.csv

## Status

- Status: runtime-connected
- Handling: Four original, synthesized SFX are connected to existing combat and exploration events. The existing projectile bitmap remains the sole VFX candidate.
- SFX count: 4
- VFX count: 1

## Files

| Kind | Source path | Duplicate of |
|---|---|---|
| SFX | `assets/generated/audio/lm-projectile-launch-v1.wav` | original synthesized asset |
| SFX | `assets/generated/audio/lm-impact-v1.wav` | original synthesized asset |
| SFX | `assets/generated/audio/lm-heal-v1.wav` | original synthesized asset |
| SFX | `assets/generated/audio/lm-clue-discovered-v1.wav` | original synthesized asset |
| VFX | `assets/art/effects/projectile_bolt.png` | existing runtime asset |

## Runtime hooks

- Projectile creation: launch cue; projectile contact and direct enemy damage: impact cue.
- Healing fountain tick: heal cue.
- First-time clue discovery: discovery cue.
- `autoloads/AudioManager.gd` creates short-lived `AudioStreamPlayer` nodes, so gameplay scenes do not own or duplicate audio players.
- Verification on 2026-10-06: Godot 4.7.2 headless GUT suite passed (14/14 tests, 32 assertions); main menu scene loaded headlessly.
