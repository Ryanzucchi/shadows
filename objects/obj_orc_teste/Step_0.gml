// Se estiver congelado pelo debug, não faz nada
if (variable_instance_exists(id, "debug_freeze") && debug_freeze) exit;

var _player = instance_nearest(x, y, obj_jogador);
var _dist = point_distance(x, y, _player.x, _player.y);

// --- 1. GESTÃO DE COOLDOWNS ---
if (attack_cooldown > 0) attack_cooldown--;
if (special_cooldown > 0) special_cooldown--;

// --- 2. MÁQUINA DE ESTADOS ---
switch (state) {
    case MO_STATE.IDLE:
        if (_dist < aggro_range) state = MO_STATE.CHASE;
        break;

    case MO_STATE.CHASE:
        if (_dist > aggro_range * 1.5) {
            state = MO_STATE.IDLE;
        } 
        else {
            // Lógica de Alcance: Ataques de área (range 0) usam o tamanho (width) como alcance
            var _spec_range = (special_atk.range == 0) ? special_atk.width * 1.5 : special_atk.range;
            var _basic_range = (basic_atk.range == 0) ? basic_atk.width * 1.5 : basic_atk.range;

            // A. TENTA USAR ESPECIAL (Prioridade máxima)
            if (special_cooldown <= 0) {
                if (_dist <= _spec_range) {
                    // Prepara Especial
                    current_active_attack = special_atk;
                    state = MO_STATE.CHANNELING;
                    channel_timer = special_atk.channel_time;
                    target_x = _player.x;
                    target_y = _player.y;
                } else {
                    // Está longe para o especial? Chega mais perto
                    mp_potential_step(_player.x, _player.y, spd, false);
                }
            }
            // B. TENTA USAR BÁSICO (Se especial não disponível)
            else if (attack_cooldown <= 0 && _dist <= _basic_range) {
                current_active_attack = basic_atk;
                state = MO_STATE.CHANNELING;
                channel_timer = basic_atk.channel_time;
                target_x = _player.x;
                target_y = _player.y;
            }
            // C. MOVIMENTO
            else {
                mp_potential_step(_player.x, _player.y, spd, false);
            }
        }
        break;

    case MO_STATE.CHANNELING:
        // Telegraph: Mira travada ou acompanhando (depende do gosto)
        if (channel_timer > 0) {
            channel_timer--;
        } else {
            state = MO_STATE.ATTACKING;
        }
        break;

    case MO_STATE.ATTACKING:
        // CRIA O GOLPE
        var _dir = point_direction(x, y, target_x, target_y);
        var _proj = instance_create_layer(x, y, "Instances", obj_skillshot);
        
        _proj.attack_data = current_active_attack;
        _proj.owner = id;
        _proj.target_type = obj_jogador;
        _proj.image_angle = _dir;
        _proj.direction = _dir;

        // Configura posição (Area spawna no alvo, Projétil spawna no monstro)
        if (current_active_attack.shape == "area") {
            _proj.x = target_x;
            _proj.y = target_y;
            _proj.speed = 0;
        } 
        else if (current_active_attack.shape == "self") {
            _proj.x = x;
            _proj.y = y;
            _proj.speed = 0;
        }
        else {
            _proj.x = x;
            _proj.y = y;
            _proj.speed = current_active_attack.proj_speed;
        }

        // APLICA COOLDOWN FIXO
        if (current_active_attack == special_atk) {
            special_cooldown = special_atk.cooldown_max; // CD Longo
            attack_cooldown = 60; // Pausa global
        } else {
            attack_cooldown = basic_atk.cooldown_max; // CD Curto
        }

        state = MO_STATE.COOLDOWN;
        state_timer = 30; // Pausa pós-golpe (animação)
        break;

    case MO_STATE.COOLDOWN:
        if (state_timer > 0) state_timer--;
        else state = MO_STATE.CHASE;
        break;
}

if (hp <= 0) instance_destroy();