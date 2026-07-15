// --- Inicializa com Dados (Data-Driven) ---
// Clona a base do banco de dados para que este orc seja único
monster_data = variable_clone(global.monster_db.orc_teste);

// Atalhos locais para compatibilidade e performance
hp = monster_data.hp;
max_hp = monster_data.max_hp;
spd = monster_data.spd;
xp_value = monster_data.base_xp;

basic_atk = monster_data.basic_atk;
special_atk = monster_data.special_atk;
type_1 = monster_data.element_1;
type_2 = monster_data.element_2;

// --- Timers e Controle ---
state = MO_STATE.IDLE; // <--- MUDANÇA: Usar MO_STATE, não "IDLE"
state_timer = 0;

attack_cooldown = 0;
special_cooldown = 180; // Começa com cooldown para não usar instantâneo
channel_timer = 0;

target_x = 0;
target_y = 0;
current_active_attack = undefined; 

aggro_range = 250;
show_debug_info = true;

// --- Variáveis de Debug (Obrigatórias) ---
debug_open = false;
debug_selected_type_idx = 3; // Sombra
debug_selected_atk_idx = 0;
debug_types_list = ["grama", "agua", "fogo", "sombra", "inseto", "normal", "metal", "dragao", "luz", "terra"];
debug_freeze = false;
type_1 = "sombra";