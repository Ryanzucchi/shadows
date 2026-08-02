/// @description Desenho Visual da Janela de Inventário & Tomo Mágico

if (!is_open) exit;

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

var _w = 640;
var _h = 440;
var _x = (_gw - _w) / 2;
var _y = (_gh - _h) / 2;

// --- Fundo Semitransparente & Borda Alquímica ---
draw_set_alpha(0.92);
draw_set_color(c_black);
draw_roundrect_ext(_x, _y, _x + _w, _y + _h, 16, 16, false);
draw_set_alpha(1.0);

draw_set_color(c_purple);
draw_roundrect_ext(_x, _y, _x + _w, _y + _h, 16, 16, true);
draw_set_color(c_yellow);
draw_roundrect_ext(_x - 2, _y - 2, _x + _w + 2, _y + _h + 2, 18, 18, true);

// --- Título / Abas Superior ---
var _tab_w = _w / 3;
for (var i = 0; i < 3; i++) {
    var _tx1 = _x + (i * _tab_w);
    var _tx2 = _tx1 + _tab_w;
    
    if (i == current_tab) {
        draw_set_color(c_dkgray);
        draw_rectangle(_tx1 + 4, _y + 6, _tx2 - 4, _y + 36, false);
        draw_set_color(c_yellow);
        draw_rectangle(_tx1 + 4, _y + 6, _tx2 - 4, _y + 36, true);
    } else {
        draw_set_color(c_gray);
    }
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(_tx1 + (_tab_w / 2), _y + 21, tab_names[i]);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _content_y = _y + 50;

// --- CONTEÚDO DAS ABAS ---
switch (current_tab) {
    case 0: // 🧪 TUBOS DE ENSAIO (PARTY)
        draw_set_color(c_aqua);
        draw_text(_x + 20, _content_y, "--- SUAS CRIATURAS EM TUBOS DE ENSAIO ---");
        draw_set_color(c_white);
        draw_text(_x + 350, _content_y, "(Selecione um tubo para reordenar)");
        
        var _ty = _content_y + 30;
        var _party_len = array_length(global.party);
        
        if (_party_len == 0) {
            draw_set_color(c_gray);
            draw_text(_x + 30, _ty + 40, "Nenhum tubo de ensaio na equipe.");
        } else {
            for (var i = 0; i < _party_len; i++) {
                var _mon = global.party[i];
                var _is_sel = (i == selected_index);
                var _is_swap = (i == swap_source_index);
                
                // Desenha Frasco/Tubo Gráfico
                var _fx = _x + 30;
                var _fy = _ty + (i * 55);
                
                // Borda do Destaque
                if (_is_swap) {
                    draw_set_color(c_lime);
                    draw_rectangle(_fx - 5, _fy - 4, _fx + 580, _fy + 46, true);
                } else if (_is_sel) {
                    draw_set_color(c_yellow);
                    draw_rectangle(_fx - 5, _fy - 4, _fx + 580, _fy + 46, true);
                }
                
                // Desenha Tubo de Ensaio Gráfico (Frasco Alquímico)
                draw_set_color(c_white);
                draw_rectangle(_fx, _fy, _fx + 20, _fy + 40, true); // Vidro do Tubo
                
                // Líquido do Monstro (Cor do Elemento)
                var _liquid_col = c_purple;
                switch (_mon.element) {
                    case "fogo":   _liquid_col = c_red; break;
                    case "agua":   _liquid_col = c_blue; break;
                    case "grama":  _liquid_col = c_lime; break;
                    case "sombra": _liquid_col = c_purple; break;
                    case "terra":  _liquid_col = c_orange; break;
                    case "luz":    _liquid_col = c_yellow; break;
                }
                draw_set_color(_liquid_col);
                draw_rectangle(_fx + 2, _fy + 10, _fx + 18, _fy + 38, false); // Nível do Líquido
                
                // Textos das Informações do Monstro
                draw_set_color(_is_sel ? c_yellow : c_white);
                var _status_txt = _mon.is_summoned ? "[INVOCADO NO MAPA]" : "[NO FRASCO]";
                draw_text(_fx + 35, _fy + 2, "Tubo " + string(i+1) + ": " + _mon.name + " (Lvl." + string(_mon.level) + ") " + _status_txt);
                
                draw_set_color(c_ltgray);
                draw_text(_fx + 35, _fy + 22, "HP: " + string(ceil(_mon.hp)) + "/" + string(_mon.max_hp) + " | Humor: " + _mon.mood + " | Personalidade: " + _mon.personality);
            }
        }
    break;

    case 1: // 📖 TOMO DE MAGIAS (LIVRO)
        draw_set_color(c_yellow);
        draw_text(_x + 20, _content_y, "--- TOMO DE MAGIAS ANOTADAS (MOUSE LEFT / RT) ---");
        
        var _spell_keys = variable_struct_get_names(global.spell_database);
        var _sy = _content_y + 30;
        
        for (var i = 0; i < array_length(_spell_keys); i++) {
            var _key = _spell_keys[i];
            var _spell = variable_struct_get(global.spell_database, _key);
            var _is_sel = (i == selected_index);
            var _is_eq = (global.equipped_spell.spell_id == _spell.spell_id);
            
            var _sx = _x + 30;
            var _sitem_y = _sy + (i * 45);
            
            if (_is_sel) {
                draw_set_color(c_yellow);
                draw_rectangle(_sx - 5, _sitem_y - 2, _sx + 580, _sitem_y + 38, true);
            }
            
            draw_set_color(_is_eq ? c_lime : (_is_sel ? c_yellow : c_white));
            var _eq_tag = _is_eq ? " [EQUIPADA NO MOUSE LEFT]" : "";
            draw_text(_sx, _sitem_y, "✨ " + _spell.name + " (" + string(_spell.element) + ")" + _eq_tag);
            
            draw_set_color(c_ltgray);
            draw_text(_sx + 20, _sitem_y + 18, "Custo Mana: " + string(_spell.mana_cost) + " | " + _spell.description);
        }
    break;

    case 2: // 🎒 LISTA DE ITENS
        draw_set_color(c_lime);
        draw_text(_x + 20, _content_y, "--- SEUS ITENS & POÇÕES ---");
        
        var _iy = _content_y + 30;
        var _inv_len = array_length(global.player_inventory);
        
        if (_inv_len == 0) {
            draw_set_color(c_gray);
            draw_text(_x + 30, _iy + 40, "Inventário de itens vazio.");
        } else {
            for (var i = 0; i < _inv_len; i++) {
                var _slot = global.player_inventory[i];
                var _is_sel = (i == selected_index);
                var _ix = _x + 30;
                var _item_y = _iy + (i * 45);
                
                if (_is_sel) {
                    draw_set_color(c_yellow);
                    draw_rectangle(_ix - 5, _item_y - 2, _ix + 580, _item_y + 38, true);
                }
                
                draw_set_color(_slot.item.color);
                draw_text(_ix, _item_y, "🧪 " + _slot.item.name + " x" + string(_slot.count));
                
                draw_set_color(c_ltgray);
                draw_text(_ix + 20, _item_y + 18, _slot.item.description);
            }
        }
    break;
}

// --- Rodapé com Instruções ---
draw_set_color(c_yellow);
draw_set_halign(fa_center);
draw_text(_x + (_w / 2), _y + _h - 30, "A / D / D-Pad: Mudar Aba | W / S: Selecionar | A / Espaço: Executar Ação | I / TAB: Fechar");
draw_set_halign(fa_left);
