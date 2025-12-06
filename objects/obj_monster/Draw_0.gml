draw_self();

// Debug HP e Estado
draw_set_halign(fa_center);
draw_set_color(c_white);

// Se não tiver sprite, desenha bolinha
if (sprite_index == -1) {
    draw_set_color(global.type_colors[types[0]]);
    draw_circle(x, y, 16, false);
}

// Barra de HP
var _hp_pct = (hp / hp_max) * 100;
draw_healthbar(x-16, y-25, x+16, y-20, _hp_pct, c_black, c_red, c_green, 0, true, true);

// Debug Texto
// draw_text(x, y-40, state);