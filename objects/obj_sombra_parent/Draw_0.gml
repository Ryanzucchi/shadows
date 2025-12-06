/// @description Desenha Sprite + Debug

// 1. OBRIGATÓRIO: Desenha o monstro
draw_self(); 

// 2. Desenha o Debug (com o nome novo da variável)
if (modo_debug) {
    // Salva configurações antigas
    var _cor_antiga = draw_get_color();
    var _alpha_antigo = draw_get_alpha();
    
    draw_set_halign(fa_center);
    
    // Texto do Estado
    draw_set_color(c_white);
    draw_text(x, bbox_top - 20, state);
    
    // Visão (Amarelo)
    draw_set_alpha(0.3);
    draw_set_color(c_yellow);
    draw_circle(x, y, raio_visao, true);
    
    // Ataque (Vermelho)
    draw_set_color(c_red);
    draw_circle(x, y, raio_ataque, true);
    
    // Linha de Alvo
    if (state == "CHASE" && instance_exists(obj_jogador)) {
        draw_set_alpha(0.8);
        draw_set_color(c_lime);
        draw_line(x, y, obj_jogador.x, obj_jogador.y);
    }

    // Restaura configurações
    draw_set_halign(fa_left);
    draw_set_color(_cor_antiga);
    draw_set_alpha(_alpha_antigo);
}