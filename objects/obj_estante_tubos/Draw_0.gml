/// @description Desenho do Objeto no Mapa

// Desenha a Estante Alquímica de Madeira
draw_set_color(c_maroon);
draw_rectangle(x - 20, y - 40, x + 20, y, false);
draw_set_color(c_yellow);
draw_rectangle(x - 20, y - 40, x + 20, y, true);

// Prateleiras e Frascos
draw_set_color(c_dkgray);
draw_line(x - 18, y - 28, x + 18, y - 28);
draw_line(x - 18, y - 14, x + 18, y - 14);

// Frascos de Ensaio (Desenho Alquímico)
draw_set_color(c_purple);
draw_rectangle(x - 14, y - 36, x - 10, y - 29, false);
draw_set_color(c_lime);
draw_rectangle(x - 6, y - 36, x - 2, y - 29, false);
draw_set_color(c_aqua);
draw_rectangle(x + 2, y - 36, x + 6, y - 29, false);
draw_set_color(c_red);
draw_rectangle(x + 10, y - 36, x + 14, y - 29, false);

draw_set_color(c_white);

// Indicador Flutuante de Interação
if (player_nearby && !is_open) {
    draw_set_halign(fa_center);
    draw_set_color(c_yellow);
    draw_text(x, y - 55, "[B / E] Estante de Tubos");
    draw_set_halign(fa_left);
    draw_set_color(c_white);
}
