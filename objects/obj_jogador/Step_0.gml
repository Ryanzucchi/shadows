/// @description Lógica Principal + DEBUG

// =========================================================
// 1. CAPTURA DE INPUTS
// =========================================================
var _xaxis = 0;
var _yaxis = 0;
var _key_right = keyboard_check(vk_right) or keyboard_check(ord("D"));
var _key_left  = keyboard_check(vk_left) or keyboard_check(ord("A"));
var _key_up    = keyboard_check(vk_up) or keyboard_check(ord("W"));
var _key_down  = keyboard_check(vk_down) or keyboard_check(ord("S"));
var _key_dash  = keyboard_check_pressed(vk_space) or keyboard_check_pressed(ord("K"));
var _key_run   = keyboard_check(vk_shift); 

_xaxis = _key_right - _key_left;
_yaxis = _key_down - _key_up;

if (gamepad_is_connected(0)) {
    var _gp_h = gamepad_axis_value(0, gp_axislh);
    var _gp_v = gamepad_axis_value(0, gp_axislv);
    if (abs(_gp_h) > 0.2 || abs(_gp_v) > 0.2) {
        _xaxis = _gp_h;
        _yaxis = _gp_v;
    }
    if (gamepad_button_check_pressed(0, gp_face1)) _key_dash = true;
    if (gamepad_button_check(0, gp_face3)) _key_run = true;
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
// 3. SISTEMA DE COMBATE DO JOGADOR (ATUALIZADO)
// =========================================================
if (mouse_check_button_pressed(mb_left)) {
    
    // 1. Acessa o banco de dados do tipo FOGO
    var _db_player = global.attack_database.fogo;
    
    // 2. Escolhe um ataque da lista de BÁSICOS (basics)
    // Índice 0 = Faísca, Índice 1 = Brasa
    var _ataque_escolhido = _db_player.basics[0]; 
    
    // 3. Cria o Projétil
    var _proj = instance_create_layer(x, y, "Instances", obj_skillshot);
    
    // 4. Configura os dados
    _proj.attack_data = _ataque_escolhido;
    _proj.owner = id;
    _proj.target_type = obj_monster; // Jogador acerta monstros
    
    // 5. Direção e Velocidade
    var _dir = point_direction(x, y, mouse_x, mouse_y);
    _proj.direction = _dir;
    _proj.image_angle = _dir;
    
    _proj.velocity_x = lengthdir_x(_ataque_escolhido.proj_speed, _dir);
    _proj.velocity_y = lengthdir_y(_ataque_escolhido.proj_speed, _dir);
}

// =========================================================
// 4. SISTEMA DE CAPTURA
// =========================================================
if (keyboard_check_pressed(ord("C"))) {
    // Acha o monstro mais próximo num raio grande (300 pixels) para atirar
    var _nearest = collision_circle(x, y, 300, obj_monster, false, true);
    if (_nearest == noone) {
        _nearest = collision_circle(x, y, 300, obj_orc_teste, false, true);
    }
    
    if (_nearest != noone) {
        // Atira uma orbe visual usando obj_skillshot
        var _proj = instance_create_layer(x, y, "Instances", obj_skillshot);
        
        var _cap_data = {
            name: "Orbe de Captura",
            element: "sombra", // Usa a estética de sombra (roxo)
            damage: 0,
            shape: "circle",
            range: 350,
            proj_speed: 6,
            color: c_fuchsia,
            width: 15,
            effect: "capture" // Novo efeito de captura!
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
// 5. INVOCAR / RECOLHER MONSTROS (Teclas 1 a 6)
// =========================================================
if (!global.capture_pending) {
    for (var i = 1; i <= 6; i++) {
        // Verifica tanto o número acima das letras quanto o numpad
        var _key_pressed = keyboard_check_pressed(ord(string(i))) || keyboard_check_pressed(vk_numpad0 + i);
        
        if (_key_pressed) {
            var _idx = i - 1;
            if (_idx < array_length(global.party)) {
                var _m_data = global.party[_idx];
                
                // Garantia de segurança (caso o monstro seja antigo no save)
                if (!variable_struct_exists(_m_data, "is_summoned")) _m_data.is_summoned = false;
                if (!variable_struct_exists(_m_data, "summon_id")) _m_data.summon_id = noone;
                
                if (_m_data.is_summoned) {
                    // Recolhe
                    if (instance_exists(_m_data.summon_id)) {
                        instance_destroy(_m_data.summon_id);
                    }
                    _m_data.is_summoned = false;
                    _m_data.summon_id = noone;
                    show_debug_message("Recolheu: " + _m_data.name);
                } else {
                    // Invoca
                    var _spawn_x = x + random_range(-40, 40);
                    var _spawn_y = y + random_range(-40, 40);
                    var _inst = instance_create_layer(_spawn_x, _spawn_y, "Instances", obj_monster);
                    
                    // Vincula os dados
                    _inst.monster_data = _m_data;
                    _inst.hp = _m_data.hp;
                    _inst.max_hp = _m_data.max_hp;
                    _inst.spd = _m_data.spd;
                    _inst.type_1 = _m_data.element;
                    _inst.basic_atk = _m_data.basic_atk;
                    _inst.special_atk = _m_data.special_atk;
                    
                    // Flags de Aliado
                    _inst.is_ally = true;
                    _m_data.is_summoned = true;
                    _m_data.summon_id = _inst;
                    
                    // Garantia para IA (antigos)
                    if (!variable_struct_exists(_m_data, "mood")) _m_data.mood = "Calmo";
                    if (!variable_struct_exists(_m_data, "personality")) _m_data.personality = "Leal";
                    
                    show_debug_message("Invocou: " + _m_data.name + " (" + _m_data.mood + " / " + _m_data.personality + ")");
                }
            }
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