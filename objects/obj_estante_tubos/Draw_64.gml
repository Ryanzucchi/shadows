/// @description Interface da Estante Box (Transferência de Tubos)

if (!is_open) exit;

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

var _w = 680;
var _h = 460;
var _x = (_gw - _w) / 2;
var _y = (_gh - _h) / 2;

// Fundo do Menu Alquímico
draw_set_alpha(0.92);
draw_set_color(c_black);
draw_roundrect_ext(_x, _y, _x + _w, _y + _h, 16, 16, false);
draw_set_alpha(1.0);

draw_set_color(c_yellow);
draw_roundrect_ext(_x, _y, _x + _w, _y + _h, 16, 16, true);

// Título Central
draw_set_halign(fa_center);
draw_set_color(c_yellow);
draw_text(_x + (_w / 2), _y + 15, "=== ESTANTE DE TUBOS DE ENSAIO (BOX ALQUÍMICO) ===");
draw_set_halign(fa_left);

// Dividindo em 2 Colunas: Painel Esquerdo (Equipe) & Painel Direito (Estante)
var _col_w = (_w - 60) / 2;
var _left_x = _x + 20;
var _right_x = _x + 40 + _col_w;
var _panel_y = _y + 45;
var _panel_h = _h - 90;

// PAINEL DA EQUIPE (ESQUERDA)
draw_set_color(current_side == 0 ? c_yellow : c_dkgray);
draw_rectangle(_left_x, _panel_y, _left_x + _col_w, _panel_y + _panel_h, true);
draw_set_color(c_aqua);
draw_text(_left_x + 10, _panel_y + 10, "EQUIPE ATIVA (Lvl." + string(global.player_level) + ")");

var _party_len = array_length(global.party);
var _py = _panel_y + 35;

if (_party_len == 0) {
    draw_set_color(c_gray);
    draw_text(_left_x + 15, _py + 20, "Equipe vazia.");
} else {
    for (var i = 0; i < _party_len; i++) {
        var _mon = global.party[i];
        var _is_sel = (current_side == 0 && i == selected_party_idx);
        var _item_y = _py + (i * 45);
        
        if (_is_sel) {
            draw_set_color(c_yellow);
            draw_rectangle(_left_x + 5, _item_y - 2, _left_x + _col_w - 5, _item_y + 38, true);
        }
        
        draw_set_color(_is_sel ? c_yellow : c_white);
        draw_text(_left_x + 12, _item_y, string(i+1) + ". " + _mon.name + " (Lvl." + string(_mon.level) + ")");
        draw_set_color(c_ltgray);
        draw_text(_left_x + 20, _item_y + 18, "HP: " + string(ceil(_mon.hp)) + "/" + string(_mon.max_hp) + " | " + _mon.element);
    }
}

// PAINEL DA ESTANTE BOX (DIREITA)
draw_set_color(current_side == 1 ? c_yellow : c_dkgray);
draw_rectangle(_right_x, _panel_y, _right_x + _col_w, _panel_y + _panel_h, true);
draw_set_color(c_purple);
draw_text(_right_x + 10, _panel_y + 10, "ESTANTE DE TUBOS (GUARDADOS)");

var _box_len = array_length(global.box);
var _by = _panel_y + 35;

if (_box_len == 0) {
    draw_set_color(c_gray);
    draw_text(_right_x + 15, _by + 20, "Estante vazia.");
} else {
    for (var i = 0; i < _box_len; i++) {
        var _mon = global.box[i];
        var _is_sel = (current_side == 1 && i == selected_box_idx);
        var _item_y = _by + (i * 45);
        
        if (_is_sel) {
            draw_set_color(c_yellow);
            draw_rectangle(_right_x + 5, _item_y - 2, _right_x + _col_w - 5, _item_y + 38, true);
        }
        
        draw_set_color(_is_sel ? c_yellow : c_white);
        draw_text(_right_x + 12, _item_y, string(i+1) + ". " + _mon.name + " (Lvl." + string(_mon.level) + ")");
        draw_set_color(c_ltgray);
        draw_text(_right_x + 20, _item_y + 18, "HP: " + string(ceil(_mon.hp)) + "/" + string(_mon.max_hp) + " | " + _mon.element);
    }
}

// Rodapé de Instruções
draw_set_color(c_yellow);
draw_set_halign(fa_center);
draw_text(_x + (_w / 2), _y + _h - 35, "⬅️ / ➡️: Trocar Lado | ⬆️ / ⬇️: Selecionar | A / Enter: Mover Tubo | B / E: Fechar");
draw_set_halign(fa_left);
