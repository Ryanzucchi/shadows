/// @description Lógica do Inventário, Tomo & Tubos de Ensaio

var _key_toggle = keyboard_check_pressed(ord("I")) || keyboard_check_pressed(vk_tab);
if (gamepad_is_connected(0)) {
    if (gamepad_button_check_pressed(0, gp_start) || gamepad_button_check_pressed(0, gp_select)) {
        _key_toggle = true;
    }
}

if (_key_toggle) {
    is_open = !is_open;
    selected_index = 0;
    swap_source_index = -1;
}

if (!is_open) exit;

// --- NAVEGAÇÃO NO INVENTÁRIO (QUANDO ABERTO) ---
var _up = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));
var _down = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"));
var _left = keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"));
var _right = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"));
var _action = keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter) || mouse_check_button_pressed(mb_left);

if (gamepad_is_connected(0)) {
    if (gamepad_button_check_pressed(0, gp_padu)) _up = true;
    if (gamepad_button_check_pressed(0, gp_padd)) _down = true;
    if (gamepad_button_check_pressed(0, gp_padl) || gamepad_button_check_pressed(0, gp_shoulderl)) _left = true;
    if (gamepad_button_check_pressed(0, gp_padr) || gamepad_button_check_pressed(0, gp_shoulderr)) _right = true;
    if (gamepad_button_check_pressed(0, gp_face1)) _action = true; // Botão A
}

// Alternar Abas (Esquerda / Direita)
if (_left) {
    current_tab--;
    if (current_tab < 0) current_tab = 2;
    selected_index = 0;
    swap_source_index = -1;
}
if (_right) {
    current_tab++;
    if (current_tab > 2) current_tab = 0;
    selected_index = 0;
    swap_source_index = -1;
}

// Navegação Vertical pelos Itens da Aba
if (_up) selected_index--;
if (_down) selected_index++;

// Lógica por Aba
switch (current_tab) {
    case 0: // 🧪 TUBOS DE ENSAIO (PARTY)
        var _party_len = array_length(global.party);
        if (_party_len > 0) {
            selected_index = clamp(selected_index, 0, _party_len - 1);
            
            // Troca/Reordena Posição dos Tubos
            if (_action) {
                if (swap_source_index == -1) {
                    swap_source_index = selected_index;
                } else {
                    if (swap_source_index != selected_index) {
                        var _temp = global.party[swap_source_index];
                        global.party[swap_source_index] = global.party[selected_index];
                        global.party[selected_index] = _temp;
                        show_debug_message("Reordenou tubos da equipe!");
                    }
                    swap_source_index = -1;
                }
            }
        }
    break;

    case 1: // 📖 TOMO DE MAGIAS
        var _spell_keys = variable_struct_get_names(global.spell_database);
        var _spell_len = array_length(_spell_keys);
        if (_spell_len > 0) {
            selected_index = clamp(selected_index, 0, _spell_len - 1);
            
            // Equipar Magia no Mouse Left / RT
            if (_action) {
                var _key_name = _spell_keys[selected_index];
                global.equipped_spell = variable_struct_get(global.spell_database, _key_name);
                show_debug_message("Equipou magia no Tomo: " + global.equipped_spell.name);
            }
        }
    break;

    case 2: // 🎒 LISTA DE ITENS
        var _inv_len = array_length(global.player_inventory);
        if (_inv_len > 0) {
            selected_index = clamp(selected_index, 0, _inv_len - 1);
            
            // Usar Item Consumível
            if (_action) {
                var _slot = global.player_inventory[selected_index];
                if (_slot.count > 0 && _slot.item.type == "consumable") {
                    var _p = instance_find(obj_jogador, 0);
                    if (_p != noone) {
                        if (_slot.item.heal_hp > 0) _p.hp = min(_p.max_hp, _p.hp + _slot.item.heal_hp);
                        if (_slot.item.heal_mana > 0) _p.mana = min(_p.max_mana, _p.mana + _slot.item.heal_mana);
                    }
                    _slot.count--;
                    show_debug_message("Usou item: " + _slot.item.name);
                    if (_slot.count <= 0) {
                        array_delete(global.player_inventory, selected_index, 1);
                        selected_index = max(0, selected_index - 1);
                    }
                }
            }
        }
    break;
}
