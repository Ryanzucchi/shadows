if (state != "DEAD") {
    // Desenha a sombra um pouco abaixo do personagem
    draw_sprite(spr_shadow, 0, x, y + 4);
}
draw_self();

// Desenha a Retícula de Lock-on sobre o inimigo travado
if (variable_instance_exists(id, "lockon_target") && lockon_target != noone && instance_exists(lockon_target)) {
    var _tx = lockon_target.x;
    var _ty = lockon_target.y - 12;
    var _r = 16 + sin(current_time / 100) * 3; // Efeito Pulsante
    
    draw_set_color(c_red);
    draw_circle(_tx, _ty, _r, true);
    draw_line(_tx - _r - 4, _ty, _tx - _r + 4, _ty);
    draw_line(_tx + _r - 4, _ty, _tx + _r + 4, _ty);
    draw_line(_tx, _ty - _r - 4, _tx, _ty - _r + 4);
    draw_line(_tx, _ty + _r - 4, _tx, _ty + _r + 4);
    draw_set_color(c_white);
}