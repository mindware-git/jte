class_name DialogueData
extends RefCounted

# ═══════════════════════════════════════════════════════════════════════════════
# DialogueData
# 대화 데이터 구조
# ═══════════════════════════════════════════════════════════════════════════════

## 대화 ID
var id: String = ""

## 대사 번역 키
var text_key: String = ""

## 선택지 목록
var choices: Array[DialogueChoice] = []


# ═══════════════════════════════════════════════════════════════════════════════
# DialogueChoice (선택지)
# ═══════════════════════════════════════════════════════════════════════════════

## 선택지 데이터
class DialogueChoice:
	var text_key: String = ""
	var next_dialogue_id: String = ""
	var actions: Array[DialogueAction] = []
	
	
	static func create(
		p_text_key: String,
		p_next_dialogue_id: String = "",
		p_actions: Array[DialogueAction] = []
	) -> DialogueChoice:
		var choice := DialogueChoice.new()
		choice.text_key = p_text_key
		choice.next_dialogue_id = p_next_dialogue_id
		choice.actions = p_actions
		return choice


# ═══════════════════════════════════════════════════════════════════════════════
# DialogueAction (대화 액션)
# ═══════════════════════════════════════════════════════════════════════════════

## 대화 액션 타입
enum ActionType {
	GIVE_ITEM,   # 아이템 지급
	SET_FLAG,    # 플래그 설정
	START_BATTLE, # 전투 시작
	HEAL,        # 회복
	END_DIALOGUE # 대화 종료
}

## 대화 액션
class DialogueAction:
	var action_type: DialogueData.ActionType
	var target_id: String = ""
	var value: Variant = null
	
	
	static func give_item(item_id: String, count: int = 1) -> DialogueAction:
		var action := DialogueAction.new()
		action.action_type = ActionType.GIVE_ITEM
		action.target_id = item_id
		action.value = count
		return action
	
	
	static func set_flag(flag_name: String, flag_value: Variant = true) -> DialogueAction:
		var action := DialogueAction.new()
		action.action_type = ActionType.SET_FLAG
		action.target_id = flag_name
		action.value = flag_value
		return action
	
	
	static func start_battle(enemy_id: String) -> DialogueAction:
		var action := DialogueAction.new()
		action.action_type = ActionType.START_BATTLE
		action.target_id = enemy_id
		return action
	
	
	static func heal(amount: int) -> DialogueAction:
		var action := DialogueAction.new()
		action.action_type = ActionType.HEAL
		action.value = amount
		return action
	
	
	static func end_dialogue() -> DialogueAction:
		var action := DialogueAction.new()
		action.action_type = ActionType.END_DIALOGUE
		return action


# ═══════════════════════════════════════════════════════════════════════════════
# Factory
# ═══════════════════════════════════════════════════════════════════════════════

static func create(p_id: String, p_text_key: String, p_choices: Array[DialogueChoice] = []) -> DialogueData:
	var dialogue := DialogueData.new()
	dialogue.id = p_id
	dialogue.text_key = p_text_key
	dialogue.choices = p_choices
	return dialogue


static func simple(p_id: String, p_text_key: String) -> DialogueData:
	return create(p_id, p_text_key, [
		DialogueChoice.create("CHOICE_GOODBYE", "", [DialogueAction.end_dialogue()])
	])


static func with_choices(p_id: String, p_text_key: String, p_choices: Array[DialogueChoice]) -> DialogueData:
	return create(p_id, p_text_key, p_choices)