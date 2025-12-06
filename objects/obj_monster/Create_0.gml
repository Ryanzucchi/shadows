// --- Inicialização Básica ---
hp = 100;
max_hp = 100;
spd = 1.0;
type_1 = "fogo"; // Tipo padrão (pode ser alterado no editor ou creation code da room)
type_2 = "nenhum";

// --- Combate ---
state = MO_STATE.IDLE;
state_timer = 0;
aggro_range = 250;
attack_range_buffer = 0; // Ajustado dinamicamente pelo golpe

// Carrega ataques iniciais (será sobrescrito se usar Debug)
attack_cooldown = 0;
channel_timer = 0;
current_attack = undefined; // Struct do ataque atual
target_x = 0;
target_y = 0;

// Seleciona golpes padrão do banco
var _db = variable_struct_get(global.attack_database, type_1);
if (_db != undefined) {
    basic_atk = _db[0]; // Primeiro golpe da lista (básico)
    special_atk = _db[2]; // Terceiro golpe (especial)
} else {
    basic_atk = global.attack_database.normal[0];
    special_atk = global.attack_database.normal[2];
}

// --- DEBUG ---
debug_open = false;
debug_selected_type_idx = 0;
debug_selected_atk_idx = 0;
debug_types_list = ["grama", "agua", "fogo", "sombra", "inseto", "normal", "metal", "dragao", "luz", "terra"];
// Trava o monstro para teste
debug_freeze = false;