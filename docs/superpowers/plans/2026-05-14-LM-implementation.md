# Living Mansion (LM) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Godot 4.x 탑뷰 뱀서라이크 게임 구현 — 이동하는 성을 조종하고 내부 선형 슬롯에 영웅/시설을 배치해 사방의 적을 자동 처치하는 로그라이트 스테이지 클리어 게임

**Architecture:** Castle(CharacterBody2D)이 플레이어 방향 입력을 받아 이동. 내부 Slot 배열에 배치된 Hero/Facility가 각자의 Area2D 탐지 범위 내 Enemy를 자동 공격. WaveManager가 적 스폰 관리. XP 누적 시 LevelUpPopup이 전투 일시정지 후 3선택지 제공. 스테이지 클리어 보상으로 SaveData에 메타 업그레이드 저장.

**Tech Stack:** Godot 4.x, GDScript, GUT (Godot Unit Test addon)

---

## File Map

```
res://
├── project.godot
├── addons/gut/                          # GUT 테스트 프레임워크
├── autoloads/
│   ├── GameState.gd                     # 런 상태 (HP, XP, 슬롯, 신호)
│   └── SaveData.gd                      # 메타 진행 저장/불러오기
├── scripts/resources/
│   ├── HeroData.gd
│   ├── FacilityData.gd
│   ├── EnemyData.gd
│   ├── WaveData.gd
│   └── MetaUpgradeData.gd
├── resources/
│   ├── heroes/{archer,mage,knight,priest,alchemist}.tres
│   ├── facilities/{crossbow,catapult,spike_fence,healing_fountain,mana_orb}.tres
│   ├── enemies/{goblin,orc,goblin_archer,troll,boss_stage1}.tres
│   ├── waves/stage_1/{wave_1,wave_2,wave_3,boss}.tres
│   └── meta_upgrades/upgrades.tres
├── scenes/
│   ├── main_menu/MainMenu.tscn + MainMenu.gd
│   ├── stage_select/StageSelect.tscn + StageSelect.gd
│   ├── placement/PlacementScreen.tscn + PlacementScreen.gd
│   ├── game/
│   │   ├── Game.tscn + Game.gd
│   │   ├── castle/Castle.tscn + Castle.gd
│   │   ├── castle/Slot.tscn + Slot.gd
│   │   ├── units/Hero.tscn + Hero.gd
│   │   ├── units/Facility.tscn + Facility.gd
│   │   ├── units/heroes/{Archer,Mage,Knight,Priest,Alchemist}.tscn + .gd
│   │   ├── units/facilities/{Crossbow,Catapult,SpikeFence,HealingFountain,ManaOrb}.tscn + .gd
│   │   ├── enemies/Enemy.tscn + Enemy.gd
│   │   ├── enemies/{Goblin,Orc,GoblinArcher,Troll,Boss}.tscn + .gd
│   │   ├── projectiles/Projectile.tscn + Projectile.gd
│   │   └── wave/WaveManager.tscn + WaveManager.gd
│   └── ui/
│       ├── HUD.tscn + HUD.gd
│       ├── LevelUpPopup.tscn + LevelUpPopup.gd
│       ├── WaveIntermission.tscn + WaveIntermission.gd
│       └── MetaScreen.tscn + MetaScreen.gd
└── tests/
    ├── test_game_state.gd
    └── test_meta_upgrades.gd
```

---

### Task 1: Godot 프로젝트 생성 + GUT 설치

**Files:**
- Create: `project.godot` (Godot 에디터에서 생성)
- Create: `addons/gut/` (에셋 스토어에서 설치)

- [ ] **Step 1: Godot 에디터에서 새 프로젝트 생성**

  Godot 4.x 실행 → New Project → 이름: `LivingMansion` → 경로: `C:/Development/26_LM` → Create & Edit

- [ ] **Step 2: GUT 애드온 설치**

  AssetLib 탭 → "GUT" 검색 → 다운로드 및 설치 → Project > Project Settings > Plugins → GUT 활성화

- [ ] **Step 3: 폴더 구조 생성**

  FileSystem 패널에서 우클릭으로 다음 폴더 생성:
  `autoloads/`, `scripts/resources/`, `resources/heroes/`, `resources/facilities/`, `resources/enemies/`, `resources/waves/stage_1/`, `resources/meta_upgrades/`, `scenes/main_menu/`, `scenes/stage_select/`, `scenes/placement/`, `scenes/game/castle/`, `scenes/game/units/heroes/`, `scenes/game/units/facilities/`, `scenes/game/enemies/`, `scenes/game/projectiles/`, `scenes/game/wave/`, `scenes/ui/`, `tests/`

- [ ] **Step 4: 기본 입력 액션 등록**

  Project > Project Settings > Input Map → 다음 액션 추가:
  - `move_left` → A key, Left Arrow
  - `move_right` → D key, Right Arrow
  - `move_up` → W key, Up Arrow
  - `move_down` → S key, Down Arrow

- [ ] **Step 5: 커밋**

```bash
git add .
git commit -m "chore: init Godot project with GUT addon and folder structure"
```

---

### Task 2: 리소스 데이터 클래스 정의

**Files:**
- Create: `scripts/resources/HeroData.gd`
- Create: `scripts/resources/FacilityData.gd`
- Create: `scripts/resources/EnemyData.gd`
- Create: `scripts/resources/WaveData.gd`
- Create: `scripts/resources/MetaUpgradeData.gd`

- [ ] **Step 1: HeroData.gd 작성**

```gdscript
# scripts/resources/HeroData.gd
class_name HeroData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var scene_path: String = ""
@export var damage: float = 10.0
@export var attack_speed: float = 1.0   # 초당 공격 횟수
@export var attack_range: float = 200.0
@export var description: String = ""
@export var icon: Texture2D
```

- [ ] **Step 2: FacilityData.gd 작성**

```gdscript
# scripts/resources/FacilityData.gd
class_name FacilityData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var scene_path: String = ""
@export var damage: float = 8.0
@export var attack_speed: float = 1.5
@export var attack_range: float = 180.0
@export var description: String = ""
@export var icon: Texture2D
@export var max_level: int = 3
```

- [ ] **Step 3: EnemyData.gd 작성**

```gdscript
# scripts/resources/EnemyData.gd
class_name EnemyData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var scene_path: String = ""
@export var max_hp: float = 30.0
@export var move_speed: float = 80.0
@export var damage: float = 5.0
@export var attack_range: float = 60.0
@export var xp_reward: int = 1
@export var is_ranged: bool = false
@export var attack_interval: float = 1.0
@export var projectile_speed: float = 200.0  # is_ranged=true일 때만 사용
```

- [ ] **Step 4: WaveData.gd 작성**

```gdscript
# scripts/resources/WaveData.gd
class_name WaveData
extends Resource

@export var wave_number: int = 1
@export var duration: float = 30.0
@export var spawn_interval: float = 2.0
@export var enemy_pool: Array[EnemyData] = []
@export var spawn_weights: Array[float] = []  # enemy_pool 인덱스와 1:1 대응
@export var max_enemies_at_once: int = 20
@export var is_boss_wave: bool = false
```

- [ ] **Step 5: MetaUpgradeData.gd 작성**

```gdscript
# scripts/resources/MetaUpgradeData.gd
class_name MetaUpgradeData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var cost: int = 100
@export var max_level: int = 3
# upgrade_type 값: "slot_count", "max_hp", "start_gold", "hero_level", "xp_bonus", "facility_discount"
@export var upgrade_type: String = ""
@export var value_per_level: float = 1.0
```

- [ ] **Step 6: 커밋**

```bash
git add scripts/
git commit -m "feat: add resource data classes (HeroData, FacilityData, EnemyData, WaveData, MetaUpgradeData)"
```

---

### Task 3: GameState + SaveData 오토로드

**Files:**
- Create: `autoloads/GameState.gd`
- Create: `autoloads/SaveData.gd`
- Modify: `project.godot` (오토로드 등록)

- [ ] **Step 1: GameState.gd 작성**

```gdscript
# autoloads/GameState.gd
extends Node

# 런 상태
var current_stage: int = 1
var current_wave: int = 0
var castle_hp: float = 100.0
var castle_max_hp: float = 100.0
var xp: float = 0.0
var xp_to_next_level: float = 10.0
var level: int = 1
var gold: int = 0

# 슬롯 상태: [{unit_data: HeroData/FacilityData or null, unit_node: Node or null}]
var slot_count: int = 3
var slots: Array = []

# 선택지 풀
var hero_pool: Array[HeroData] = []
var facility_pool: Array[FacilityData] = []

signal level_up_triggered(choices: Array)
signal castle_died()
signal wave_cleared(wave_number: int)
signal stage_cleared(stage_number: int, gold_reward: int)

func _ready() -> void:
    SaveData.load_save()
    _apply_meta_upgrades()

func reset_run() -> void:
    current_wave = 0
    castle_hp = castle_max_hp
    xp = 0.0
    xp_to_next_level = 10.0
    level = 1
    gold = SaveData.get_upgrade_value("start_gold")
    slots.clear()
    for i in slot_count:
        slots.append({unit_data = null, unit_node = null})

func gain_xp(amount: float) -> void:
    var bonus = 1.0 + SaveData.get_upgrade_value("xp_bonus") * 0.1
    xp += amount * bonus
    if xp >= xp_to_next_level:
        xp -= xp_to_next_level
        xp_to_next_level = floor(xp_to_next_level * 1.2)
        level += 1
        emit_signal("level_up_triggered", _get_levelup_choices())

func take_castle_damage(amount: float) -> void:
    castle_hp = max(0.0, castle_hp - amount)
    if castle_hp <= 0.0:
        emit_signal("castle_died")

func heal_castle(amount: float) -> void:
    castle_hp = min(castle_max_hp, castle_hp + amount)

func _get_levelup_choices() -> Array:
    var all: Array = []
    all.append_array(hero_pool)
    all.append_array(facility_pool)
    all.shuffle()
    return all.slice(0, 3)

func _apply_meta_upgrades() -> void:
    slot_count = 3 + int(SaveData.get_upgrade_value("slot_count"))
    castle_max_hp = 100.0 + SaveData.get_upgrade_value("max_hp") * 10.0
```

- [ ] **Step 2: SaveData.gd 작성**

```gdscript
# autoloads/SaveData.gd
extends Node

const SAVE_PATH = "user://lm_save.json"

var meta_upgrades: Dictionary = {}  # upgrade_id -> level (int)
var unlocked_stages: Array = [1]
var total_gold: int = 0

func save() -> void:
    var data = {
        "meta_upgrades": meta_upgrades,
        "unlocked_stages": unlocked_stages,
        "total_gold": total_gold
    }
    var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    file.store_string(JSON.stringify(data))
    file.close()

func load_save() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
    var text = file.get_as_text()
    file.close()
    var data = JSON.parse_string(text)
    if data is Dictionary:
        meta_upgrades = data.get("meta_upgrades", {})
        unlocked_stages = data.get("unlocked_stages", [1])
        total_gold = data.get("total_gold", 0)

func get_upgrade_level(upgrade_id: String) -> int:
    return meta_upgrades.get(upgrade_id, 0)

func get_upgrade_value(upgrade_id: String) -> float:
    return float(get_upgrade_level(upgrade_id))

func try_upgrade(upgrade_id: String, cost: int, max_level: int) -> bool:
    var current = get_upgrade_level(upgrade_id)
    if current >= max_level or total_gold < cost:
        return false
    total_gold -= cost
    meta_upgrades[upgrade_id] = current + 1
    save()
    return true

func add_gold(amount: int) -> void:
    total_gold += amount
    save()
```

- [ ] **Step 3: 오토로드 등록**

  Project > Project Settings > Autoload → 다음 두 개 추가:
  - Path: `res://autoloads/SaveData.gd`, Name: `SaveData`
  - Path: `res://autoloads/GameState.gd`, Name: `GameState`

  (SaveData를 GameState보다 먼저 등록해야 GameState._ready()에서 SaveData 참조 가능)

- [ ] **Step 4: GUT 테스트 작성**

```gdscript
# tests/test_game_state.gd
extends GutTest

func test_gain_xp_triggers_level_up() -> void:
    GameState.xp = 0.0
    GameState.xp_to_next_level = 10.0
    GameState.level = 1
    var leveled_up = false
    GameState.level_up_triggered.connect(func(_c): leveled_up = true)
    GameState.gain_xp(10.0)
    assert_true(leveled_up)
    assert_eq(GameState.level, 2)

func test_take_castle_damage_clamps_to_zero() -> void:
    GameState.castle_hp = 10.0
    GameState.take_castle_damage(999.0)
    assert_eq(GameState.castle_hp, 0.0)

func test_heal_castle_clamps_to_max() -> void:
    GameState.castle_max_hp = 100.0
    GameState.castle_hp = 90.0
    GameState.heal_castle(50.0)
    assert_eq(GameState.castle_hp, 100.0)
```

- [ ] **Step 5: 테스트 실행**

```bash
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
```

Expected: 3 tests pass

- [ ] **Step 6: 커밋**

```bash
git add autoloads/ tests/test_game_state.gd
git commit -m "feat: add GameState and SaveData autoloads with XP and meta upgrade logic"
```

---

### Task 4: Projectile 씬

**Files:**
- Create: `scenes/game/projectiles/Projectile.tscn`
- Create: `scenes/game/projectiles/Projectile.gd`

- [ ] **Step 1: Projectile 씬 생성 (에디터)**

  새 씬 → Root Node: `Area2D` → 이름: `Projectile`
  자식 추가: `CollisionShape2D` (CircleShape2D, radius: 5), `Sprite2D` (임시 흰 원)
  `scenes/game/projectiles/Projectile.tscn`으로 저장

- [ ] **Step 2: Projectile.gd 작성**

```gdscript
# scenes/game/projectiles/Projectile.gd
class_name Projectile
extends Area2D

var damage: float = 0.0
var speed: float = 300.0
var direction: Vector2 = Vector2.RIGHT
var target: Node2D = null  # 타겟 추적형일 때 사용 (null이면 직선)

func init(dmg: float, spd: float, dir: Vector2, tgt: Node2D = null) -> void:
    damage = dmg
    speed = spd
    direction = dir.normalized()
    target = tgt

func _physics_process(delta: float) -> void:
    if is_instance_valid(target):
        direction = (target.global_position - global_position).normalized()
    global_position += direction * speed * delta

    # 화면 밖으로 나가면 제거
    var vp = get_viewport().get_visible_rect()
    var cam_pos = get_viewport().get_camera_2d().global_position if get_viewport().get_camera_2d() else Vector2.ZERO
    if global_position.distance_to(cam_pos) > 1000.0:
        queue_free()

func _on_body_entered(body: Node) -> void:
    if body.has_method("take_damage"):
        body.take_damage(damage)
        queue_free()
```

- [ ] **Step 3: Projectile 씬에 스크립트 및 시그널 연결 (에디터)**

  Projectile 씬 선택 → Script: Projectile.gd 연결
  Area2D의 `body_entered` 시그널 → `_on_body_entered` 연결
  Collision Layer/Mask 설정: Layer 3 (projectile), Mask 2 (enemy)

- [ ] **Step 4: 커밋**

```bash
git add scenes/game/projectiles/
git commit -m "feat: add Projectile scene with directional and homing movement"
```

---

### Task 5: Enemy 기본 클래스 + Goblin

**Files:**
- Create: `scenes/game/enemies/Enemy.tscn`
- Create: `scenes/game/enemies/Enemy.gd`
- Create: `scenes/game/enemies/Goblin.tscn`
- Create: `scenes/game/enemies/Goblin.gd`

- [ ] **Step 1: Enemy 씬 생성 (에디터)**

  새 씬 → Root: `CharacterBody2D` → 이름: `Enemy`
  자식 추가: `CollisionShape2D` (CapsuleShape2D, height:20, radius:10), `Sprite2D`, `HealthBar` (ProgressBar, 위에 배치)
  `scenes/game/enemies/Enemy.tscn`으로 저장

- [ ] **Step 2: Enemy.gd 작성**

```gdscript
# scenes/game/enemies/Enemy.gd
class_name Enemy
extends CharacterBody2D

@export var enemy_data: EnemyData

var hp: float = 0.0
var castle_ref: Node2D = null
var attack_timer: float = 0.0

@onready var health_bar: ProgressBar = $HealthBar
@onready var sprite: Sprite2D = $Sprite2D

signal died(enemy: Enemy, xp_amount: int)

func _ready() -> void:
    if enemy_data:
        hp = enemy_data.max_hp
        if health_bar:
            health_bar.max_value = enemy_data.max_hp
            health_bar.value = hp

func init(castle: Node2D) -> void:
    castle_ref = castle

func _physics_process(delta: float) -> void:
    if not is_instance_valid(castle_ref):
        return
    var dist = global_position.distance_to(castle_ref.global_position)
    if dist > enemy_data.attack_range:
        var dir = (castle_ref.global_position - global_position).normalized()
        velocity = dir * enemy_data.move_speed
        move_and_slide()
    else:
        velocity = Vector2.ZERO
        attack_timer -= delta
        if attack_timer <= 0.0:
            attack_timer = enemy_data.attack_interval
            _do_attack()

func _do_attack() -> void:
    if castle_ref.has_method("take_damage"):
        castle_ref.take_damage(enemy_data.damage)

func take_damage(amount: float) -> void:
    hp -= amount
    if health_bar:
        health_bar.value = hp
    if hp <= 0.0:
        emit_signal("died", self, enemy_data.xp_reward)
        queue_free()
```

- [ ] **Step 3: Goblin.tscn + Goblin.gd 작성**

  Enemy.tscn을 상속하여 Goblin.tscn 생성:
  씬 메뉴 → New Inherited Scene → Enemy.tscn 선택 → 이름 Goblin으로 변경
  Sprite2D에 임시 초록 사각형 텍스처 설정
  `scenes/game/enemies/Goblin.tscn`으로 저장

```gdscript
# scenes/game/enemies/Goblin.gd
class_name Goblin
extends Enemy
# 고블린은 Enemy 기본 동작 그대로 사용
# 추후 특수 동작 추가 가능
```

- [ ] **Step 4: 커밋**

```bash
git add scenes/game/enemies/
git commit -m "feat: add Enemy base class and Goblin enemy"
```

---

### Task 6: Castle 씬 + 이동

**Files:**
- Create: `scenes/game/castle/Castle.tscn`
- Create: `scenes/game/castle/Castle.gd`

- [ ] **Step 1: Castle 씬 생성 (에디터)**

  새 씬 → Root: `CharacterBody2D` → 이름: `Castle`
  자식 추가:
  - `CollisionShape2D` (RectangleShape2D, size: 80x80)
  - `Sprite2D` (임시 회색 사각형)
  - `SlotsContainer` (Node2D) — 슬롯들을 담을 컨테이너
  - `Camera2D` (Enabled: true, Position Smoothing: true)

  `scenes/game/castle/Castle.tscn`으로 저장

- [ ] **Step 2: Castle.gd 작성**

```gdscript
# scenes/game/castle/Castle.gd
class_name Castle
extends CharacterBody2D

const SPEED = 120.0

@onready var slots_container: Node2D = $SlotsContainer

var slots: Array = []  # Slot 노드 배열
var slot_scenes: Array[PackedScene] = []  # 배치된 유닛 씬

func _ready() -> void:
    GameState.castle_hp = GameState.castle_max_hp
    _setup_slots()

func _physics_process(delta: float) -> void:
    var dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity = dir * SPEED
    move_and_slide()

func _setup_slots() -> void:
    # 기존 슬롯 제거
    for child in slots_container.get_children():
        child.queue_free()
    slots.clear()

    var count = GameState.slot_count
    var spacing = 50.0
    var total_width = (count - 1) * spacing

    for i in count:
        var slot = preload("res://scenes/game/castle/Slot.tscn").instantiate()
        slot.position = Vector2(-total_width / 2.0 + i * spacing, 0.0)
        slot.slot_index = i
        slots_container.add_child(slot)
        slots.append(slot)

func take_damage(amount: float) -> void:
    GameState.take_castle_damage(amount)

func heal(amount: float) -> void:
    GameState.heal_castle(amount)

func place_unit(slot_index: int, unit_data) -> void:
    if slot_index < 0 or slot_index >= slots.size():
        return
    slots[slot_index].set_unit(unit_data)
```

- [ ] **Step 3: 커밋**

```bash
git add scenes/game/castle/Castle.tscn scenes/game/castle/Castle.gd
git commit -m "feat: add Castle scene with directional movement and slot container"
```

---

### Task 7: Slot 씬

**Files:**
- Create: `scenes/game/castle/Slot.tscn`
- Create: `scenes/game/castle/Slot.gd`

- [ ] **Step 1: Slot 씬 생성 (에디터)**

  새 씬 → Root: `Node2D` → 이름: `Slot`
  자식 추가:
  - `Sprite2D` (임시 반투명 사각형, 비어있음 표시)
  - `UnitContainer` (Node2D) — 실제 유닛 노드가 들어갈 자리

  `scenes/game/castle/Slot.tscn`으로 저장

- [ ] **Step 2: Slot.gd 작성**

```gdscript
# scenes/game/castle/Slot.gd
class_name Slot
extends Node2D

var slot_index: int = 0
var unit_data = null  # HeroData or FacilityData
var unit_node: Node = null

@onready var unit_container: Node2D = $UnitContainer
@onready var slot_sprite: Sprite2D = $Sprite2D

func set_unit(data) -> void:
    # 기존 유닛 제거
    if is_instance_valid(unit_node):
        unit_node.queue_free()
        unit_node = null

    unit_data = data
    if data == null:
        return

    var scene = load(data.scene_path) as PackedScene
    if scene == null:
        push_error("Slot: scene not found at " + data.scene_path)
        return
    unit_node = scene.instantiate()
    unit_node.unit_data = data
    unit_container.add_child(unit_node)

func clear_unit() -> void:
    set_unit(null)

func is_empty() -> bool:
    return unit_node == null
```

- [ ] **Step 3: 커밋**

```bash
git add scenes/game/castle/Slot.tscn scenes/game/castle/Slot.gd
git commit -m "feat: add Slot scene for castle unit placement"
```

---

### Task 8: Hero 기본 클래스 + Archer

**Files:**
- Create: `scenes/game/units/Hero.tscn`
- Create: `scenes/game/units/Hero.gd`
- Create: `scenes/game/units/heroes/Archer.tscn`
- Create: `scenes/game/units/heroes/Archer.gd`

- [ ] **Step 1: Hero 씬 생성 (에디터)**

  새 씬 → Root: `Node2D` → 이름: `Hero`
  자식 추가:
  - `Sprite2D`
  - `DetectionArea` (Area2D)
    - `CollisionShape2D` (CircleShape2D, radius: 200)

  DetectionArea: Collision Layer 없음, Mask: 2 (enemy layer)
  `scenes/game/units/Hero.tscn`으로 저장

- [ ] **Step 2: Hero.gd 작성**

```gdscript
# scenes/game/units/Hero.gd
class_name Hero
extends Node2D

var unit_data: HeroData = null
var hero_level: int = 1
var current_target: Enemy = null
var attack_timer: float = 0.0
var nearby_enemies: Array = []

@onready var detection_area: Area2D = $DetectionArea
@onready var detection_shape: CollisionShape2D = $DetectionArea/CollisionShape2D

func _ready() -> void:
    if unit_data:
        _apply_data()
    # 메타 업그레이드로 초기 레벨 보정
    hero_level = 1 + int(SaveData.get_upgrade_value("hero_level"))
    detection_area.body_entered.connect(_on_body_entered)
    detection_area.body_exited.connect(_on_body_exited)

func _apply_data() -> void:
    var shape = CircleShape2D.new()
    shape.radius = unit_data.attack_range
    detection_shape.shape = shape

func _physics_process(delta: float) -> void:
    nearby_enemies = nearby_enemies.filter(func(e): return is_instance_valid(e))
    if not is_instance_valid(current_target) or current_target not in nearby_enemies:
        current_target = _get_nearest()
    if current_target:
        attack_timer -= delta
        if attack_timer <= 0.0:
            attack_timer = 1.0 / unit_data.attack_speed
            _attack(current_target)

func _get_nearest() -> Enemy:
    if nearby_enemies.is_empty():
        return null
    var nearest: Enemy = nearby_enemies[0]
    var min_dist = global_position.distance_squared_to(nearest.global_position)
    for e in nearby_enemies:
        var d = global_position.distance_squared_to(e.global_position)
        if d < min_dist:
            min_dist = d
            nearest = e
    return nearest

func get_damage() -> float:
    return unit_data.damage * (1.0 + (hero_level - 1) * 0.15)

func _attack(_target: Enemy) -> void:
    pass  # 서브클래스에서 구현

func _on_body_entered(body: Node2D) -> void:
    if body is Enemy:
        nearby_enemies.append(body)

func _on_body_exited(body: Node2D) -> void:
    nearby_enemies.erase(body)

func upgrade() -> void:
    hero_level += 1
    if unit_data:
        var shape = CircleShape2D.new()
        shape.radius = unit_data.attack_range * (1.0 + (hero_level - 1) * 0.05)
        detection_shape.shape = shape
```

- [ ] **Step 3: Archer.tscn + Archer.gd 작성**

  Hero.tscn 상속으로 Archer.tscn 생성:
  씬 메뉴 → New Inherited Scene → Hero.tscn
  이름: Archer, Sprite2D에 임시 파란 삼각형
  `scenes/game/units/heroes/Archer.tscn`으로 저장

```gdscript
# scenes/game/units/heroes/Archer.gd
class_name Archer
extends Hero

const PROJECTILE_SCENE = preload("res://scenes/game/projectiles/Projectile.tscn")

func _attack(target: Enemy) -> void:
    var proj = PROJECTILE_SCENE.instantiate() as Projectile
    proj.global_position = global_position
    var dir = (target.global_position - global_position).normalized()
    proj.init(get_damage(), 300.0, dir)
    get_tree().current_scene.add_child(proj)
```

- [ ] **Step 4: 커밋**

```bash
git add scenes/game/units/
git commit -m "feat: add Hero base class and Archer hero with projectile attack"
```

---

### Task 9: Facility 기본 클래스 + Crossbow

**Files:**
- Create: `scenes/game/units/Facility.tscn`
- Create: `scenes/game/units/Facility.gd`
- Create: `scenes/game/units/facilities/Crossbow.tscn`
- Create: `scenes/game/units/facilities/Crossbow.gd`

- [ ] **Step 1: Facility 씬 생성 (에디터)**

  새 씬 → Root: `Node2D` → 이름: `Facility`
  자식: `Sprite2D`, `DetectionArea`(Area2D) → `CollisionShape2D`(CircleShape2D)
  `scenes/game/units/Facility.tscn`으로 저장

- [ ] **Step 2: Facility.gd 작성**

```gdscript
# scenes/game/units/Facility.gd
class_name Facility
extends Node2D

var unit_data: FacilityData = null
var facility_level: int = 1
var current_target: Enemy = null
var attack_timer: float = 0.0
var nearby_enemies: Array = []

@onready var detection_area: Area2D = $DetectionArea
@onready var detection_shape: CollisionShape2D = $DetectionArea/CollisionShape2D

func _ready() -> void:
    if unit_data:
        var shape = CircleShape2D.new()
        shape.radius = unit_data.attack_range
        detection_shape.shape = shape
    detection_area.body_entered.connect(_on_body_entered)
    detection_area.body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
    nearby_enemies = nearby_enemies.filter(func(e): return is_instance_valid(e))
    if not is_instance_valid(current_target) or current_target not in nearby_enemies:
        current_target = _get_nearest()
    if current_target:
        attack_timer -= delta
        if attack_timer <= 0.0:
            attack_timer = 1.0 / unit_data.attack_speed
            _attack(current_target)

func _get_nearest() -> Enemy:
    if nearby_enemies.is_empty():
        return null
    var nearest: Enemy = nearby_enemies[0]
    var min_dist = global_position.distance_squared_to(nearest.global_position)
    for e in nearby_enemies:
        var d = global_position.distance_squared_to(e.global_position)
        if d < min_dist:
            min_dist = d
            nearest = e
    return nearest

func get_damage() -> float:
    return unit_data.damage * (1.0 + (facility_level - 1) * 0.2)

func _attack(_target: Enemy) -> void:
    pass

func upgrade() -> void:
    facility_level = min(facility_level + 1, unit_data.max_level)

func _on_body_entered(body: Node2D) -> void:
    if body is Enemy:
        nearby_enemies.append(body)

func _on_body_exited(body: Node2D) -> void:
    nearby_enemies.erase(body)
```

- [ ] **Step 3: Crossbow.tscn + Crossbow.gd 작성**

  Facility.tscn 상속으로 Crossbow.tscn 생성
  `scenes/game/units/facilities/Crossbow.tscn`으로 저장

```gdscript
# scenes/game/units/facilities/Crossbow.gd
class_name Crossbow
extends Facility

const PROJECTILE_SCENE = preload("res://scenes/game/projectiles/Projectile.tscn")

func _attack(target: Enemy) -> void:
    var proj = PROJECTILE_SCENE.instantiate() as Projectile
    proj.global_position = global_position
    var dir = (target.global_position - global_position).normalized()
    proj.init(get_damage(), 350.0, dir)
    get_tree().current_scene.add_child(proj)
```

- [ ] **Step 4: 커밋**

```bash
git add scenes/game/units/Facility.tscn scenes/game/units/Facility.gd scenes/game/units/facilities/
git commit -m "feat: add Facility base class and Crossbow facility"
```

---

### Task 10: WaveManager

**Files:**
- Create: `scenes/game/wave/WaveManager.tscn`
- Create: `scenes/game/wave/WaveManager.gd`

- [ ] **Step 1: WaveManager 씬 생성 (에디터)**

  새 씬 → Root: `Node` → 이름: `WaveManager`
  `scenes/game/wave/WaveManager.tscn`으로 저장

- [ ] **Step 2: WaveManager.gd 작성**

```gdscript
# scenes/game/wave/WaveManager.gd
class_name WaveManager
extends Node

@export var wave_data_list: Array[WaveData] = []

var current_wave_index: int = -1
var active_enemies: Array = []
var spawn_timer: float = 0.0
var wave_timer: float = 0.0
var is_wave_active: bool = false
var castle: Castle = null
var enemy_container: Node = null  # 적을 씬 트리에 추가할 부모

signal wave_started(wave_number: int)
signal wave_cleared(wave_number: int)
signal all_waves_cleared()

func init(castle_node: Castle, container: Node) -> void:
    castle = castle_node
    enemy_container = container

func start_next_wave() -> void:
    current_wave_index += 1
    if current_wave_index >= wave_data_list.size():
        emit_signal("all_waves_cleared")
        return
    var wave = wave_data_list[current_wave_index]
    wave_timer = wave.duration
    spawn_timer = 0.0
    is_wave_active = true
    emit_signal("wave_started", current_wave_index + 1)

func _process(delta: float) -> void:
    if not is_wave_active:
        return
    var wave = wave_data_list[current_wave_index]

    spawn_timer -= delta
    if spawn_timer <= 0.0 and active_enemies.size() < wave.max_enemies_at_once:
        spawn_timer = wave.spawn_interval
        _spawn_enemy(wave)

    wave_timer -= delta
    active_enemies = active_enemies.filter(func(e): return is_instance_valid(e))

    if wave_timer <= 0.0 and active_enemies.is_empty():
        is_wave_active = false
        emit_signal("wave_cleared", current_wave_index + 1)

func _spawn_enemy(wave: WaveData) -> void:
    if wave.enemy_pool.is_empty() or not is_instance_valid(castle):
        return
    var data = _pick_enemy(wave)
    var scene = load(data.scene_path) as PackedScene
    if not scene:
        return
    var enemy = scene.instantiate() as Enemy
    enemy.enemy_data = data
    enemy.init(castle)
    enemy.died.connect(_on_enemy_died)
    enemy.global_position = castle.global_position + _random_edge_offset()
    enemy_container.add_child(enemy)
    active_enemies.append(enemy)

func _random_edge_offset() -> Vector2:
    var dist = 500.0 + randf() * 100.0
    var angle = randf() * TAU
    return Vector2(cos(angle), sin(angle)) * dist

func _pick_enemy(wave: WaveData) -> EnemyData:
    var total = 0.0
    for w in wave.spawn_weights:
        total += w
    var r = randf() * total
    var cum = 0.0
    for i in wave.enemy_pool.size():
        cum += wave.spawn_weights[i]
        if r <= cum:
            return wave.enemy_pool[i]
    return wave.enemy_pool[0]

func _on_enemy_died(enemy: Enemy, xp_amount: int) -> void:
    active_enemies.erase(enemy)
    GameState.gain_xp(float(xp_amount))
```

- [ ] **Step 3: 커밋**

```bash
git add scenes/game/wave/
git commit -m "feat: add WaveManager with weighted enemy spawning"
```

---

### Task 11: LevelUp 팝업 + XP UI

**Files:**
- Create: `scenes/ui/LevelUpPopup.tscn`
- Create: `scenes/ui/LevelUpPopup.gd`

- [ ] **Step 1: LevelUpPopup 씬 생성 (에디터)**

  새 씬 → Root: `CanvasLayer` → 이름: `LevelUpPopup`
  자식:
  - `PanelContainer` (화면 중앙, 크기 600x400)
    - `VBoxContainer`
      - `Label` (이름: TitleLabel, 텍스트: "Level Up!")
      - `HBoxContainer` (이름: ChoicesContainer) — 선택지 3개가 들어갈 곳

  `scenes/ui/LevelUpPopup.tscn`으로 저장

- [ ] **Step 2: LevelUpPopup.gd 작성**

```gdscript
# scenes/ui/LevelUpPopup.gd
class_name LevelUpPopup
extends CanvasLayer

@onready var choices_container: HBoxContainer = $PanelContainer/VBoxContainer/ChoicesContainer

var choice_button_scene = preload("res://scenes/ui/ChoiceButton.tscn")  # Task 11 Step 3에서 생성

signal choice_made(data)

func show_choices(choices: Array) -> void:
    get_tree().paused = true
    visible = true
    for child in choices_container.get_children():
        child.queue_free()
    for data in choices:
        var btn = choice_button_scene.instantiate()
        btn.setup(data)
        btn.pressed.connect(_on_choice_selected.bind(data))
        choices_container.add_child(btn)

func _on_choice_selected(data) -> void:
    get_tree().paused = false
    visible = false
    emit_signal("choice_made", data)
```

- [ ] **Step 3: ChoiceButton 씬 생성 (에디터)**

  새 씬 → Root: `Button` → 이름: `ChoiceButton`
  자식: `VBoxContainer` → `TextureRect`(아이콘), `Label`(이름), `Label`(설명)
  `scenes/ui/ChoiceButton.tscn`으로 저장

```gdscript
# scenes/ui/ChoiceButton.gd
class_name ChoiceButton
extends Button

@onready var icon_rect: TextureRect = $VBoxContainer/TextureRect
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var desc_label: Label = $VBoxContainer/DescLabel

func setup(data) -> void:
    name_label.text = data.display_name
    desc_label.text = data.description
    if data.icon:
        icon_rect.texture = data.icon
```

- [ ] **Step 4: 커밋**

```bash
git add scenes/ui/LevelUpPopup.tscn scenes/ui/LevelUpPopup.gd scenes/ui/ChoiceButton.tscn scenes/ui/ChoiceButton.gd
git commit -m "feat: add LevelUpPopup with paused 3-choice selection"
```

---

### Task 12: WaveIntermission UI

**Files:**
- Create: `scenes/ui/WaveIntermission.tscn`
- Create: `scenes/ui/WaveIntermission.gd`

- [ ] **Step 1: WaveIntermission 씬 생성 (에디터)**

  새 씬 → Root: `CanvasLayer` → 이름: `WaveIntermission`
  자식:
  - `PanelContainer` (우측 패널, 너비 300)
    - `VBoxContainer`
      - `Label` (이름: WaveLabel, 텍스트: "Wave 1 Clear!")
      - `Label` (이름: TimerLabel)
      - `ScrollContainer` → `VBoxContainer` (이름: SlotList) — 슬롯 목록
      - `Button` (이름: ReadyButton, 텍스트: "전투 시작")

  `scenes/ui/WaveIntermission.tscn`으로 저장

- [ ] **Step 2: WaveIntermission.gd 작성**

```gdscript
# scenes/ui/WaveIntermission.gd
class_name WaveIntermission
extends CanvasLayer

const AUTO_START_TIME = 15.0

@onready var wave_label: Label = $PanelContainer/VBoxContainer/WaveLabel
@onready var timer_label: Label = $PanelContainer/VBoxContainer/TimerLabel
@onready var slot_list: VBoxContainer = $PanelContainer/VBoxContainer/ScrollContainer/SlotList
@onready var ready_button: Button = $PanelContainer/VBoxContainer/ReadyButton

var time_remaining: float = AUTO_START_TIME
var castle_ref: Castle = null

signal intermission_done()

func _ready() -> void:
    ready_button.pressed.connect(_on_ready_pressed)

func show_intermission(wave_number: int, castle: Castle) -> void:
    castle_ref = castle
    visible = true
    time_remaining = AUTO_START_TIME
    wave_label.text = "Wave %d Clear!" % wave_number
    _refresh_slot_list()

func _process(delta: float) -> void:
    if not visible:
        return
    time_remaining -= delta
    timer_label.text = "자동 시작: %ds" % int(ceil(time_remaining))
    if time_remaining <= 0.0:
        _finish()

func _refresh_slot_list() -> void:
    for child in slot_list.get_children():
        child.queue_free()
    for i in GameState.slot_count:
        var label = Label.new()
        var slot_data = GameState.slots[i]
        if slot_data.unit_data:
            label.text = "슬롯 %d: %s" % [i + 1, slot_data.unit_data.display_name]
        else:
            label.text = "슬롯 %d: 비어있음" % (i + 1)
        slot_list.add_child(label)

func _on_ready_pressed() -> void:
    _finish()

func _finish() -> void:
    visible = false
    emit_signal("intermission_done")
```

- [ ] **Step 3: 커밋**

```bash
git add scenes/ui/WaveIntermission.tscn scenes/ui/WaveIntermission.gd
git commit -m "feat: add WaveIntermission UI with auto-start timer"
```

---

### Task 13: HUD

**Files:**
- Create: `scenes/ui/HUD.tscn`
- Create: `scenes/ui/HUD.gd`

- [ ] **Step 1: HUD 씬 생성 (에디터)**

  새 씬 → Root: `CanvasLayer` → 이름: `HUD`
  자식:
  - `VBoxContainer` (좌상단 앵커)
    - `ProgressBar` (이름: HPBar, max: 100)
    - `Label` (이름: HPLabel)
    - `ProgressBar` (이름: XPBar, max: 10)
    - `Label` (이름: LevelLabel)
  - `Label` (이름: WaveLabel, 상단 중앙)
  - `Label` (이름: GoldLabel, 우상단)

  `scenes/ui/HUD.tscn`으로 저장

- [ ] **Step 2: HUD.gd 작성**

```gdscript
# scenes/ui/HUD.gd
class_name HUD
extends CanvasLayer

@onready var hp_bar: ProgressBar = $VBoxContainer/HPBar
@onready var hp_label: Label = $VBoxContainer/HPLabel
@onready var xp_bar: ProgressBar = $VBoxContainer/XPBar
@onready var level_label: Label = $VBoxContainer/LevelLabel
@onready var wave_label: Label = $WaveLabel
@onready var gold_label: Label = $GoldLabel

func _process(_delta: float) -> void:
    hp_bar.max_value = GameState.castle_max_hp
    hp_bar.value = GameState.castle_hp
    hp_label.text = "%d / %d" % [int(GameState.castle_hp), int(GameState.castle_max_hp)]

    xp_bar.max_value = GameState.xp_to_next_level
    xp_bar.value = GameState.xp
    level_label.text = "Lv. %d" % GameState.level

    gold_label.text = "Gold: %d" % GameState.gold

func set_wave(wave_number: int, total_waves: int) -> void:
    wave_label.text = "Wave %d / %d" % [wave_number, total_waves]
```

- [ ] **Step 3: 커밋**

```bash
git add scenes/ui/HUD.tscn scenes/ui/HUD.gd
git commit -m "feat: add HUD with HP, XP, level, wave, gold display"
```

---

### Task 14: Game 루트 씬 (코디네이터)

**Files:**
- Create: `scenes/game/Game.tscn`
- Create: `scenes/game/Game.gd`

- [ ] **Step 1: Game 씬 생성 (에디터)**

  새 씬 → Root: `Node2D` → 이름: `Game`
  자식 인스턴스로 추가:
  - `Castle.tscn` 인스턴스
  - `WaveManager.tscn` 인스턴스
  - `Node2D` (이름: EnemyContainer)
  - `HUD.tscn` 인스턴스
  - `LevelUpPopup.tscn` 인스턴스 (visible: false)
  - `WaveIntermission.tscn` 인스턴스 (visible: false)

  `scenes/game/Game.tscn`으로 저장

- [ ] **Step 2: Game.gd 작성**

```gdscript
# scenes/game/Game.gd
class_name Game
extends Node2D

@onready var castle: Castle = $Castle
@onready var wave_manager: WaveManager = $WaveManager
@onready var enemy_container: Node2D = $EnemyContainer
@onready var hud: HUD = $HUD
@onready var levelup_popup: LevelUpPopup = $LevelUpPopup
@onready var wave_intermission: WaveIntermission = $WaveIntermission

var total_waves: int = 0

func _ready() -> void:
    GameState.reset_run()
    _load_unit_pools()
    _connect_signals()

    wave_manager.init(castle, enemy_container)
    total_waves = wave_manager.wave_data_list.size()

    # 첫 웨이브 시작
    wave_manager.start_next_wave()

func _load_unit_pools() -> void:
    GameState.hero_pool.clear()
    GameState.facility_pool.clear()
    # 리소스 로드 (Task 21에서 .tres 파일 생성 후 사용)
    var hero_dir = DirAccess.open("res://resources/heroes/")
    if hero_dir:
        hero_dir.list_dir_begin()
        var fname = hero_dir.get_next()
        while fname != "":
            if fname.ends_with(".tres"):
                var data = load("res://resources/heroes/" + fname) as HeroData
                if data:
                    GameState.hero_pool.append(data)
            fname = hero_dir.get_next()
    var fac_dir = DirAccess.open("res://resources/facilities/")
    if fac_dir:
        fac_dir.list_dir_begin()
        var fname2 = fac_dir.get_next()
        while fname2 != "":
            if fname2.ends_with(".tres"):
                var data = load("res://resources/facilities/" + fname2) as FacilityData
                if data:
                    GameState.facility_pool.append(data)
            fname2 = fac_dir.get_next()

func _connect_signals() -> void:
    wave_manager.wave_started.connect(_on_wave_started)
    wave_manager.wave_cleared.connect(_on_wave_cleared)
    wave_manager.all_waves_cleared.connect(_on_all_waves_cleared)
    GameState.level_up_triggered.connect(levelup_popup.show_choices)
    GameState.castle_died.connect(_on_castle_died)
    levelup_popup.choice_made.connect(_on_choice_made)
    wave_intermission.intermission_done.connect(_on_intermission_done)

func _on_wave_started(wave_number: int) -> void:
    hud.set_wave(wave_number, total_waves)

func _on_wave_cleared(wave_number: int) -> void:
    GameState.gold += 50  # 웨이브 클리어 보상
    wave_intermission.show_intermission(wave_number, castle)

func _on_all_waves_cleared() -> void:
    var gold_reward = 200
    GameState.gold += gold_reward
    SaveData.add_gold(gold_reward)
    SaveData.unlocked_stages.append(GameState.current_stage + 1)
    SaveData.save()
    GameState.emit_signal("stage_cleared", GameState.current_stage, gold_reward)
    get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")

func _on_castle_died() -> void:
    get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn")

func _on_choice_made(data) -> void:
    # 빈 슬롯이 있으면 배치, 없으면 첫 슬롯에 배치
    var placed = false
    for i in castle.slots.size():
        if castle.slots[i].is_empty():
            castle.place_unit(i, data)
            GameState.slots[i].unit_data = data
            placed = true
            break
    if not placed and castle.slots.size() > 0:
        # 풀 상태: 교체 선택 UI (간단히 첫 슬롯 교체)
        castle.place_unit(0, data)
        GameState.slots[0].unit_data = data

func _on_intermission_done() -> void:
    wave_manager.start_next_wave()
```

- [ ] **Step 3: Game.tscn을 메인 씬으로 설정**

  Project > Project Settings > Application > Run > Main Scene → `res://scenes/game/Game.tscn`

- [ ] **Step 4: 커밋**

```bash
git add scenes/game/Game.tscn scenes/game/Game.gd
git commit -m "feat: add Game coordinator scene connecting all subsystems"
```

---

### Task 15: Main Menu + Stage Select

**Files:**
- Create: `scenes/main_menu/MainMenu.tscn` + `MainMenu.gd`
- Create: `scenes/stage_select/StageSelect.tscn` + `StageSelect.gd`

- [ ] **Step 1: MainMenu 씬 생성 (에디터)**

  새 씬 → Root: `Control` → 이름: `MainMenu`
  자식: `VBoxContainer` (중앙) →
  - `Label` ("Living Mansion")
  - `Button` (이름: PlayButton, "게임 시작")
  - `Button` (이름: UpgradeButton, "업그레이드")
  - `Button` (이름: QuitButton, "종료")

  `scenes/main_menu/MainMenu.tscn`으로 저장

```gdscript
# scenes/main_menu/MainMenu.gd
extends Control

@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var upgrade_button: Button = $VBoxContainer/UpgradeButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready() -> void:
    play_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/stage_select/StageSelect.tscn"))
    upgrade_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/ui/MetaScreen.tscn"))
    quit_button.pressed.connect(func(): get_tree().quit())
```

- [ ] **Step 2: StageSelect 씬 생성 (에디터)**

  새 씬 → Root: `Control` → 이름: `StageSelect`
  자식:
  - `Label` ("스테이지 선택")
  - `GridContainer` (이름: StageGrid, columns: 5)
  - `Button` (이름: BackButton, "뒤로")

  `scenes/stage_select/StageSelect.tscn`으로 저장

```gdscript
# scenes/stage_select/StageSelect.gd
extends Control

@onready var stage_grid: GridContainer = $StageGrid
@onready var back_button: Button = $BackButton

func _ready() -> void:
    back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn"))
    _build_stage_buttons()

func _build_stage_buttons() -> void:
    for child in stage_grid.get_children():
        child.queue_free()
    for i in range(1, 6):  # 스테이지 1~5
        var btn = Button.new()
        btn.text = "Stage %d" % i
        btn.disabled = not (i in SaveData.unlocked_stages)
        btn.pressed.connect(_on_stage_selected.bind(i))
        stage_grid.add_child(btn)

func _on_stage_selected(stage_number: int) -> void:
    GameState.current_stage = stage_number
    get_tree().change_scene_to_file("res://scenes/game/Game.tscn")
```

- [ ] **Step 3: 커밋**

```bash
git add scenes/main_menu/ scenes/stage_select/
git commit -m "feat: add MainMenu and StageSelect screens"
```

---

### Task 16: Placement Screen (출발 전 배치)

**Files:**
- Create: `scenes/placement/PlacementScreen.tscn`
- Create: `scenes/placement/PlacementScreen.gd`

- [ ] **Step 1: PlacementScreen 씬 생성 (에디터)**

  새 씬 → Root: `Control` → 이름: `PlacementScreen`
  자식:
  - `Label` ("배치 화면")
  - `HBoxContainer` (이름: SlotRow) — 슬롯 미리보기
  - `ScrollContainer` → `VBoxContainer` (이름: UnitList) — 보유 유닛 목록
  - `Button` (이름: StartButton, "전투 시작")
  - `Button` (이름: BackButton, "뒤로")

  `scenes/placement/PlacementScreen.tscn`으로 저장

```gdscript
# scenes/placement/PlacementScreen.gd
extends Control

@onready var slot_row: HBoxContainer = $SlotRow
@onready var unit_list: VBoxContainer = $ScrollContainer/UnitList
@onready var start_button: Button = $StartButton
@onready var back_button: Button = $BackButton

var selected_unit_data = null
var selected_slot: int = -1

func _ready() -> void:
    start_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/game/Game.tscn"))
    back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/stage_select/StageSelect.tscn"))
    _build_slots()
    _build_unit_list()

func _build_slots() -> void:
    for child in slot_row.get_children():
        child.queue_free()
    for i in GameState.slot_count:
        var btn = Button.new()
        var slot = GameState.slots[i]
        btn.text = slot.unit_data.display_name if slot.unit_data else "빈 슬롯"
        btn.pressed.connect(_on_slot_clicked.bind(i))
        slot_row.add_child(btn)

func _build_unit_list() -> void:
    for child in unit_list.get_children():
        child.queue_free()
    var all = []
    all.append_array(GameState.hero_pool)
    all.append_array(GameState.facility_pool)
    for data in all:
        var btn = Button.new()
        btn.text = data.display_name
        btn.pressed.connect(_on_unit_selected.bind(data))
        unit_list.add_child(btn)

func _on_slot_clicked(index: int) -> void:
    selected_slot = index
    if selected_unit_data and selected_slot >= 0:
        GameState.slots[selected_slot].unit_data = selected_unit_data
        _build_slots()

func _on_unit_selected(data) -> void:
    selected_unit_data = data
    if selected_slot >= 0:
        GameState.slots[selected_slot].unit_data = data
        _build_slots()
```

- [ ] **Step 2: StageSelect에서 PlacementScreen으로 이동하도록 수정**

```gdscript
# scenes/stage_select/StageSelect.gd 의 _on_stage_selected 수정
func _on_stage_selected(stage_number: int) -> void:
    GameState.current_stage = stage_number
    GameState.reset_run()
    get_tree().change_scene_to_file("res://scenes/placement/PlacementScreen.tscn")
```

- [ ] **Step 3: 커밋**

```bash
git add scenes/placement/ scenes/stage_select/StageSelect.gd
git commit -m "feat: add PlacementScreen for pre-battle unit setup"
```

---

### Task 17: Meta Upgrade Screen

**Files:**
- Create: `scenes/ui/MetaScreen.tscn`
- Create: `scenes/ui/MetaScreen.gd`
- Create: `resources/meta_upgrades/upgrades.tres`

- [ ] **Step 1: MetaUpgradeData 리소스 파일 생성 (에디터)**

  FileSystem에서 `resources/meta_upgrades/` 우클릭 → New Resource → `MetaUpgradeData`
  6개 생성:

  | 파일명 | id | display_name | upgrade_type | cost | value_per_level |
  |--------|-----|-------------|--------------|------|-----------------|
  | slot_expand.tres | slot_count | 슬롯 확장 | slot_count | 150 | 1 |
  | hp_up.tres | max_hp | 성 HP 강화 | max_hp | 100 | 1 |
  | start_gold.tres | start_gold | 초기 골드 | start_gold | 80 | 50 |
  | hero_level.tres | hero_level | 영웅 초기 레벨 | hero_level | 200 | 1 |
  | xp_bonus.tres | xp_bonus | 경험치 보너스 | xp_bonus | 120 | 1 |
  | fac_discount.tres | facility_discount | 시설 할인 | facility_discount | 100 | 1 |

- [ ] **Step 2: MetaScreen 씬 생성 (에디터)**

  새 씬 → Root: `Control` → 이름: `MetaScreen`
  자식:
  - `Label` ("영구 업그레이드")
  - `Label` (이름: GoldLabel)
  - `ScrollContainer` → `VBoxContainer` (이름: UpgradeList)
  - `Button` (이름: BackButton, "뒤로")

  `scenes/ui/MetaScreen.tscn`으로 저장

```gdscript
# scenes/ui/MetaScreen.gd
extends Control

const UPGRADE_PATHS = [
    "res://resources/meta_upgrades/slot_expand.tres",
    "res://resources/meta_upgrades/hp_up.tres",
    "res://resources/meta_upgrades/start_gold.tres",
    "res://resources/meta_upgrades/hero_level.tres",
    "res://resources/meta_upgrades/xp_bonus.tres",
    "res://resources/meta_upgrades/fac_discount.tres",
]

@onready var gold_label: Label = $GoldLabel
@onready var upgrade_list: VBoxContainer = $ScrollContainer/UpgradeList
@onready var back_button: Button = $BackButton

func _ready() -> void:
    back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu/MainMenu.tscn"))
    _build_list()

func _build_list() -> void:
    gold_label.text = "보유 골드: %d" % SaveData.total_gold
    for child in upgrade_list.get_children():
        child.queue_free()
    for path in UPGRADE_PATHS:
        var data = load(path) as MetaUpgradeData
        if not data:
            continue
        var current_level = SaveData.get_upgrade_level(data.id)
        var hbox = HBoxContainer.new()
        var lbl = Label.new()
        lbl.text = "%s  Lv.%d/%d  (비용: %d골드)" % [data.display_name, current_level, data.max_level, data.cost]
        lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        var btn = Button.new()
        btn.text = "업그레이드"
        btn.disabled = current_level >= data.max_level or SaveData.total_gold < data.cost
        btn.pressed.connect(_on_upgrade.bind(data))
        hbox.add_child(lbl)
        hbox.add_child(btn)
        upgrade_list.add_child(hbox)

func _on_upgrade(data: MetaUpgradeData) -> void:
    if SaveData.try_upgrade(data.id, data.cost, data.max_level):
        _build_list()
```

- [ ] **Step 3: 커밋**

```bash
git add scenes/ui/MetaScreen.tscn scenes/ui/MetaScreen.gd resources/meta_upgrades/
git commit -m "feat: add MetaScreen and permanent upgrade resources"
```

---

### Task 18: 추가 영웅 (Mage, Knight, Priest, Alchemist)

**Files:**
- Create: `scenes/game/units/heroes/{Mage,Knight,Priest,Alchemist}.tscn + .gd`

각 영웅은 Hero.tscn 상속. Archer.gd의 패턴을 따름.

- [ ] **Step 1: Mage.gd 작성**

```gdscript
# scenes/game/units/heroes/Mage.gd
class_name Mage
extends Hero

const PROJECTILE_SCENE = preload("res://scenes/game/projectiles/Projectile.tscn")

func _attack(_target: Enemy) -> void:
    # 탐지된 모든 적에게 광역 투사체 발사
    for enemy in nearby_enemies.slice(0, 5):
        if not is_instance_valid(enemy):
            continue
        var proj = PROJECTILE_SCENE.instantiate() as Projectile
        proj.global_position = global_position
        var dir = (enemy.global_position - global_position).normalized()
        proj.init(get_damage() * 0.7, 250.0, dir)  # 광역이므로 데미지 70%
        get_tree().current_scene.add_child(proj)
```

- [ ] **Step 2: Knight.gd 작성**

```gdscript
# scenes/game/units/heroes/Knight.gd
class_name Knight
extends Hero

# 기사: 근접 공격 (사거리 내 적에게 직접 데미지, 투사체 없음)
func _attack(target: Enemy) -> void:
    if is_instance_valid(target):
        target.take_damage(get_damage())
```

- [ ] **Step 3: Priest.gd 작성**

```gdscript
# scenes/game/units/heroes/Priest.gd
class_name Priest
extends Hero

# 성직자: 적 공격 대신 성 힐
func _physics_process(delta: float) -> void:
    attack_timer -= delta
    if attack_timer <= 0.0:
        attack_timer = 1.0 / unit_data.attack_speed
        GameState.heal_castle(unit_data.damage)  # damage 필드를 힐량으로 재사용
```

- [ ] **Step 4: Alchemist.gd 작성**

```gdscript
# scenes/game/units/heroes/Alchemist.gd
class_name Alchemist
extends Hero

# 연금술사: 골드 생성
func _physics_process(delta: float) -> void:
    attack_timer -= delta
    if attack_timer <= 0.0:
        attack_timer = 1.0 / unit_data.attack_speed
        GameState.gold += int(unit_data.damage)  # damage 필드를 골드 생성량으로 재사용
```

- [ ] **Step 5: 각 .tscn 생성 (에디터)**

  Mage, Knight, Priest, Alchemist 각각 Hero.tscn 상속으로 생성,
  해당 .gd 스크립트 연결, Sprite2D에 구분 가능한 임시 색상 설정

- [ ] **Step 6: 커밋**

```bash
git add scenes/game/units/heroes/
git commit -m "feat: add Mage, Knight, Priest, Alchemist heroes"
```

---

### Task 19: 추가 시설 (Catapult, SpikeFence, HealingFountain, ManaOrb)

**Files:**
- Create: `scenes/game/units/facilities/{Catapult,SpikeFence,HealingFountain,ManaOrb}.tscn + .gd`

- [ ] **Step 1: Catapult.gd 작성**

```gdscript
# scenes/game/units/facilities/Catapult.gd
class_name Catapult
extends Facility

const PROJECTILE_SCENE = preload("res://scenes/game/projectiles/Projectile.tscn")

func _attack(target: Enemy) -> void:
    # 느리지만 큰 광역 투사체
    var proj = PROJECTILE_SCENE.instantiate() as Projectile
    proj.global_position = global_position
    var dir = (target.global_position - global_position).normalized()
    proj.init(get_damage(), 150.0, dir, target)  # 타겟 추적형
    # 착탄 시 주변 범위 피해는 Projectile 확장으로 구현 (추후)
    get_tree().current_scene.add_child(proj)
```

- [ ] **Step 2: SpikeFence.gd 작성**

```gdscript
# scenes/game/units/facilities/SpikeFence.gd
class_name SpikeFence
extends Facility

# 가시 방벽: 일정 범위 내 적에게 지속 데미지 (투사체 없음)
func _attack(target: Enemy) -> void:
    if is_instance_valid(target):
        target.take_damage(get_damage())
```

- [ ] **Step 3: HealingFountain.gd 작성**

```gdscript
# scenes/game/units/facilities/HealingFountain.gd
class_name HealingFountain
extends Facility

func _physics_process(delta: float) -> void:
    attack_timer -= delta
    if attack_timer <= 0.0:
        attack_timer = 1.0 / unit_data.attack_speed
        GameState.heal_castle(get_damage())
```

- [ ] **Step 4: ManaOrb.gd 작성**

```gdscript
# scenes/game/units/facilities/ManaOrb.gd
class_name ManaOrb
extends Facility

# 마나 오브: 인접 슬롯의 유닛 공격속도 버프 (매 틱마다 버프 적용은 단순화: XP 보너스로 대체)
func _physics_process(delta: float) -> void:
    attack_timer -= delta
    if attack_timer <= 0.0:
        attack_timer = 1.0 / unit_data.attack_speed
        # 소량 XP 지급으로 구현 (간접 버프 효과)
        GameState.gain_xp(0.5)
```

- [ ] **Step 5: 각 .tscn 생성 (에디터)**

  각각 Facility.tscn 상속으로 생성, 해당 .gd 연결

- [ ] **Step 6: 커밋**

```bash
git add scenes/game/units/facilities/
git commit -m "feat: add Catapult, SpikeFence, HealingFountain, ManaOrb facilities"
```

---

### Task 20: 추가 적 (Orc, GoblinArcher, Troll, Boss)

**Files:**
- Create: `scenes/game/enemies/{Orc,GoblinArcher,Troll,Boss}.tscn + .gd`

- [ ] **Step 1: Orc.gd 작성**

```gdscript
# scenes/game/enemies/Orc.gd
class_name Orc
extends Enemy
# 느리고 HP 높음 — Enemy 기본 동작 그대로
```

- [ ] **Step 2: GoblinArcher.gd 작성**

```gdscript
# scenes/game/enemies/GoblinArcher.gd
class_name GoblinArcher
extends Enemy

const PROJECTILE_SCENE = preload("res://scenes/game/projectiles/Projectile.tscn")

func _do_attack() -> void:
    # 원거리: 투사체 발사
    var proj = PROJECTILE_SCENE.instantiate() as Projectile
    proj.global_position = global_position
    var dir = (castle_ref.global_position - global_position).normalized()
    proj.init(enemy_data.damage, enemy_data.projectile_speed, dir)
    # 투사체가 성을 맞춰야 하므로 collision 설정 조정 필요
    get_tree().current_scene.add_child(proj)
```

- [ ] **Step 3: Troll.gd 작성**

```gdscript
# scenes/game/enemies/Troll.gd
class_name Troll
extends Enemy

# 트롤: 광역 공격 — 성 근처의 모든 슬롯 유닛에게도 데미지 (단순화: 성에 1.5배 데미지)
func _do_attack() -> void:
    if castle_ref.has_method("take_damage"):
        castle_ref.take_damage(enemy_data.damage * 1.5)
```

- [ ] **Step 4: Boss.gd 작성**

```gdscript
# scenes/game/enemies/Boss.gd
class_name Boss
extends Enemy

var phase: int = 1  # HP 50% 이하면 2페이즈

func take_damage(amount: float) -> void:
    super.take_damage(amount)
    if hp <= enemy_data.max_hp * 0.5 and phase == 1:
        phase = 2
        # 2페이즈: 이동속도 1.5배
        # enemy_data는 Resource이므로 직접 수정 불가 → 로컬 변수로 오버라이드
        _enter_phase_2()

func _enter_phase_2() -> void:
    # 직접 velocity 배율을 높임 (move_speed를 override)
    pass  # _physics_process에서 phase 체크로 구현

func _physics_process(delta: float) -> void:
    if not is_instance_valid(castle_ref):
        return
    var speed_mult = 1.5 if phase == 2 else 1.0
    var dist = global_position.distance_to(castle_ref.global_position)
    if dist > enemy_data.attack_range:
        var dir = (castle_ref.global_position - global_position).normalized()
        velocity = dir * enemy_data.move_speed * speed_mult
        move_and_slide()
    else:
        velocity = Vector2.ZERO
        attack_timer -= delta
        if attack_timer <= 0.0:
            attack_timer = enemy_data.attack_interval
            _do_attack()
```

- [ ] **Step 5: 각 .tscn 생성 (에디터)**

  각각 Enemy.tscn 상속으로 생성, 해당 .gd 연결, 임시 색상 구분

  GoblinArcher: is_ranged 체크를 위해 충돌 레이어/마스크 조정
  - GoblinArcher 투사체: Collision Layer 4(enemy_projectile), Mask 1(castle)
  - Castle: Collision Mask에 Layer 4 추가

- [ ] **Step 6: 커밋**

```bash
git add scenes/game/enemies/
git commit -m "feat: add Orc, GoblinArcher, Troll, Boss enemies"
```

---

### Task 21: 리소스 .tres 파일 생성 (영웅/시설/적/웨이브)

**Files:**
- Create: `resources/heroes/*.tres`
- Create: `resources/facilities/*.tres`
- Create: `resources/enemies/*.tres`
- Create: `resources/waves/stage_1/*.tres`

- [ ] **Step 1: 영웅 리소스 생성 (에디터에서 각각 New Resource → HeroData)**

  | 파일 | id | display_name | scene_path | damage | attack_speed | attack_range |
  |------|-----|-------------|-----------|--------|-------------|-------------|
  | archer.tres | archer | 궁수 | res://scenes/game/units/heroes/Archer.tscn | 12 | 1.2 | 220 |
  | mage.tres | mage | 마법사 | res://scenes/game/units/heroes/Mage.tscn | 18 | 0.7 | 250 |
  | knight.tres | knight | 기사 | res://scenes/game/units/heroes/Knight.tscn | 20 | 0.9 | 70 |
  | priest.tres | priest | 성직자 | res://scenes/game/units/heroes/Priest.tscn | 8 | 0.5 | 0 |
  | alchemist.tres | alchemist | 연금술사 | res://scenes/game/units/heroes/Alchemist.tscn | 5 | 0.3 | 0 |

- [ ] **Step 2: 시설 리소스 생성 (New Resource → FacilityData)**

  | 파일 | id | display_name | scene_path | damage | attack_speed | attack_range |
  |------|-----|-------------|-----------|--------|-------------|-------------|
  | crossbow.tres | crossbow | 석궁 포탑 | res://scenes/game/units/facilities/Crossbow.tscn | 8 | 1.8 | 200 |
  | catapult.tres | catapult | 화염 투석기 | res://scenes/game/units/facilities/Catapult.tscn | 25 | 0.4 | 280 |
  | spike_fence.tres | spike_fence | 가시 방벽 | res://scenes/game/units/facilities/SpikeFence.tscn | 6 | 2.0 | 60 |
  | healing_fountain.tres | healing_fountain | 치료 분수 | res://scenes/game/units/facilities/HealingFountain.tscn | 5 | 0.5 | 0 |
  | mana_orb.tres | mana_orb | 마나 오브 | res://scenes/game/units/facilities/ManaOrb.tscn | 0 | 1.0 | 0 |

- [ ] **Step 3: 적 리소스 생성 (New Resource → EnemyData)**

  | 파일 | id | max_hp | move_speed | damage | attack_range | xp_reward | attack_interval |
  |------|-----|--------|-----------|--------|-------------|----------|----------------|
  | goblin.tres | goblin | 20 | 120 | 4 | 55 | 1 | 1.0 |
  | orc.tres | orc | 80 | 55 | 12 | 60 | 3 | 1.5 |
  | goblin_archer.tres | goblin_archer | 25 | 70 | 6 | 250 | 2 | 1.2 |
  | troll.tres | troll | 150 | 45 | 18 | 65 | 5 | 2.0 |
  | boss_stage1.tres | boss_stage1 | 500 | 60 | 20 | 65 | 20 | 1.5 |

  goblin_archer.tres: is_ranged=true, projectile_speed=200, scene_path=GoblinArcher.tscn
  boss_stage1.tres: scene_path=Boss.tscn

- [ ] **Step 4: 웨이브 리소스 생성 (New Resource → WaveData)**

  `resources/waves/stage_1/` 안에 4개 생성:

  **wave_1.tres:** wave_number=1, duration=35, spawn_interval=2.5, enemy_pool=[goblin], spawn_weights=[1.0], max_enemies_at_once=15

  **wave_2.tres:** wave_number=2, duration=40, spawn_interval=2.0, enemy_pool=[goblin, orc], spawn_weights=[0.7, 0.3], max_enemies_at_once=18

  **wave_3.tres:** wave_number=3, duration=45, spawn_interval=1.5, enemy_pool=[goblin, orc, goblin_archer], spawn_weights=[0.5, 0.3, 0.2], max_enemies_at_once=20

  **boss.tres:** wave_number=4, duration=120, spawn_interval=5.0, enemy_pool=[boss_stage1, goblin], spawn_weights=[0.2, 0.8], max_enemies_at_once=10, is_boss_wave=true

- [ ] **Step 5: Game.tscn의 WaveManager에 wave_data_list 설정 (에디터)**

  Game.tscn 열기 → WaveManager 선택 → Inspector에서 wave_data_list에
  wave_1.tres, wave_2.tres, wave_3.tres, boss.tres 순서로 추가

- [ ] **Step 6: 커밋**

```bash
git add resources/
git commit -m "feat: add all hero, facility, enemy, and wave resources for stage 1"
```

---

### Task 22: 통합 테스트 + 메타 업그레이드 테스트

**Files:**
- Create: `tests/test_meta_upgrades.gd`

- [ ] **Step 1: 메타 업그레이드 테스트 작성**

```gdscript
# tests/test_meta_upgrades.gd
extends GutTest

func before_each() -> void:
    SaveData.meta_upgrades = {}
    SaveData.total_gold = 500

func test_upgrade_succeeds_with_enough_gold() -> void:
    var result = SaveData.try_upgrade("slot_count", 150, 3)
    assert_true(result)
    assert_eq(SaveData.get_upgrade_level("slot_count"), 1)
    assert_eq(SaveData.total_gold, 350)

func test_upgrade_fails_without_gold() -> void:
    SaveData.total_gold = 50
    var result = SaveData.try_upgrade("slot_count", 150, 3)
    assert_false(result)
    assert_eq(SaveData.get_upgrade_level("slot_count"), 0)

func test_upgrade_fails_at_max_level() -> void:
    SaveData.meta_upgrades["slot_count"] = 3
    var result = SaveData.try_upgrade("slot_count", 150, 3)
    assert_false(result)

func test_get_upgrade_value_returns_zero_for_unset() -> void:
    assert_eq(SaveData.get_upgrade_value("nonexistent"), 0.0)
```

- [ ] **Step 2: 테스트 실행**

```bash
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
```

Expected: 전체 테스트 통과

- [ ] **Step 3: 게임 실행 확인**

  Godot 에디터에서 F5 (또는 Run) → 다음 확인:
  - MainMenu 표시됨
  - Stage 1 선택 → PlacementScreen 표시
  - 전투 시작 → Castle 이동, 적 스폰, 자동 공격
  - 레벨업 팝업 표시 및 선택 작동
  - 웨이브 클리어 → WaveIntermission 표시
  - 보스 처치 → MainMenu 복귀, 골드 지급

- [ ] **Step 4: 최종 커밋**

```bash
git add tests/test_meta_upgrades.gd
git commit -m "test: add meta upgrade tests and complete MVP integration"
git push origin master
```

---

## 구현 순서 요약

| 단계 | 작업 | 결과물 |
|------|------|--------|
| 1 | Task 1-3 | 프로젝트 + 데이터 구조 + 오토로드 |
| 2 | Task 4-5 | Projectile + Enemy 기본 |
| 3 | Task 6-7 | Castle + Slot |
| 4 | Task 8-9 | Hero + Facility 기본 |
| 5 | Task 10 | WaveManager |
| 6 | Task 11-13 | UI (LevelUp, Intermission, HUD) |
| 7 | Task 14 | Game 씬 통합 → **첫 플레이 가능** |
| 8 | Task 15-17 | Menu + Meta UI |
| 9 | Task 18-20 | 추가 콘텐츠 (영웅/시설/적) |
| 10 | Task 21-22 | 리소스 + 통합 테스트 |
