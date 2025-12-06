/// @description Debug na Tela

// Configura fonte e cor (opcional, mas facilita a leitura)
draw_set_color(c_yellow);
draw_set_halign(fa_left);

// Desenha o texto no canto superior esquerdo (x: 10, y: 10)
draw_text(10, 10, "State: " + string(state));
draw_text(10, 30, "Face: " + string(face)); // Útil para ver a direção

// Reseta a cor para branco (para não pintar outros objetos sem querer)
draw_set_color(c_white);