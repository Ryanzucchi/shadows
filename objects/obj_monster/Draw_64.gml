// Ativa/Desativa com F1
if (keyboard_check_pressed(vk_f1)) debug_open = !debug_open;

if (debug_open) {
    var _mx = 50;
    var _my = 50;
    
    // Fundo
    draw_set_alpha(0.8);
    draw_set_color(c_black);
    draw_rectangle(_mx, _my, _mx + 400, _my + 500, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    
    draw_text(_mx + 10, _my + 10, "--- MONSTER DEBUG (V2) ---");
    draw_text(_mx + 10, _my + 30, "Setas: Navegar | Enter: Trocar Especial | Espaço: Trocar Básico");
    draw_text(_mx + 10, _my + 50, "F: Congelar/Descongelar Monstro");
    
    // Controles
    if (keyboard_check_pressed(vk_down)) debug_selected_type_idx++;
    if (keyboard_check_pressed(vk_up)) debug_selected_type_idx--;
    if (keyboard_check_pressed(vk_right)) debug_selected_atk_idx++;
    if (keyboard_check_pressed(vk_left)) debug_selected_atk_idx--;
    if (keyboard_check_pressed(ord("F"))) debug_freeze = !debug_freeze;
    
    // Wrap (Ciclo infinito nas listas)
    var _total_types = array_length(debug_types_list);
    if (debug_selected_type_idx < 0) debug_selected_type_idx = _total_types - 1;
    if (debug_selected_type_idx >= _total_types) debug_selected_type_idx = 0;
    
    if (debug_selected_atk_idx < 0) debug_selected_atk_idx = 4; // Total de 5 ataques (0-4)
    if (debug_selected_atk_idx > 4) debug_selected_atk_idx = 0;
    
    // --- CORREÇÃO: Monta uma lista temporária unificada ---
    var _s_type = debug_types_list[debug_selected_type_idx];
    var _type_data = variable_struct_get(global.attack_database, _s_type);
    
    // Cria array temporário juntando [Básicos] + [Especiais]
    var _display_list = [];
    
    // Adiciona os 2 básicos (índices 0 e 1)
    array_push(_display_list, _type_data.basics[0]);
    array_push(_display_list, _type_data.basics[1]);
    
    // Adiciona os 3 especiais (índices 2, 3 e 4)
    array_push(_display_list, _type_data.specials[0]);
    array_push(_display_list, _type_data.specials[1]);
    array_push(_display_list, _type_data.specials[2]);
    
    // Seleciona o ataque da lista unificada
    var _s_atk = _display_list[debug_selected_atk_idx];
    
    // Exibe Tipo Atual
    draw_text(_mx + 10, _my + 80, "TIPO SELECIONADO: < " + string_upper(_s_type) + " >");
    
    // Lista os 5 ataques
    for (var i = 0; i < 5; i++) {
        var _col = c_gray;
        if (i == debug_selected_atk_idx) _col = c_yellow;
        draw_set_color(_col);
        
        var _a = _display_list[i];
        var _prefix = (i < 2) ? "[BAS] " : "[ESP] "; // Marca visualmente se é básico ou especial
        
        draw_text(_mx + 20, _my + 110 + (i * 20), _prefix + _a.name);
    }
    draw_set_color(c_white);
    
    // Info do Ataque Selecionado
    draw_text(_mx + 10, _my + 230, "Detalhes:");
    draw_text(_mx + 20, _my + 250, "Dano: " + string(_s_atk.damage));
    draw_text(_mx + 20, _my + 270, "Forma: " + _s_atk.shape);
    draw_text(_mx + 20, _my + 290, "Efeito: " + _s_atk.effect);
    
    // Aplicação das Mudanças
    if (keyboard_check_pressed(vk_enter)) {
        // Se apertar Enter, define como ESPECIAL
        // (Nota: permite definir um ataque básico como especial se quiser testar, mas o ideal é seguir a categoria)
        special_atk = _s_atk;
        type_1 = _s_type;
        special_cooldown = 0; // Reseta CD para testar
        show_debug_message("Especial alterado para: " + _s_atk.name);
    }
    if (keyboard_check_pressed(vk_space)) {
        // Se apertar Espaço, define como BÁSICO
        basic_atk = _s_atk;
        type_1 = _s_type;
        attack_cooldown = 0;
        show_debug_message("Básico alterado para: " + _s_atk.name);
    }
    
    // Status Atual do Monstro
    draw_text(_mx + 10, _my + 350, "--- MONSTRO ATUAL ---");
    draw_text(_mx + 10, _my + 370, "Básico: " + basic_atk.name);
    draw_text(_mx + 10, _my + 390, "Especial: " + special_atk.name);
    draw_text(_mx + 10, _my + 410, "CD Especial: " + string(special_cooldown));
    draw_text(_mx + 10, _my + 430, "Congelado: " + string(debug_freeze));
}