var _player = instance_nearest(x, y, obj_jogador);
var _dist = point_distance(x, y, _player.x, _player.y);

// Cooldown
if (attack_cooldown > 0) attack_cooldown--;

// Se estiver congelado pelo debug, sai
if (debug_freeze) exit;

switch (state) {
    case MO_STATE.IDLE:
        if (_dist < aggro_range) state = MO_STATE.CHASE;
        break;

    case MO_STATE.CHASE:
        // Define qual ataque usar (Simples IA: tenta especial, senão básico)
        var _chosen = undefined;
        
        // Se especial pronto e no range
        if (attack_cooldown <= 0 && _dist <= special_atk.range) {
            _chosen = special_atk;
        } 
        // Se básico pronto e no range (e especial em CD ou fora de range)
        else if (attack_cooldown <= 0 && _dist <= basic_atk.range) {
            _chosen = basic_atk;
        }
        
        // Tratamento especial para ataques "self" (proximity) e "area"
        if (_chosen != undefined) {
            // Se for ataque de área global (range 0) ou self, atira
            if (_chosen.shape == "self" || _chosen.shape == "area") {
                if (_dist <= 150) { // Range fixo de aggro para melee/self
                    current_attack = _chosen;
                    state = MO_STATE.CHANNELING;
                    channel_timer = _chosen.channel_time;
                    target_x = _player.x;
                    target_y = _player.y;
                } else {
                    mp_potential_step(_player.x, _player.y, spd, false);
                }
            }
            else {
                // Ataques de projétil/linha
                current_attack = _chosen;
                state = MO_STATE.CHANNELING;
                channel_timer = _chosen.channel_time;
                target_x = _player.x;
                target_y = _player.y;
            }
        } 
        else {
            // Move-se se não estiver atacando
            if (_dist > aggro_range * 1.5) state = MO_STATE.IDLE;
            else mp_potential_step(_player.x, _player.y, spd, false);
        }
        break;

    case MO_STATE.CHANNELING:
        // Parado carregando
        if (channel_timer > 0) {
            channel_timer--;
            // Travar mira apenas no início ou seguir? Vamos travar para permitir esquiva.
        } else {
            state = MO_STATE.ATTACKING;
        }
        break;

    case MO_STATE.ATTACKING:
        // Instancia o obj_skillshot
        var _dir = point_direction(x, y, target_x, target_y);
        
        var _s = instance_create_layer(x, y, "Instances", obj_skillshot);
        _s.attack_data = current_attack;
        _s.owner = id;
        _s.target_type = obj_jogador;
        
        // Configura posição e movimento
        if (current_attack.shape == "self") {
            _s.x = x;
            _s.y = y;
            _s.speed = 0;
            _s.image_angle = 0;
        } 
        else if (current_attack.shape == "area") {
            _s.x = target_x; // Spawna no alvo
            _s.y = target_y;
            _s.speed = 0;
        }
        else {
            _s.x = x;
            _s.y = y;
            _s.direction = _dir;
            _s.image_angle = _dir;
            _s.speed = current_attack.proj_speed;
        }

        // Aplica Cooldown
        attack_cooldown = current_attack.cooldown_max;
        state = MO_STATE.COOLDOWN;
        state_timer = 30; // Pausa pós-golpe
        break;

    case MO_STATE.COOLDOWN:
        if (state_timer > 0) state_timer--;
        else state = MO_STATE.CHASE;
        break;
}

// Morte
if (hp <= 0) instance_destroy();