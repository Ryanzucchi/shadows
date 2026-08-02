/// @description Desenho do NPC Alquimista no Mapa

// Corpo e Chapéu de Bruxa Alquimista
draw_set_color(c_purple);
draw_ellipse(x - 12, y - 32, x + 12, y, false);

// Chapéu de Bruxa
draw_set_color(c_dkgray);
draw_ellipse(x - 18, y - 30, x + 18, y - 24, false); // Aba do chapéu
draw_triangle(x - 10, y - 28, x + 10, y - 28, x, y - 48, false); // Cone do chapéu
draw_set_color(c_yellow);
draw_line(x - 10, y - 28, x + 10, y - 28); // Fita amarela

draw_set_color(c_white);

// Indicador Flutuante
if (player_nearby && !is_open) {
    draw_set_halign(fa_center);
    draw_set_color(c_yellow);
    draw_text(x, y - 58, "[B / E] Loja de " + npc_name);
    draw_set_halign(fa_left);
    draw_set_color(c_white);
}
