/// @description Lógica do NPC Vendedor e Loja Alquímica

depth = -bbox_bottom;

var _player = instance_nearest(x, y, obj_jogador);
if (_player != noone) {
    var _dist = point_distance(x, y, _player.x, _player.y);
    player_nearby = (_dist < 60);
} else {
    player_nearby = false;
}

// Interação (B no Controle ou E/Espaço no Teclado)
var _key_interact = keyboard_check_pressed(ord("E")) || keyboard_check_pressed(vk_space);
if (gamepad_is_connected(0) && gamepad_button_check_pressed(0, gp_face2)) {
    _key_interact = true;
}

if (player_nearby && _key_interact && !is_open) {
    is_open = true;
    selected_shop_idx = 0;
} else if (is_open && (_key_interact || keyboard_check_pressed(vk_escape))) {
    is_open = false;
}

if (!is_open) exit;

// --- NAVEGAÇÃO E COMPRA NA LOJA ---
var _up = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));
var _down = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"));
var _buy = keyboard_check_pressed(vk_enter) || mouse_check_button_pressed(mb_left);

if (gamepad_is_connected(0)) {
    if (gamepad_button_check_pressed(0, gp_padu)) _up = true;
    if (gamepad_button_check_pressed(0, gp_padd)) _down = true;
    if (gamepad_button_check_pressed(0, gp_face1)) _buy = true; // Botão A
}

var _shop_len = array_length(shop_items);
if (_shop_len > 0) {
    if (_up) selected_shop_idx--;
    if (_down) selected_shop_idx++;
    selected_shop_idx = clamp(selected_shop_idx, 0, _shop_len - 1);
    
    // Processar Compra
    if (_buy) {
        var _slot = shop_items[selected_shop_idx];
        if (global.player_coins >= _slot.price) {
            global.player_coins -= _slot.price;
            
            // Adiciona ao inventário do jogador
            var _found = false;
            for (var i = 0; i < array_length(global.player_inventory); i++) {
                if (global.player_inventory[i].item.item_id == _slot.item.item_id) {
                    global.player_inventory[i].count++;
                    _found = true;
                    break;
                }
            }
            if (!_found) {
                array_push(global.player_inventory, { item: _slot.item, count: 1 });
            }
            
            show_debug_message("Comptou item: " + _slot.item.name);
        } else {
            show_debug_message("Moedas insuficientes!");
        }
    }
}
