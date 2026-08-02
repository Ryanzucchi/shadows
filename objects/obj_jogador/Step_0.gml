/// @description Lógica Principal + DEBUG

// --- Regeneração de Mana ---
mana = min(max_mana, mana + mana_regen);

// =========================================================
// 1. CAPTURA DE INPUTS (TECLADO / MOUSE / GAMEPAD)
// =========================================================
var _xaxis = 0;
var _yaxis = 0;
var _key_right = keyboard_check(vk_right) or keyboard_check(ord("D"));
var _key_left  = keyboard_check(vk_left) or keyboard_check(ord("A"));
var _key_up    = keyboard_check(vk_up) or keyboard_check(ord("W"));
var _key_down  = keyboard_check(vk_down) or keyboard_check(ord("S"));
var _key_dash  = keyboard_check_pressed(vk_space) or keyboard_check_pressed(ord("K"));
var _key_run   = keyboard_check(vk_shift); 

var _key_attack = mouse_check_button_pressed(mb_left);
var _key_capture = keyboard_check_pressed(ord("C")) or mouse_check_button_pressed(mb_right);
var _key_lockon = keyboard_check_pressed(ord("R")) or mouse_check_button_pressed(mb_middle);
var _key_special_menu = keyboard_check(ord("E")) or keyboard_check(vk_tab);
var _aim_dir = point_direction(x, y, mouse_x, mouse_y);

_xaxis = _key_right - _key_left;
_yaxis = _key_down - _key_up;

if (gamepad_is_connected(0)) {
    var _gp_h = gamepad_axis_value(0, gp_axislh);
    var _gp_v = gamepad_axis_value(0, gp_axislv);
    if (abs(_gp_h) > 0.2 || abs(_gp_v) > 0.2) {
        _xaxis = _gp_h;
        _yaxis = _gp_v;
    }
    
    // Correr via LT (Gatilho Esquerdo)
    var _lt_val = gamepad_button_value(0, gp_shoulderlb);
    if (_lt_val > 0.2 || gamepad_button_check(0, gp_shoulderlb)) _key_run = true;
    
    // Mira pelo Analógico Direito
    var _gp_rh = gamepad_axis_value(0, gp_axisrh);
    var _gp_rv = gamepad_axis_value(0, gp_axisrv);
    if (abs(_gp_rh) > 0.2 || abs(_gp_rv) > 0.2) {
        _aim_dir = point_direction(0, 0, _gp_rh, _gp_rv);
    } else if (_xaxis != 0 || _yaxis != 0) {
        _aim_dir = dir;
    }
    
    if (gamepad_button_check_pressed(0, gp_face1)) _key_dash = true;       // A = Dash
    if (gamepad_button_check_pressed(0, gp_face4)) _key_capture = true;    // Y = Capturar Inimigo
    if (gamepad_button_check_pressed(0, gp_stickr)) _key_lockon = true;    // R3 (Clicar Analógico Direito) = Lock-on Inimigo
    if (gamepad_button_check_pressed(0, gp_shoulderrb) || gamepad_button_check_pressed(0, gp_shoulderr)) _key_attack = true; // RT/R2 = Disparar Magia
    if (gamepad_button_check(0, gp_shoulderl)) _key_special_menu = true; // LB = Menu Especiais
}

// --- LÓGICA DE LOCK-ON ---
if (_key_lockon) {
    if (lockon_target != noone) {
        lockon_target = noone; // Destrava se já houver um alvo
    } else {
        // Busca inimigo mais próximo
        var _cand = noone;
        var _min_d = 450;
        with (obj_monster) {
            if (!variable_instance_exists(id, "is_ally") || !is_ally) {
                var _d = point_distance(other.x, other.y, x, y);
                if (_d < _min_d) { _min_d = _d; _cand = id; }
            }
        }
        if (_cand == noone) {
            var _orc = instance_nearest(x, y, obj_orc_teste);
            if (_orc != noone && point_distance(x, y, _orc.x, _orc.y) < 450) _cand = _orc;
        }
        lockon_target = _cand;
    }
}

// Validação do Lock-on
if (lockon_target != noone) {
    if (!instance_exists(lockon_target) || point_distance(x, y, lockon_target.x, lockon_target.y) > 500) {
        lockon_target = noone;
    } else {
        _aim_dir = point_direction(x, y, lockon_target.x, lockon_target.y);
    }
}

// =========================================================
// 2. STATE MACHINE (MOVIMENTAÇÃO)
// =========================================================

switch (state) {
    case "IDLE":
        hspd = 0;
        vspd = 0;
        image_speed = 1;
        sprite_index = sprite_idle[face];
        
        // Transições de Movimento
        if (_xaxis != 0 || _yaxis != 0) {
            if (_key_run) {
                state = "RUN";
            } else {
                state = "WALK";
            }
        }
        
        if (_key_dash) {
            state = "DASH";
            dir = face * 45; 
            image_index = 0;
            var _dust = instance_create_layer(x, y + 5, "Instances", obj_dash_dust);
            _dust.face = face; 
        }
    break;

    case "WALK":
        dir = point_direction(0, 0, _xaxis, _yaxis);
        // Atualiza Face
        if (_xaxis != 0 || _yaxis != 0) {
            face = round(dir / 45);
            if (face == 8) face = 0;
        }

        // Transição para RUN
        if (_key_run) state = "RUN";
        
        // Movimento
        hspd = lengthdir_x(spd_walk, dir);
        vspd = lengthdir_y(spd_walk, dir);
        
        // Colisão e Movimento
        move_and_collide(hspd, vspd, obj_parede);
        
        sprite_index = sprite_walk[face];
        image_speed = 1.0;
        
        if (_xaxis == 0 && _yaxis == 0) state = "IDLE";
        
        if (_key_dash) {
            state = "DASH";
            image_index = 0;
            var _dust = instance_create_layer(x, y + 5, "Instances", obj_dash_dust);
            _dust.face = face; 
        }
    break;

    case "RUN":
        dir = point_direction(0, 0, _xaxis, _yaxis);
        // Atualiza Face
        if (_xaxis != 0 || _yaxis != 0) {
            face = round(dir / 45);
            if (face == 8) face = 0;
        }

        // Transição para WALK
        if (!_key_run) state = "WALK";
        
        // Movimento Rápido
        hspd = lengthdir_x(spd_run, dir);
        vspd = lengthdir_y(spd_run, dir);
        
        // Colisão e Movimento
        move_and_collide(hspd, vspd, obj_parede);
        
        sprite_index = sprite_walk[face]; 
        image_speed = 2.0;
        
        if (_xaxis == 0 && _yaxis == 0) state = "IDLE";
        
        if (_key_dash) {
            state = "DASH";
            image_index = 0;
            var _dust = instance_create_layer(x, y + 5, "Instances", obj_dash_dust);
            _dust.face = face; 
        }
    break;

    case "DASH":
        image_speed = 3.0;
        hspd = lengthdir_x(dash_spd, dir);
        vspd = lengthdir_y(dash_spd, dir);
        
        // Colisão e Movimento
        move_and_collide(hspd, vspd, obj_parede);
        
        sprite_index = sprite_dash[face];
        
        if (image_index >= image_number - 1) state = "IDLE"; 
    break;

    case "DEAD":
        sprite_index = sprite_death[face];
        if (image_index >= image_number - 1) {
            image_speed = 0;
            image_index = image_number - 1;
        }
    break;
}

// Ordenação de profundidade (Depth Sorting)
depth = -bbox_bottom;

// Checagem de Morte
if (hp <= 0 && state != "DEAD") {
    state = "DEAD"; 
    image_index = 0;
    hspd = 0;
    vspd = 0;
}

// ... (seu código de movimento anterior continua igual) ...

// =========================================================
// 3. SISTEMA DE COMBATE DO JOGADOR (MAGIA DO TOMO + MANA)
// =========================================================
var _spell = variable_global_exists("equipped_spell") ? global.equipped_spell : global.spell_database.faisca;
var _spell_cost = _spell.mana_cost;

if (_key_attack && mana >= _spell_cost) {
    mana -= _spell_cost;
    
    var _ataque_escolhido = _spell.attack;
    var _proj = instance_create_layer(x, y, "Instances", obj_skillshot);
    
    _proj.attack_data = _ataque_escolhido;
    _proj.owner = id;
    _proj.target_type = obj_monster; // Jogador acerta monstros
    
    _proj.direction = _aim_dir;
    _proj.image_angle = _aim_dir;
    
    _proj.velocity_x = lengthdir_x(_ataque_escolhido.proj_speed, _aim_dir);
    _proj.velocity_y = lengthdir_y(_ataque_escolhido.proj_speed, _aim_dir);
}

// =========================================================
// 3.5 COMANDO DE ESPECIAL DO MONSTRO SELECIONADO (V / RB)
// =========================================================
var _key_monster_special = keyboard_check_pressed(ord("V")) || (gamepad_is_connected(0) && gamepad_button_check_pressed(0, gp_shoulderrb));

if (_key_monster_special && array_length(global.party) > 0) {
    selected_party_index = clamp(selected_party_index, 0, array_length(global.party) - 1);
    var _m_data = global.party[selected_party_index];
    
    if (variable_struct_exists(_m_data, "is_summoned") && _m_data.is_summoned && instance_exists(_m_data.summon_id)) {
        var _mon_inst = _m_data.summon_id;
        
        _mon_inst.current_attack = _m_data.special_atk;
        _mon_inst.target_x = x + lengthdir_x(_m_data.special_atk.range, _aim_dir);
        _mon_inst.target_y = y + lengthdir_y(_m_data.special_atk.range, _aim_dir);
        _mon_inst.state = MO_STATE.ATTACKING;
        
        show_debug_message("💥 COMANDOU ATAQUE ESPECIAL: " + _m_data.name + " -> " + _m_data.special_atk.name);
    }
}

// =========================================================
// 4. SISTEMA DE CAPTURA (C / MOUSE RIGHT / BOTÃO Y)
// =========================================================
if (_key_capture) {
    var _nearest = lockon_target;
    if (_nearest == noone || !instance_exists(_nearest)) {
        _nearest = collision_circle(x, y, 350, obj_monster, false, true);
        if (_nearest == noone) {
            _nearest = collision_circle(x, y, 350, obj_orc_teste, false, true);
        }
    }
    
    if (_nearest != noone && instance_exists(_nearest)) {
        var _proj = instance_create_layer(x, y, "Instances", obj_skillshot);
        
        var _cap_data = {
            name: "Orbe de Captura",
            element: "sombra",
            damage: 0,
            shape: "circle",
            range: 350,
            proj_speed: 6,
            color: c_fuchsia,
            width: 15,
            effect: "capture"
        };
        
        _proj.attack_data = _cap_data;
        _proj.owner = id;
        _proj.target_type = _nearest.object_index;
        
        var _dir = point_direction(x, y, _nearest.x, _nearest.y);
        _proj.direction = _dir;
        _proj.image_angle = _dir;
        _proj.velocity_x = lengthdir_x(_cap_data.proj_speed, _dir);
        _proj.velocity_y = lengthdir_y(_cap_data.proj_speed, _dir);
    }
}

// =========================================================
// 5. NAVEGAÇÃO E INVOCAÇÃO DE FRASCOS/MONSTROS (D-Pad + LB)
// =========================================================
if (!global.capture_pending && array_length(global.party) > 0) {
    // 1. Navegação entre os Frascos (D-Pad Esquerda/Direita ou Q/E ou Scroll)
    var _nav_left = keyboard_check_pressed(ord("Q")) || mouse_wheel_up();
    var _nav_right = keyboard_check_pressed(ord("E")) || mouse_wheel_down();
    var _key_summon = keyboard_check_pressed(ord("F"));
    
    if (gamepad_is_connected(0)) {
        if (gamepad_button_check_pressed(0, gp_padl)) _nav_left = true;
        if (gamepad_button_check_pressed(0, gp_padr)) _nav_right = true;
        if (gamepad_button_check_pressed(0, gp_shoulderl)) _key_summon = true; // LB para Invocar/Recolher frasco selecionado
    }
    
    if (_nav_left) {
        selected_party_index--;
        if (selected_party_index < 0) selected_party_index = array_length(global.party) - 1;
    }
    if (_nav_right) {
        selected_party_index++;
        if (selected_party_index >= array_length(global.party)) selected_party_index = 0;
    }
    
    // Atalho numérico direto (1 a 6) no teclado
    for (var i = 1; i <= 6; i++) {
        if (keyboard_check_pressed(ord(string(i))) || keyboard_check_pressed(vk_numpad0 + i)) {
            var _num_idx = i - 1;
            if (_num_idx < array_length(global.party)) {
                selected_party_index = _num_idx;
                _key_summon = true;
            }
        }
    }
    
    selected_party_index = clamp(selected_party_index, 0, array_length(global.party) - 1);
    
    // Executa a Invocação ou Recolhimento do Frasco Selecionado
    if (_key_summon) {
        var _m_data = global.party[selected_party_index];
        
        if (!variable_struct_exists(_m_data, "is_summoned")) _m_data.is_summoned = false;
        if (!variable_struct_exists(_m_data, "summon_id")) _m_data.summon_id = noone;
        
        if (_m_data.is_summoned) {
            // Recolhe
            if (instance_exists(_m_data.summon_id)) {
                instance_destroy(_m_data.summon_id);
            }
            _m_data.is_summoned = false;
            _m_data.summon_id = noone;
            show_debug_message("Recolheu frasco " + string(selected_party_index + 1) + ": " + _m_data.name);
        } else {
            // Invoca
            var _spawn_x = x + random_range(-40, 40);
            var _spawn_y = y + random_range(-40, 40);
            var _inst = instance_create_layer(_spawn_x, _spawn_y, "Instances", obj_monster);
            
            _inst.monster_data = _m_data;
            _inst.hp = _m_data.hp;
            _inst.max_hp = _m_data.max_hp;
            _inst.spd = _m_data.spd;
            _inst.type_1 = _m_data.element;
            _inst.basic_atk = _m_data.basic_atk;
            _inst.special_atk = _m_data.special_atk;
            
            _inst.is_ally = true;
            _m_data.is_summoned = true;
            _m_data.summon_id = _inst;
            
            if (!variable_struct_exists(_m_data, "mood")) _m_data.mood = "Calmo";
            if (!variable_struct_exists(_m_data, "personality")) _m_data.personality = "Leal";
            
            show_debug_message("Invocou frasco " + string(selected_party_index + 1) + ": " + _m_data.name);
        }
    }
}

// =========================================================
// 5. TESTE DE ESCOLHA (Simulação de UI da Party)
// =========================================================
if (global.capture_pending) {
    // Simula botões (1 para Party Perigosa, 2 para Box)
    if (keyboard_check_pressed(ord("1"))) {
        party_add_dangerous(global.capture_pending_monster);
        global.capture_pending = false;
        global.capture_pending_monster = undefined;
    } else if (keyboard_check_pressed(ord("2"))) {
        box_add_monster(global.capture_pending_monster);
        global.capture_pending = false;
        global.capture_pending_monster = undefined;
    }
}

// =========================================================
// 6. SISTEMA DE REBELIÃO (PARTY PERIGOSA)
// =========================================================
// Se tivermos mais monstros do que o nosso nível, há chance de rebelião ao andar.
if (array_length(global.party) > global.player_level && (hspd != 0 || vspd != 0)) {
    // Uma chance bem pequena por frame (ex: 1 em 10000)
    if (irandom(10000) == 1) {
        show_debug_message("!!! UM MONSTRO SE REBELOU DA SUA PARTY PERIGOSA !!!");
        var _rebel_idx = irandom(array_length(global.party) - 1);
        var _rebel_data = global.party[_rebel_idx];
        
        // Remove da party
        array_delete(global.party, _rebel_idx, 1);
        
        // Cria ele no mapa inimigo
        var _inst = instance_create_layer(x + irandom_range(-50, 50), y + irandom_range(-50, 50), "Instances", obj_monster);
        _inst.monster_data = _rebel_data;
    }
}