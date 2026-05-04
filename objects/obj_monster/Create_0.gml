// --- Inicialização Básica (Data-Driven) ---
// Em um jogo real, você definiria qual monstro ele é no Creation Code da Room
// Ex: monster_data = variable_clone(global.monster_db.slime_fogo);
// Como fallback, usaremos o slime_fogo se não for definido.
if (!variable_instance_exists(id, "monster_data")) {
    monster_data = variable_clone(global.monster_db.slime_fogo);
}

hp = monster_data.hp;
max_hp = monster_data.max_hp;
spd = monster_data.spd;
type_1 = monster_data.element; 
type_2 = "nenhum";

// --- Combate ---
state = MO_STATE.IDLE;
state_timer = 0;
aggro_range = 250;
attack_range_buffer = 0; // Ajustado dinamicamente pelo golpe

// Carrega ataques
attack_cooldown = 0;
channel_timer = 0;
current_attack = undefined; // Struct do ataque atual
target_x = 0;
target_y = 0;

basic_atk = monster_data.basic_atk;
special_atk = monster_data.special_atk;

// --- DEBUG ---
debug_open = false;
debug_selected_type_idx = 0;
debug_selected_atk_idx = 0;
debug_types_list = ["grama", "agua", "fogo", "sombra", "inseto", "normal", "metal", "dragao", "luz", "terra"];
// Trava o monstro para teste
debug_freeze = false;