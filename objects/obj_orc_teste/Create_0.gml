// --- Status Básicos ---
hp = 50;
max_hp = 50;
spd = 1.2;
xp_value = 10;

// --- Carrega Dados do Banco ---
var _db_sombra = global.attack_database.sombra;

// Carrega os ataques corretamente
basic_atk = _db_sombra.basics[0];   // Orbe Sombrio
special_atk = _db_sombra.specials[0]; // Vazio (ou outro especial)

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