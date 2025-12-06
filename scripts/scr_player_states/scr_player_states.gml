function state_free() {
    // 1. Calcular Velocidade (Aceleração e Fricção)
    var _target_spd = is_moving ? move_spd : 0;
    spd_current = lerp(spd_current, _target_spd, is_moving ? accel : friction_amt);

    // 2. Calcular movimento X e Y
    h_spd = lengthdir_x(spd_current, input_dir);
    v_spd = lengthdir_y(spd_current, input_dir);

    // 3. Colisão e Movimento (Sistema moderno move_and_collide)
    // Se estiver usando versão antiga, avise que mando o código de place_meeting
    move_and_collide(h_spd, v_spd, obj_parede); // Substitua obj_wall pelo seu objeto de colisão

    // 4. Atualizar Sprite e Direção do Rosto
    if (is_moving) {
        // A mágica matemática para converter 360 graus em index 0-7
        // Adicionamos 22.5 (45/2) para centralizar o ângulo na direção correta
        var _dir_index = floor((input_dir + 22.5) / 45);
        if (_dir_index >= 8) _dir_index = 0;
        
        face_dir = _dir_index;
        
        sprite_index = sprites_walk[face_dir];
        image_speed = 1; // Velocidade normal da animação
    } else {
        sprite_index = sprites_idle[face_dir];
        image_speed = 0.5; // Idle geralmente é mais lento
    }
    
    // 5. Gatilho do Dash
    if (key_dash && dash_cooldown <= 0 && is_moving) {
        state = STATES.DASH;
        dash_timer = dash_duration;
        dash_cooldown = dash_cooldown_max;
        
        // Zera o índice da animação para o Dash começar do frame 0
        image_index = 0; 
        
        // Efeito visual (opcional): Criar poeira ou som
    }
    
    // Reduzir cooldown do dash
    if (dash_cooldown > 0) dash_cooldown--;
}