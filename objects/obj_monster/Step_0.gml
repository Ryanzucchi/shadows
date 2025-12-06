/// @description Máquina de Estados

// Se o jogo estiver pausado, saia (implemente checagem global se tiver)
// if (global.pause) exit;

// Gerenciar morte
if (state == "DEATH") {
    sprite_index = spr_death;
    if (image_index >= image_number - 1) {
        image_speed = 0;
        image_alpha -= 0.02;
        if (image_alpha <= 0) instance_destroy();
    }
    return; // Não executa o resto
}

// Reduz cooldowns
for (var i = 0; i < array_length(move_cooldowns); i++) {
    if (move_cooldowns[i] > 0) move_cooldowns[i]--;
}

// --- MÁQUINA DE ESTADOS ---
switch (state) {
    case "IDLE":
        sprite_index = spr_idle;
        speed = 0;
        
        // IA: Decide se anda ou fica parado
        if (state_timer++ > 60) {
            // 30% de chance de andar, 70% de ficar
            if (choose(true, false, false)) {
                state = "WANDER";
                direction = irandom(360);
            }
            state_timer = 0;
        }
        check_aggro();
        break;

    case "WANDER":
        sprite_index = spr_walk;
        speed = spd * 0.5; // Anda devagar
        
        // Colisão simples
        if (place_meeting(x + hspeed, y + vspeed, obj_parede)) {
            direction = irandom(360);
        }
        
        // Volta para Idle
        if (state_timer++ > 120) {
            state = "IDLE";
            state_timer = 0;
        }
        check_aggro();
        break;

    case "CHASE":
        sprite_index = spr_walk;
        
        if (instance_exists(target)) {
            // Movimento em direção ao alvo
            var _dir_to_target = point_direction(x, y, target.x, target.y);
            var _dist_to_target = point_distance(x, y, target.x, target.y);
            
            // "mp_potential_step" tenta ir para o alvo desviando de paredes
            // Se preferir movimento mais fluido sem travar:
            mp_potential_step(target.x, target.y, chase_spd, false);
            
            face_dir = _dir_to_target; // Atualiza para onde olha
            
            // Checa alcance de ataque
            if (_dist_to_target <= attack_range) {
                state = "ATTACK";
                state_timer = 0;
                speed = 0; // Para para atacar
            }
            
            // Desiste se fugir muito
            if (_dist_to_target > aggro_range * 1.5) {
                state = "IDLE";
                target = noone;
            }
        } else {
            state = "IDLE";
        }
        break;

    case "ATTACK":
        sprite_index = spr_attack; // Se tiver sprite de ataque
        speed = 0;
        
        // Lógica de escolha de golpe
        var _move_to_use = -1;
        
        // Prioriza Slot 1 (Ativo), senão Slot 0 (Auto)
        if (array_length(moveset) > 1 && !is_undefined(moveset[1]) && move_cooldowns[1] <= 0) {
            _move_to_use = 1;
        } else if (!is_undefined(moveset[0]) && move_cooldowns[0] <= 0) {
            _move_to_use = 0;
        }
        
        if (_move_to_use != -1) {
            perform_attack(_move_to_use);
            move_cooldowns[_move_to_use] = moveset[_move_to_use].cooldown;
            
            // Entra em Cooldown (Pausa pós ataque)
            state = "COOLDOWN";
            state_timer = 45; // Fica parado 45 frames recuperando fôlego
        } else {
            // Tudo em cooldown? Kiting (recua ou persegue)
            state = "CHASE";
        }
        break;
        
    case "COOLDOWN":
        sprite_index = spr_idle;
        speed = 0;
        if (state_timer-- <= 0) state = "CHASE";
        break;
}

// --- Atualiza Sprite (Flip X) ---
if (x != xprevious) {
    if (x > xprevious) image_xscale = 1;
    else image_xscale = -1;
}