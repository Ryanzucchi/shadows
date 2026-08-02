/// @description Lógica da Estante de Tubos (Box Storage)

depth = -bbox_bottom;

var _player = instance_nearest(x, y, obj_jogador);
if (_player != noone) {
    var _dist = point_distance(x, y, _player.x, _player.y);
    player_nearby = (_dist < 60);
} else {
    player_nearby = false;
}

// Tecla de Interação (Botão B no Controle ou E/Espaço no Teclado)
var _key_interact = keyboard_check_pressed(ord("E")) || keyboard_check_pressed(vk_space);
if (gamepad_is_connected(0) && gamepad_button_check_pressed(0, gp_face2)) {
    _key_interact = true;
}

if (player_nearby && _key_interact && !is_open) {
    is_open = true;
    current_side = 0;
    selected_party_idx = 0;
    selected_box_idx = 0;
} else if (is_open && (_key_interact || keyboard_check_pressed(vk_escape))) {
    // Tecla de fechar se já estiver aberto
    is_open = false;
}

if (!is_open) exit;

// --- NAVEGAÇÃO NA ESTANTE BOX ---
var _up = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));
var _down = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"));
var _left = keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"));
var _right = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"));
var _action = keyboard_check_pressed(vk_enter) || mouse_check_button_pressed(mb_left);

if (gamepad_is_connected(0)) {
    if (gamepad_button_check_pressed(0, gp_padu)) _up = true;
    if (gamepad_button_check_pressed(0, gp_padd)) _down = true;
    if (gamepad_button_check_pressed(0, gp_padl)) _left = true;
    if (gamepad_button_check_pressed(0, gp_padr)) _right = true;
    if (gamepad_button_check_pressed(0, gp_face1)) _action = true; // Botão A
}

// Trocar de Lado (0 = Equipe, 1 = Estante Box)
if (_left) current_side = 0;
if (_right) current_side = 1;

var _party_len = array_length(global.party);
var _box_len = array_length(global.box);

// Navegação Vertical
if (current_side == 0 && _party_len > 0) {
    if (_up) selected_party_idx--;
    if (_down) selected_party_idx++;
    selected_party_idx = clamp(selected_party_idx, 0, _party_len - 1);
} else if (current_side == 1 && _box_len > 0) {
    if (_up) selected_box_idx--;
    if (_down) selected_box_idx++;
    selected_box_idx = clamp(selected_box_idx, 0, _box_len - 1);
}

// --- TRANSFERÊNCIA DE TUBOS DE ENSAIO ---
if (_action) {
    if (current_side == 0 && _party_len > 0) {
        // Mover da EQUIPE para a ESTANTE BOX
        selected_party_idx = clamp(selected_party_idx, 0, _party_len - 1);
        var _mon = global.party[selected_party_idx];
        
        // Se estiver invocado, desinvoca primeiro
        if (variable_struct_exists(_mon, "is_summoned") && _mon.is_summoned) {
            if (instance_exists(_mon.summon_id)) instance_destroy(_mon.summon_id);
            _mon.is_summoned = false;
            _mon.summon_id = noone;
        }
        
        array_push(global.box, _mon);
        array_delete(global.party, selected_party_idx, 1);
        show_debug_message("Guardou tubo na estante: " + _mon.name);
        
        if (array_length(global.party) == 0) selected_party_idx = 0;
        else selected_party_idx = min(selected_party_idx, array_length(global.party) - 1);
        
    } else if (current_side == 1 && _box_len > 0) {
        // Mover da ESTANTE BOX para a EQUIPE
        selected_box_idx = clamp(selected_box_idx, 0, _box_len - 1);
        var _mon = global.box[selected_box_idx];
        
        // Adiciona na party
        array_push(global.party, _mon);
        array_delete(global.box, selected_box_idx, 1);
        show_debug_message("Retirou tubo da estante para a equipe: " + _mon.name);
        
        if (array_length(global.box) == 0) selected_box_idx = 0;
        else selected_box_idx = min(selected_box_idx, array_length(global.box) - 1);
    }
}
