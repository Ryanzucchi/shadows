/// @description Interface de Loja Alquímica & Diálogo

if (!is_open) exit;

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

var _w = 620;
var _h = 420;
var _x = (_gw - _w) / 2;
var _y = (_gh - _h) / 2;

// Fundo do Balcão de Loja
draw_set_alpha(0.92);
draw_set_color(c_black);
draw_roundrect_ext(_x, _y, _x + _w, _y + _h, 16, 16, false);
draw_set_alpha(1.0);

draw_set_color(c_purple);
draw_roundrect_ext(_x, _y, _x + _w, _y + _h, 16, 16, true);
draw_set_color(c_yellow);
draw_roundrect_ext(_x - 2, _y - 2, _x + _w + 2, _y + _h + 2, 18, 18, true);

// Cabeçalho da Loja
draw_set_color(c_yellow);
draw_text(_x + 20, _y + 15, "🔮 LOJA ALQUÍMICA DE " + string_upper(npc_name));

draw_set_color(c_lime);
draw_set_halign(fa_right);
draw_text(_x + _w - 20, _y + 15, "💰 Moedas: " + string(global.player_coins));
draw_set_halign(fa_left);

// Balão de Diálogo
draw_set_color(c_dkgray);
draw_roundrect(_x + 20, _y + 40, _x + _w - 20, _y + 80, false);
draw_set_color(c_white);
draw_text_ext(_x + 30, _y + 48, dialog_text, 18, _w - 60);

// Lista de Itens à Venda
var _sy = _y + 95;
var _shop_len = array_length(shop_items);

for (var i = 0; i < _shop_len; i++) {
    var _slot = shop_items[i];
    var _is_sel = (i == selected_shop_idx);
    var _item_y = _sy + (i * 48);
    
    if (_is_sel) {
        draw_set_color(c_yellow);
        draw_rectangle(_x + 20, _item_y - 2, _x + _w - 20, _item_y + 40, true);
    }
    
    draw_set_color(_slot.item.color);
    draw_text(_x + 30, _item_y + 2, "🧪 " + _slot.item.name);
    
    draw_set_color(c_lime);
    draw_set_halign(fa_right);
    draw_text(_x + _w - 30, _item_y + 2, string(_slot.price) + " Moedas");
    draw_set_halign(fa_left);
    
    draw_set_color(c_ltgray);
    draw_text(_x + 30, _item_y + 20, _slot.item.description);
}

// Rodapé
draw_set_color(c_yellow);
draw_set_halign(fa_center);
draw_text(_x + (_w / 2), _y + _h - 30, "⬆️ / ⬇️: Selecionar Item | A / Enter: Comprar Item | B / E: Sair da Loja");
draw_set_halign(fa_left);
