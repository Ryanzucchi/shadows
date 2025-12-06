/// @description A Lógica que serve para TODOS
// Se o sprite estiver definido, usa ele. Se não, não crasha.
if (sprite_index != -1) {
    // 1. Calcular Distância
    var _dist = point_distance(x, y, obj_jogador.x, obj_jogador.y);
    var _dir = point_direction(x, y, obj_jogador.x, obj_jogador.y);

    // 2. State Machine Simplificada
    switch(state) {
        case "IDLE":
            sprite_index = spr_idle;
            hspd = 0;
            vspd = 0;
            
            // Se ver o player, persegue
            if (_dist < raio_visao) state = "CHASE";
        break;
        
        case "CHASE":
            sprite_index = spr_walk;
            
            // Virar para o lado certo (Espelhamento)
            if (obj_jogador.x > x) image_xscale = 1; // Direita
            else image_xscale = -1; // Esquerda
            
            // Mover
            hspd = lengthdir_x(velocidade, _dir);
            vspd = lengthdir_y(velocidade, _dir);
            
            // Se chegar perto, ataca
            if (_dist < raio_ataque && pode_atacar) {
                state = "ATTACK";
                image_index = 0;
                hspd = 0;
                vspd = 0;
            }
            
            // Se player fugir muito, desiste
            if (_dist > raio_visao * 1.5) state = "IDLE";
        break;
        
        case "ATTACK":
            sprite_index = spr_attack;
            
            // PONTO DE DANO: Geralmente no meio da animação (frame 3 ou 4)
            if (image_index >= 3 && pode_atacar) {
                // Cria hitbox ou dá dano direto
                // (Código de dano virá depois)
                pode_atacar = false;
                alarm[0] = 60; // Cooldown
            }
            
            if (image_index >= image_number - 1) state = "IDLE";
        break;
    }
    
    // 3. Colisão e Aplicação de Movimento
    if (place_meeting(x + hspd, y, obj_parede)) hspd = 0;
    x += hspd;
    
    if (place_meeting(x, y + vspd, obj_parede)) vspd = 0;
    y += vspd;
    
    // 4. Profundidade 3D
    depth = -bbox_bottom;
}