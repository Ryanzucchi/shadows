if (is_undefined(move_data)) exit;

draw_set_color(move_data.color);

if (move_data.shape == "linear") {
    draw_circle(x, y, 8, false); // Pequeno círculo
    // Rastro (Telegraph simples)
    draw_set_alpha(0.3);
    draw_circle(x - lengthdir_x(5, dir), y - lengthdir_y(5, dir), 6, false);
    draw_set_alpha(1);
} 
else if (move_data.shape == "circle_aoe") {
    // Telegraph: Circulo crescendo ou piscando
    draw_set_alpha(0.4);
    draw_circle(x, y, move_data.range, false);
    draw_set_alpha(1);
    draw_circle(x, y, move_data.range, true); // Borda
}
else if (move_data.shape == "cone") {
    // Desenha um triângulo na direção
    var x1 = x + lengthdir_x(move_data.range, dir - 20);
    var y1 = y + lengthdir_y(move_data.range, dir - 20);
    var x2 = x + lengthdir_x(move_data.range, dir + 20);
    var y2 = y + lengthdir_y(move_data.range, dir + 20);
    draw_triangle(x, y, x1, y1, x2, y2, false);
}

draw_set_color(c_white);