# Scripts/test/unit/test_building_controller.gd
class_name TestBuildingController
extends GdUnitTestSuite

## 测试建筑控制器

## 创建基地 Building（不加入场景树，避免 _ready 崩溃）
func _create_base() -> Building:
	var base_data: BuildingData = BuildingData.new()
	base_data.building_type = UnitEnums.BuildingType.BASE
	base_data.shield_enabled = true
	base_data.shield_requires_towers = 1
	base_data.max_health = 1000

	var base: Building = Building.new()
	base.data = base_data
	base.max_health = 1000
	base.current_health = 1000
	base.shield_active = true
	return base


## 创建防御塔 Building
func _create_tower() -> Building:
	var tower_data: BuildingData = BuildingData.new()
	tower_data.building_type = UnitEnums.BuildingType.TOWER
	tower_data.shield_enabled = false
	tower_data.max_health = 500

	var tower: Building = Building.new()
	tower.data = tower_data
	tower.max_health = 500
	tower.current_health = 500
	return tower


## 测试1：控制器可以设置基地
func test_can_set_base() -> void:
	var controller: BuildingController = auto_free(BuildingController.new())
	var base: Building = _create_base()

	controller.set_base(base)
	assert_that(controller.base).is_equal(base)


## 测试2：控制器可以注册友方塔
func test_can_register_towers() -> void:
	var controller: BuildingController = auto_free(BuildingController.new())
	var base: Building = _create_base()
	var tower1: Building = _create_tower()
	var tower2: Building = _create_tower()

	controller.set_base(base)
	controller.register_tower(tower1)
	controller.register_tower(tower2)

	assert_that(controller.friendly_towers.size()).is_equal(2)


## 测试3：塔死亡后从列表移除
func test_tower_removed_on_death() -> void:
	var controller: BuildingController = auto_free(BuildingController.new())
	var base: Building = _create_base()
	var tower1: Building = _create_tower()
	var tower2: Building = _create_tower()

	controller.set_base(base)
	controller.register_tower(tower1)
	controller.register_tower(tower2)

	# 模拟塔死亡
	tower1.is_dead = true
	tower1.died.emit(null)

	assert_that(controller.get_alive_tower_count()).is_equal(1)


## 测试4：存活塔数小于要求时护盾消失
func test_shield_breaks_when_towers_destroyed() -> void:
	var controller: BuildingController = auto_free(BuildingController.new())
	var base: Building = _create_base()
	var tower1: Building = _create_tower()

	controller.set_base(base)
	controller.register_tower(tower1)

	# 确认初始状态护盾激活
	assert_that(base.shield_active).is_true()

	# 塔死亡
	tower1.is_dead = true
	tower1.died.emit(null)

	# 护盾应该消失
	assert_that(base.shield_active).is_false()


## 测试5：护盾消失时发出信号
func test_shield_broken_signal_emitted() -> void:
	var controller: BuildingController = auto_free(BuildingController.new())
	var base: Building = _create_base()
	var tower1: Building = _create_tower()

	controller.set_base(base)
	controller.register_tower(tower1)

	var signal_emitted: bool = false
	controller.shield_broken.connect(func(): signal_emitted = true)

	# 塔死亡
	tower1.is_dead = true
	tower1.died.emit(null)

	assert_that(signal_emitted).is_true()


## 测试6：多塔存活时护盾保持
func test_shield_remains_with_multiple_towers() -> void:
	var controller: BuildingController = auto_free(BuildingController.new())
	var base: Building = _create_base()
	var tower1: Building = _create_tower()
	var tower2: Building = _create_tower()

	(base.data as BuildingData).shield_requires_towers = 1  # 只需要1塔存活
	controller.set_base(base)
	controller.register_tower(tower1)
	controller.register_tower(tower2)

	# 一塔死亡
	tower1.is_dead = true
	tower1.died.emit(null)

	# 还有一塔存活，护盾应该保持
	assert_that(base.shield_active).is_true()


## 测试7：所有塔死亡后护盾消失
func test_shield_breaks_when_all_towers_dead() -> void:
	var controller: BuildingController = auto_free(BuildingController.new())
	var base: Building = _create_base()
	var tower1: Building = _create_tower()
	var tower2: Building = _create_tower()

	(base.data as BuildingData).shield_requires_towers = 1
	controller.set_base(base)
	controller.register_tower(tower1)
	controller.register_tower(tower2)

	# 两塔都死亡
	tower1.is_dead = true
	tower1.died.emit(null)
	tower2.is_dead = true
	tower2.died.emit(null)

	assert_that(base.shield_active).is_false()


## 测试8：is_shield_active 返回正确状态
func test_is_shield_active() -> void:
	var controller: BuildingController = auto_free(BuildingController.new())
	var base: Building = _create_base()

	controller.set_base(base)
	assert_that(controller.is_shield_active()).is_true()

	base.shield_active = false
	assert_that(controller.is_shield_active()).is_false()
