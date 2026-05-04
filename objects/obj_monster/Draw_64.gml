// Ativa/Desativa com F1
if (keyboard_check_pressed(vk_f1)) debug_open = !debug_open;

if (debug_open) {
    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();
    
    var _mx = _gui_w / 2 - 200;
    var _my = _gui_h / 2 - 250;
    
    // Fundo
    draw_set_alpha(0.85);
    draw_set_color(c_black);
    draw_roundrect(_mx, _my, _mx + 400, _my + 500, false);
    draw_set_alpha(1);
    
    // Borda
    draw_set_color(c_aqua);
    draw_roundrect(_mx, _my, _mx + 400, _my + 500, true);
    
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_text(_mx + 200, _my + 15, "--- LABORATÓRIO DE TESTES ---");
    
    draw_set_halign(fa_left);
    draw_set_color(c_silver);
    draw_text(_mx + 20, _my + 35, "Setas Cima/Baixo : Escolher Monstro Base");
    draw_text(_mx + 20, _my + 50, "ENTER            : Aplicar Monstro Atual");
    draw_text(_mx + 20, _my + 65, "HOME / END       : Trocar Atk BÁSICO");
    draw_text(_mx + 20, _my + 80, "PgUP / PgDOWN    : Trocar Atk ESPECIAL");
    draw_text(_mx + 20, _my + 95, "F                : Congelar / Descongelar IA");
    
    // Inicializa lista plana de ataques se não existir
    if (!variable_instance_exists(id, "debug_all_attacks")) {
        debug_all_attacks = [];
        var _elements = variable_struct_get_names(global.attack_database);
        for (var e = 0; e < array_length(_elements); e++) {
            var _cat = variable_struct_get(global.attack_database, _elements[e]);
            for (var b = 0; b < array_length(_cat.basics); b++) array_push(debug_all_attacks, _cat.basics[b]);
            for (var s = 0; s < array_length(_cat.specials); s++) array_push(debug_all_attacks, _cat.specials[s]);
        }
        debug_atk_b_idx = 0;
        debug_atk_s_idx = 0;
    }
    
    // Controles de Congelamento
    if (keyboard_check_pressed(ord("F"))) debug_freeze = !debug_freeze;
    
    // Controles de Ataques do Monstro VIVO (Muda Imediatamente)
    var _total_atks = array_length(debug_all_attacks);
    if (keyboard_check_pressed(vk_home)) { debug_atk_b_idx--; if (debug_atk_b_idx < 0) debug_atk_b_idx = _total_atks-1; basic_atk = debug_all_attacks[debug_atk_b_idx]; }
    if (keyboard_check_pressed(vk_end)) { debug_atk_b_idx++; if (debug_atk_b_idx >= _total_atks) debug_atk_b_idx = 0; basic_atk = debug_all_attacks[debug_atk_b_idx]; }
    
    if (keyboard_check_pressed(vk_pageup)) { debug_atk_s_idx--; if (debug_atk_s_idx < 0) debug_atk_s_idx = _total_atks-1; special_atk = debug_all_attacks[debug_atk_s_idx]; }
    if (keyboard_check_pressed(vk_pagedown)) { debug_atk_s_idx++; if (debug_atk_s_idx >= _total_atks) debug_atk_s_idx = 0; special_atk = debug_all_attacks[debug_atk_s_idx]; }

    
    // Obtém as chaves do banco de dados para listar
    var _keys = variable_struct_get_names(global.monster_db);
    var _total_monsters = array_length(_keys);
    
    if (keyboard_check_pressed(vk_down)) debug_selected_type_idx++;
    if (keyboard_check_pressed(vk_up)) debug_selected_type_idx--;
    
    // Wrap Monstros
    if (debug_selected_type_idx < 0) debug_selected_type_idx = _total_monsters - 1;
    if (debug_selected_type_idx >= _total_monsters) debug_selected_type_idx = 0;
    
    // Lista de Monstros
    var _list_y = _my + 130;
    draw_set_color(c_aqua);
    draw_text(_mx + 20, _list_y - 20, "MONSTROS DISPONÍVEIS:");
    
    for (var i = 0; i < _total_monsters; i++) {
        var _k = _keys[i];
        var _m_data = variable_struct_get(global.monster_db, _k);
        
        if (i == debug_selected_type_idx) {
            draw_set_color(c_yellow);
            draw_text(_mx + 20, _list_y + (i * 20), ">> " + _m_data.name + " (" + _m_data.element + ")");
        } else {
            draw_set_color(c_white);
            draw_text(_mx + 40, _list_y + (i * 20), _m_data.name);
        }
    }
    
    // Preview do Monstro Selecionado
    var _sel_key = _keys[debug_selected_type_idx];
    var _sel_data = variable_struct_get(global.monster_db, _sel_key);
    
    var _preview_y = _my + 300;
    draw_set_color(c_lime);
    draw_text(_mx + 20, _preview_y, "PREVIEW DOS STATUS:");
    draw_set_color(c_white);
    draw_text(_mx + 20, _preview_y + 20, "Elemento : " + string_upper(_sel_data.element));
    draw_text(_mx + 20, _preview_y + 40, "HP Max   : " + string(_sel_data.max_hp));
    draw_text(_mx + 20, _preview_y + 60, "Velocid. : " + string(_sel_data.spd));
    draw_text(_mx + 20, _preview_y + 80, "Atk Básico: " + _sel_data.basic_atk.name);
    draw_text(_mx + 20, _preview_y + 100,"Atk Espec.: " + _sel_data.special_atk.name);
    
    // Aplicação
    if (keyboard_check_pressed(vk_enter)) {
        // Aplica o monstro no objeto atual
        monster_data = variable_clone(_sel_data);
        
        hp = monster_data.hp;
        max_hp = monster_data.max_hp;
        spd = monster_data.spd;
        type_1 = monster_data.element; 
        
        basic_atk = monster_data.basic_atk;
        special_atk = monster_data.special_atk;
        
        attack_cooldown = 0;
        channel_timer = 0;
        state = MO_STATE.IDLE;
        
        show_debug_message("Monstro atualizado para: " + monster_data.name);
    }
    
    // Status do Monstro Vivo
    draw_set_color(c_orange);
    draw_text(_mx + 20, _my + 420, "--- MONSTRO ATUAL DA TELA ---");
    draw_set_color(c_white);
    if (variable_instance_exists(id, "monster_data") && monster_data != undefined) {
        draw_text(_mx + 20, _my + 440, "Nome: " + monster_data.name + " | HP: " + string(ceil(hp)) + "/" + string(max_hp));
        draw_set_color(c_yellow);
        draw_text(_mx + 20, _my + 460, "Atk Base: " + basic_atk.name);
        draw_text(_mx + 20, _my + 480, "Atk Esp: " + special_atk.name);
    }
}