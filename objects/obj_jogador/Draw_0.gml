if (state != "DEAD") {
    // Desenha a sombra um pouco abaixo do personagem
    // Certifique-se de ter o sprite spr_shadow importado e centralizado
    draw_sprite(spr_shadow, 0, x, y + 4);
}
draw_self();