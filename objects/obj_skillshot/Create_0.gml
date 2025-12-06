owner = noone; // Quem atirou (para não se acertar)
move_data = undefined; // Dados do golpe (struct Move)
lifetime = 0;
max_lifetime = 120; // Segurança para destruir
damage_dealt = false; // Para AoE não dar dano todo frame
target_x = x;
target_y = y;
dir = 0;