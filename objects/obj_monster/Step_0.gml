// Variável de Aliado
var _is_ally = variable_instance_exists(id, "is_ally") ? is_ally : false;

// 1. Descobrir Alvo Principal usando módulo de IA
var _target = ai_find_target(_is_ally, id);
var _dist = (_target != noone) ? point_distance(x, y, _target.x, _target.y) : 999999;
var _player_inst = instance_nearest(x, y, obj_jogador);

// 2. Aplicar Modificadores de Personalidade e Humor
var _mods = ai_apply_modifiers(id, spd, aggro_range);
var _final_spd = _mods.final_spd;
var _final_aggro = _mods.final_aggro;

// 3. Obter o Alvo de Movimentação Real (Posicionamento Estratégico)
var _move_target = ai_get_movement_target(id, _target, _player_inst, _is_ally);
var _move_x = _move_target.x;
var _move_y = _move_target.y;
if (_move_target.aggro != undefined) {
    _final_aggro = _move_target.aggro;
}

// Cooldown
if (attack_cooldown > 0) attack_cooldown--;

// Se estiver congelado pelo debug, sai
if (debug_freeze) exit;

switch (state) {
    case MO_STATE.IDLE:
        var _d_to_move = point_distance(x, y, _move_x, _move_y);
        if (_d_to_move > _final_aggro) state = MO_STATE.CHASE;
        break;

    case MO_STATE.CHASE:
        var _chosen = undefined;
        
        // Aliados nunca atacam o mestre
        var _can_attack = true;
        if (_is_ally && _target.object_index == obj_jogador) _can_attack = false;
        
        if (_can_attack) {
            // Distância para o alvo do ataque real (_target) e não _move_x
            var _dist_to_enemy = point_distance(x, y, _target.x, _target.y);
            if (attack_cooldown <= 0 && _dist_to_enemy <= special_atk.range) {
                _chosen = special_atk;
            } else if (attack_cooldown <= 0 && _dist_to_enemy <= basic_atk.range) {
                _chosen = basic_atk;
            }
        }
        
        if (_chosen != undefined) {
            if (_chosen.shape == "self" || _chosen.shape == "area") {
                if (_dist_to_enemy <= 150) { 
                    current_attack = _chosen;
                    state = MO_STATE.CHANNELING;
                    channel_timer = _chosen.channel_time;
                    target_x = _target.x;
                    target_y = _target.y;
                } else {
                    mp_potential_step(_move_x, _move_y, _final_spd, false);
                }
            } else {
                current_attack = _chosen;
                state = MO_STATE.CHANNELING;
                channel_timer = _chosen.channel_time;
                target_x = _target.x;
                target_y = _target.y;
            }
        } 
        else {
            // Movimentação
            var _d_to_move = point_distance(x, y, _move_x, _move_y);
            
            if (_is_ally && _target.object_index == obj_jogador && _d_to_move < 50) {
                // Chegou no mestre, fica IDLE
                state = MO_STATE.IDLE;
            } else {
                if (!_is_ally && _dist > _final_aggro * 1.5) state = MO_STATE.IDLE;
                else mp_potential_step(_move_x, _move_y, _final_spd, false);
            }
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
        
        // Define alvo do projétil baseado em se é aliado ou não
        if (_is_ally) _s.target_type = obj_monster; // Aliados batem em monstros inimigos
        else {
            // Inimigo bate em quem ele focou (player ou aliado)
            _s.target_type = _target.object_index;
        }
        
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