# Dongyugi (東遊記) - Characters & Items Data

## 1. Characters Overview
The journey begins with Sanzang and Wukong in China, gathering past allies, and expanding into Korea and Japan. Here are the 10 core characters, utilizing the classic stat terminology from *Fantasy Journey to the West*.

### Core Stats Terminology (Legacy System)
*   **HP (Health Points)**: Character's vitality.
*   **SG (Skill Gauge)**: Replaces standard MP; energy consumed to use skills.
*   **POW (Power)**: Determines physical attack damage.
*   **INT (Intelligence)**: Determines magical attack damage and healing output.
*   **DEF (Defense)**: Resistance against physical and magical attacks.
*   **SPD (Speed)**: Determines turn order, evasion, and accuracy.
*   **LUK (Luck)**: Affects critical hit rates and random combat factors.

---

### China Team: The Reunited Legends

#### 1. Sanzang (삼장법사)
*   **Role**: Healer / Pure Support
*   **Stats Focus**: High SG, High INT, Low POW
*   **Description**: The wise monk who initiates the journey to East to stop the unsealing of Mount Penglai.
*   **Skills** (Original IDs 10–19, remapped from 환상서유기 삼장 line):

| # | Skill ID | Display Name (KR) | Display Name (EN) | Type | Cost | Unlock Lv | Description |
|---|---|---|---|---|---|---|---|
| 1 | `gentle_heal` | 청심진언 | Gentle Heal | Heal (Single) | 5 MP | 1 | Restores a small amount of HP to one ally. Base heal: 60. |
| 2 | `purify` | 정기정심 | Purify | Cleanse (Single) | 7 MP | 5 | Removes all debuffs and status ailments from one ally. Base heal: 110. |
| 3 | `holy_water` | 홀리워터 | Holy Water | Attack (AoE) | 10 MP | 8 | Splashes blessed water dealing INT-based damage to all enemies. Effective vs undead. Base: 35. |
| 4 | `life_drain` | 생기흡수 | Life Drain | Attack+Heal (Single) | 20 MP | 12 | Drains enemy vitality, dealing INT damage and recovering HP. Base: 110. |
| 5 | `greater_heal` | 대비진언 | Greater Heal | Heal (Single) | 20 MP | 15 | Restores a large amount of HP to one ally. Base heal: 220. |
| 6 | `restore` | 봉래회복 | Restore | Cleanse (Single) | 20 MP | 18 | Fully cures all ailments and restores moderate HP. Base heal: 100. |
| 7 | `silence` | 봉인진언 | Silence | Debuff (Single) | 10 MP | 10 | Seals the target's skills for 2 turns. Base: 100. |
| 8 | `divine_heal` | 대자대비 | Divine Heal | Heal (All) | 50 MP | 25 | Restores massive HP to all allies. Base heal: 2100. |
| 9 | `full_restore` | 혼정리 | Full Restore | Cleanse (All) | 40 MP | 30 | Fully purifies the entire party, removing all ailments and restoring HP. Base heal: 2100. |
| 10 | `summon_spirit` | 영등부르기 | Summon Spirit | Summon | 0 MP | 20 | Summons a guardian spirit to assist in battle. Base: 40. |

#### 2. Wukong (손오공)
*   **Role**: Melee DPS / Bruiser
*   **Stats Focus**: Very High POW, High SPD, Medium HP
*   **Description**: The Monkey King, freshly unsealed by Sanzang. Rebellious but bound by a common goal.
*   **Skills** (Original IDs 0–9, remapped from 환상서유기 손오공 line):

| # | Skill ID | Display Name (KR) | Display Name (EN) | Type | Cost | Unlock Lv | Description |
|---|---|---|---|---|---|---|---|
| 1 | `stone_monkey_strike` | 돌원숭이치기 | Stone Monkey Strike | Attack (Single) | 5 MP | 1 | A quick overhead smash. POW-based. Base: 22. |
| 2 | `azure_dragon_blow` | 청룡봉격 | Azure Dragon Blow | Attack (Single) | 8 MP | 5 | Channels the Azure Dragon's fury into a powerful staff strike. Base: 33. |
| 3 | `white_tiger_flip` | 백호뒤집기 | White Tiger Flip | Attack (Single) | 12 MP | 8 | A spinning vault kick inspired by the White Tiger. Base: 55. |
| 4 | `phantom_grin` | 잔원숭이웃음 | Phantom Grin | Debuff (All) | 15 MP | 10 | A mocking grin that unnerves all enemies, lowering their accuracy. Base: 100. |
| 5 | `mirror_image` | 원숭이분신 | Mirror Image | Buff (Self) | 20 MP | 12 | Creates illusory clones, dramatically boosting evasion. Base: 160. |
| 6 | `vermillion_rampage` | 주작난봉 | Vermillion Rampage | Attack (AoE) | 26 MP | 16 | Blazing staff strikes infused with the Vermillion Bird's fire. Base: 280. |
| 7 | `black_tortoise_crush` | 현무거치 | Black Tortoise Crush | Attack (AoE) | 35 MP | 20 | A devastating ground slam channeling the Black Tortoise's weight. Base: 430. |
| 8 | `moonlight_barrage` | 월광난타 | Moonlight Barrage | Attack (AoE) | 46 MP | 25 | A furious multi-hit combo under pale moonlight. Base: 660. |
| 9 | `ruyi_rampage` | 여의난무 | Ruyi Rampage | Attack (All) | 62 MP | 30 | Extends the Ruyi Jingu Bang to its full size and rampages across the battlefield. Base: 960. |
| 10 | `golden_afterimage` | 금강잔영 | Golden Afterimage | Heal+Attack (All) | 80 MP | 35 | The ultimate technique — a golden blur that heals all allies and obliterates all enemies. Base: 2000. |

#### 3. Bajie (저팔계)
*   **Role**: Tank / Vanguard
*   **Stats Focus**: Very High HP, Very High DEF, Low SPD
*   **Description**: A resilient half-man, half-pig warrior. Takes the frontline to absorb heavy hits.
*   **Skills**:
    *   `gourd_smash` (박깨기): Smashes a gourd over the enemy's head. Single target physical. SG: 2.
    *   `roast_chestnut_breath` (군밤숨): Breathes warm air to restore HP to one ally. SG: 5.
    *   `triple_belly_charge` (삼겹들이받기): Three consecutive body-slam charges. Single target. SG: 8.
    *   `gale_charge` (들이풍수): A reckless full-body rush that hits an AoE column. SG: 12.
    *   `gluttony_frenzy` (폭식광란): Enters a feeding frenzy, dealing massive AoE damage. SG: 16.

#### 4. Wujing (사오정)
*   **Role**: Defensive Mage / Zone Controller
*   **Stats Focus**: Medium HP, High SG, High INT
*   **Description**: The stoic river dweller who uses water magic to disrupt enemy formations.
*   **Skills**:
    *   `splash_strike` (물탄들이치기): Hurls a pressurized water blast at one ally's enemies. SG: 2.
    *   `claw_slash` (물갈퀴치기): A powerful claw swipe dealing physical damage. SG: 5.
    *   `four_winds_claw` (사방물갈퀴): Slashes in all directions, hitting surrounding enemies. SG: 8.
    *   `wild_torrent_claw` (난수갈퀴): An unpredictable flurry of water-clad claw attacks. AoE. SG: 12.
    *   `dragon_tide_slash` (용물살가르기): Channels the dragon tide into a massive AoE slash. SG: 16.
    *   `iron_wall` (물막세우기): Erects a water barrier, boosting party DEF. SG: 6.
    *   `counter_wave` (되물살치기): Returns incoming damage as a tidal counter. SG: 16.

---

### Korea Team: The Guardians of the Seal

#### 5. Yeoul (여울 - Gumiho)
*   **Role**: Magic Hit-and-Run / Assassin
*   **Stats Focus**: High INT, Very High SPD, Low DEF
*   **Description**: A nine-tailed fox who guards the ancient seals of the Korean peninsula.
*   **Skills**:
    *   `fox_fire` (유성여우불): Shoots a barrage of tracking blue flames at a single target.
    *   `nine_tail_blaze` (구미화주): Wraps all nine tails in flame for a devastating area attack.
    *   `soul_snare` (혼빼기): Siphons the target's willpower, dealing INT damage and inflicting Confusion.
    *   `fox_rain` (여우비): Summons spectral rain that damages all enemies with INT-based water/fire hybrid.
    *   `spirit_theft` (생기훔치기): Drains the target's life force, healing herself proportionally.
    *   `tail_veil` (꼬리장막): Fans her tails into a shimmering veil, boosting party evasion.
    *   `nine_tail_dance` (구미난무): A frenzied whirlwind of tails dealing massive AoE damage.
    *   `fox_pyre` (구미염환): Engulfs the battlefield in phantom foxfire. Ultimate AoE.
    *   `fox_ascension` (여우승천): Ascends to her true celestial form, unleashing supreme magic damage on all enemies.

#### 6. Ddukddaki (뚝딱이 - Dokkaebi)
*   **Role**: Trickster / Utility Support
*   **Stats Focus**: Medium All-Around, Very High LUK
*   **Description**: A mischievous goblin equipped with a magical mallet. Highly unpredictable.
*   **Skills**:
    *   `thunderous_mallet` (방망이 굉음): A deafening slam that silences all enemies.
    *   `goblin_jig` (도깨비 굿거리): A lively dance that restores HP to all allies.
    *   `lucky_beat` (잔재주 장단): A rhythmic drumbeat that boosts the party's LUK.
    *   `war_drum` (한판 장구): A powerful drum performance that boosts party POW.
    *   `solo_riff` (혼자 북치기): An improvised solo that buffs a single ally's all stats.
    *   `wild_festival` (난장 굿판): A chaotic ritual that buffs party SPD.
    *   `revival_waltz` (살림굿): A ceremonial dance that revives and heals fallen allies.
    *   `spirit_lift` (흥 돋우기): An uplifting performance that restores HP to all allies.
    *   `tall_tale` (허풍 한마당): An outrageous boast that massively buffs a single ally.
    *   `grand_banquet` (도깨비 대잔치): The ultimate celebration — heals the full party and grants all buffs.

#### 7. Haechi (해치 - Haetae)
*   **Role**: Holy Tank / Paladin
*   **Stats Focus**: Very High HP, High DEF, High INT
*   **Description**: A legendary beast of justice. An unbreakable wall against evil forces.
*   **Skills**:
    *   `sacred_meteor` (법화유성): Calls down a meteor of holy flame on a single target.
    *   `crimson_pillar` (적화천주): A pillar of righteous fire that damages all enemies in a line.
    *   `sin_burner` (죄업태우기): Burns away the target's sins, dealing INT damage and dispelling buffs.
    *   `judgment_rain` (심판비화): A rain of sacred fire that damages all enemies.
    *   `evil_purge` (악기빼앗기): Strips enemy buffs and converts them to damage.
    *   `haetae_fury` (해태분기): Enters a state of divine rage, boosting own POW and INT.
    *   `divine_manifestation` (해치현신): Manifests true divine form for devastating AoE holy damage.
    *   `crimson_inferno` (적화염도): Engulfs the entire field in crimson flames. Ultimate attack.
    *   `holy_ascension` (화해승천): Ascends in blazing glory, dealing maximum holy damage to all enemies.

---

### Japan Team: The Infiltrators of Secrets

#### 8. Tenmaru (텐마루 - Tengu)
*   **Role**: Aerial Fighter / Ranged DPS
*   **Stats Focus**: High POW, High SPD, Low HP
*   **Description**: A proud winged warrior wielding the power of the wind. Specializes in long-range physical strikes.
*   **Skills**:
    *   `soaring_slash` (비상참): A leaping aerial slash that strikes from above. Single target.
    *   `gale_wave` (적풍파): Sends a crescent-shaped wind blade across the field. Line attack.
    *   `blazing_wing_slash` (화조참): A fiery slashing dive attack. Line AoE.
    *   `sky_fury_dance` (천구난무): A wild aerial dance of blade strikes. AoE.
    *   `heavenly_storm_blade` (천마루난도): The ultimate wind technique — an endless storm of slashes. AoE.

#### 9. Kawataro (카와타로 - Kappa)
*   **Role**: Explorer / Water Mage
*   **Stats Focus**: High SG, Medium INT, High DEF
*   **Description**: An amphibious Yokai with deep knowledge of water routes and hidden channels.
*   **Skills**:
    *   `dish_squirt` (접시물총): Fires a compressed water disk from his head-plate. Single target.
    *   `reed_lance` (물갈대창): Hurls a hardened water-reed spear. AoE line.
    *   `triple_torrent` (삼연물침): Fires three rapid water needles in succession. Single target.
    *   `rapids_spike` (급류침): Summons a violent rapids surge to impale enemies. AoE.
    *   `channel_barrage` (수로난사): Opens all water channels for an indiscriminate deluge. AoE.

#### 10. Kagemaru (카게마루 - Ninja)
*   **Role**: Sneak / Burst Assassin
*   **Stats Focus**: Very High POW, Very High SPD, Low DEF
*   **Description**: A mysterious shadow warrior who aids the party for his own hidden motives.
*   **Skills**:
    *   `smoke_kunai` (연막쿠나이): Throws a smoke-coated kunai. Single target with Blind.
    *   `shadow_trap` (그림자덫): Plants an invisible ground trap that damages and roots the first enemy to trigger it.
    *   `blast_tag` (폭부): Attaches an explosive talisman to the target. Delayed AoE detonation.
    *   `piercing_shuriken` (꿰뚫는 수리검): A charged throw that pierces through all enemies in a line.
    *   `fox_smoke_blaze` (여우연막화): Ignites a smokescreen that deals fire damage over time to all enemies in the area.

---

## 2. Items Overview

Items are divided into three main categories: Consumables, Equipment, and Key Items.

### Consumables (소모품)
*   **Calming Pill** (청심환): A basic medicinal pill. Restores a small amount of HP.
*   **Harbor Remedy** (해롱약): A mid-grade herbal remedy purchased at ports. Restores moderate HP.
*   **Serenity Pill** (태평환): A premium medicinal pill. Restores a large amount of HP.
*   **Wild Pine Leaf** (들솔잎): A common forest herb. Provides minor healing.
*   **Frost Leaf** (서릿잎): A mountain herb with cooling properties. Restores moderate HP.
*   **Immortal Leaf** (신선잎): A rare divine herb. Fully restores HP.
*   **Heavenly Peach** (달복숭아): A legendary fruit from the celestial gardens. Fully heals HP.
*   **Purification Powder** (정화분): Sacred powder that dispels curses and illusions.
*   **Wake-Up Needle** (깸침): A sharp acupuncture needle that instantly cures Sleep and Daze.
*   **Antidote** (해독환): A medicinal pellet that cures Poison.
*   **Tiger Bell** (호랑방울): A jingling bell that jolts allies awake. Cures Sleep.
*   **Sobering Charm** (혼깨비술): A folk remedy that breaks Confusion and Charm effects.
*   **Muscle Salve** (삭신풀기기름): A fragrant oil that loosens stiff joints. Cures Paralysis.
*   **Vigor Tonic** (혈기단): A fiery elixir that temporarily heightens alertness and aggression.

### Equipment (장비)
*   **Sanzang's Ringed Staff** (석장; Weapon): A sacred, ringed brass staff. Enhances INT and drastically improves healing output.
*   **Golden Headband** (긴고아; Accessory): The legendary control circlet. Increases max SG and offers resistance to `Charm` and `Confusion`.
*   **Tiger Pelt Vest** (호피갑; Armor): Light, flexible armor crafted from mystical tiger hide. Increases DEF and SPD.
*   **Dragon Scale Mail** (용린갑; Armor): Extremely heavy armor crafted from deep-sea dragon scales. Significantly increases DEF but slightly lowers SPD.
*   **Midnight Shuriken** (야차수리검; Weapon): Specially crafted ninja stars forged at midnight. Dramatically increases LUK and critical hit rate.

### Key Items (주요 스토리 아이템)
*   **Sealing Talisman** (봉인부): Ancient talismans used to interact with sealed shrines and unlock magical pathways. Primarily used by the Korea Team.
*   **Yin-Yang Mirror** (음양경): A mystical mirror that reveals hidden paths, invisible traps, or the true forms of disguised Yokai. Mostly utilized by the Japan Team.
*   **Map of the East** (동방도): A continually magically expanding scroll that updates the topography of China, Korea, and Japan as the party explores.
*   **Fragment of Penglai** (봉래편): A mysterious, glowing crystal shard recovered from the broken seals. Resonates when close to the final destination.
