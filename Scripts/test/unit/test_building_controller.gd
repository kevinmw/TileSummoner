# Scripts/test/unit/test_building_controller.gd
class_name TestBuildingController
extends GdUnitTestSuite

## 测试建筑控制器


var _controller: BuildingController
var _base: Building
var _base_data: BuildingData
var _tower1: Building
var _tower2: Building
var _tower_data: BuildingData


func before_test() -> void:
	# 创建基地数据
	_base_data = BuildingData.new()
	_base_data.building_type = UnitEnums.BuildingType.BASE
	_base_data.shield_enabled = true
	_base_data.shield_requires_towers = 1
	_base_data.max_health = 1000

	# 创建塔数据
	_tower_data = BuildingData.new()
	_tower_data.building_type = UnitEnums.BuildingType.TOWER
	_tower_data.shield_enabled = false
	_tower_data.max_health = 500

	# 创建基地
	_base = auto_free(Building.new())
	_base.data = _base_data
	_base.max_health = 1000
	_base.current_health = 1000
	_base.shield_active = true

	# 创建塔1
	_tower1 = auto_free(Building.new())
	_tower1.data = _tower_data
	_tower1.max_health = 500
	_tower1.current_health = 500

	# 创建塔2
	_tower2 = auto_free(Building.new())
	_tower2.data = _tower_data
	_tower2.max_health = 500
	_tower2.current_health = 500

	# 创建控制器
	_controller = auto_free(BuildingController.new())


func after_test() -> void:
	_base_data.free()
	_tower_data.free()


## 测试1：控制器可以设置基地
func test_can_set_base() -> void:
	_controller.set_base(_base)
	assert_that(_controller.base).is_equal(_base)


## 测试2：控制器可以注册友方塔
func test_can_register_towers() -> void:
	_controller.set_base(_base)
	_controller.register_tower(_tower1)
	_controller.register_tower(_tower2)

	assert_that(_controller.friendly_towers.size()).is_equal(2)


## 测试3：塔死亡后从列表移除
func test_tower_removed_on_death() -> void:
	_controller.set_base(_base)
	_controller.register_tower(_tower1)
	_controller.register_tower(_tower2)

	# 模拟塔死亡
	_tower1.is_dead = true
	_tower1.died.emit(null)

	assert_that(_controller.get_alive_tower_count()).is_equal(1)


## 测试4：存活塔数小于要求时护盾消失
func test_shield_breaks_when_towers_destroyed() -> void:
	_controller.set_base(_base)
	_controller.register_tower(_tower1)

	# 确认初始状态护盾激活
	assert_that(_base.shield_active).is_true()

	# 塔死亡
	_tower1.is_dead = true
	_tower1.died.emit(null)

	# 护盾应该消失
	assert_that(_base.shield_active).is_false()


## 测试5：护盾消失时发出信号
func test_shield_broken_signal_emitted() -> void:
	_controller.set_base(_base)
	_controller.register_tower(_tower1)

	var signal_emitted := false
	_controller.shield_broken.connect(func(): signal_emitted = true)

	# 塔死亡
	_tower1.is_dead = true
	_tower1.died.emit(null)

	assert_that(signal_emitted).is_true()


## 测试6：多塔存活时护盾保持
func test_shield_remains_with_multiple_towers() -> void:
	_base_data.shield_requires_towers = 1  # 只需要1塔存活
	_controller.set_base(_base)
	_controller.register_tower(_tower1)
	_controller.register_tower(_tower2)

	# 一塔死亡
	_tower1.is_dead = true
	_tower1.died.emit(null)

	# 还有一塔存活，护盾应该保持
	assert_that(_base.shield_active).is_true()


## 测试7：所有塔死亡后护盾消失
func test_shield_breaks_when_all_towers_dead() -> void:
	_base_data.shield_requires_towers = 1
	_controller.set_base(_base)
	_controller.register_tower(_tower1)
	_controller.register_tower(_tower2)

	# 两塔都死亡
	_tower1.is_dead = true
	_tower1.died.emit(null)
	_tower2.is_dead = true
	_tower2.died.emit(null)

	assert_that(_base.shield_active).is_false()


## 测试8：is_shield_active 返回正确状态
func test_is_shield_active() -> void:
	_controller.set_base(_base)
	assert_that(_controller.is_shield_active()).is_true()

	_base.shield_active = false
	assert_that(_controller.is_shield_active()).is_false()
