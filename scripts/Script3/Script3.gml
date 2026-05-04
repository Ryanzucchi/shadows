// ==============================================================================
// SISTEMA DE INTELIGÊNCIA ARTIFICIAL (IA) DOS MONSTROS
// Centraliza rotinas de combate, movimentação e personalidade
// ==============================================================================

/**
 * @function ai_find_target(is_ally, my_id)
 * @description Procura o melhor alvo dependendo de quem o monstro é (Aliado vs Inimigo)
 */
function ai_find_target(_is_ally, _my_id) {
    var _target = noone;
    var _player_inst = instance_nearest(_my_id.x, _my_id.y, obj_jogador);

    if (_is_ally) {
        var _min_d = 999999;
        with (obj_monster) {
            if (id != _my_id && (!variable_instance_exists(id, "is_ally") || !is_ally)) {
                var _d = point_distance(x, y, _my_id.x, _my_id.y);
                if (_d < _min_d) { _min_d = _d; _target = id; }
            }
        }
        if (_target == noone || _min_d > 600) {
            _target = _player_inst;
        }
    } else {
        _target = _player_inst;
        var _min_d = point_distance(_my_id.x, _my_id.y, _target.x, _target.y);
        with (obj_monster) {
            if (id != _my_id && variable_instance_exists(id, "is_ally") && is_ally) {
                var _d = point_distance(x, y, _my_id.x, _my_id.y);
                if (_d < _min_d) { _min_d = _d; _target = id; }
            }
        }
    }
    return _target;
}

/**
 * @function ai_apply_modifiers(inst, base_spd, base_aggro)
 * @description Retorna struct com a velocidade final e aggro final baseado no humor e personalidade
 */
function ai_apply_modifiers(_inst, _base_spd, _base_aggro) {
    var _spd = _base_spd;
    var _aggro = _base_aggro;
    
    if (variable_instance_exists(_inst, "monster_data") && _inst.monster_data != undefined) {
        var _mood = _inst.monster_data.mood;
        var _pers = _inst.monster_data.personality;
        
        // Humor
        if (_mood == "Agressivo" || _mood == "Irritado" || _mood == "Eufórico") { _spd *= 1.2; _aggro *= 1.5; }
        else if (_mood == "Preguiçoso" || _mood == "Cansado" || _mood == "Triste") { _spd *= 0.7; _aggro *= 0.8; }
        else if (_mood == "Medroso" || _mood == "Ansioso") { _spd *= 1.5; _aggro *= 0.4; }
        
        // Personalidade
        if (_pers == "Corajoso" || _pers == "Feroz" || _pers == "Caçador") { _aggro *= 2.0; }
        else if (_pers == "Covarde" || _pers == "Tímido") { _aggro *= 0.5; }
    }
    
    return { final_spd: _spd, final_aggro: _aggro };
}

/**
 * @function ai_get_movement_target(inst, target, player_inst, is_ally)
 * @description Calcula para onde o monstro vai tentar andar (X, Y e Aggro override)
 */
function ai_get_movement_target(_inst, _target, _player_inst, _is_ally) {
    var _move_x = _target.x;
    var _move_y = _target.y;
    var _aggro_override = undefined;
    
    var _pers = "Leal";
    if (variable_instance_exists(_inst, "monster_data") && _inst.monster_data != undefined) {
        _pers = _inst.monster_data.personality;
    }
    
    if (_is_ally) {
        var _p_face = variable_instance_exists(_player_inst, "face") ? _player_inst.face * 45 : 0;
        
        if (_target == _player_inst) {
            // MODO PACÍFICO
            _aggro_override = 60;
            if (_pers == "Tímido" || _pers == "Covarde" || _pers == "Ansioso") {
                _move_x = _player_inst.x - lengthdir_x(60, _p_face);
                _move_y = _player_inst.y - lengthdir_y(60, _p_face);
            } else if (_pers == "Protetor" || _pers == "Corajoso") {
                _move_x = _player_inst.x + lengthdir_x(40, _p_face + 45);
                _move_y = _player_inst.y + lengthdir_y(40, _p_face + 45);
            } else {
                _move_x = _player_inst.x - lengthdir_x(50, _p_face + 180);
                _move_y = _player_inst.y - lengthdir_y(50, _p_face + 180);
            }
        } else {
            // MODO COMBATE
            if (_pers == "Tímido" || _pers == "Covarde") {
                var _e_dist = point_distance(_target.x, _target.y, _player_inst.x, _player_inst.y);
                if (_e_dist > 200) {
                    _move_x = _player_inst.x - lengthdir_x(50, _p_face);
                    _move_y = _player_inst.y - lengthdir_y(50, _p_face);
                } else {
                    var _safe_d = max(_inst.basic_atk.range, _inst.special_atk.range) * 0.8;
                    var _dir_away = point_direction(_target.x, _target.y, _inst.x, _inst.y);
                    _move_x = _target.x + lengthdir_x(_safe_d, _dir_away);
                    _move_y = _target.y + lengthdir_y(_safe_d, _dir_away);
                }
            } else if (_pers == "Protetor") {
                var _dir_pe = point_direction(_player_inst.x, _player_inst.y, _target.x, _target.y);
                _move_x = _player_inst.x + lengthdir_x(60, _dir_pe);
                _move_y = _player_inst.y + lengthdir_y(60, _dir_pe);
            }
        }
    }
    
    return { x: _move_x, y: _move_y, aggro: _aggro_override };
}