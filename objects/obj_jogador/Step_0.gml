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
        
        // Colisão Horizontal
        if (place_meeting(x + hspd, y, obj_parede)) {
            while (!place_meeting(x + sign(hspd), y, obj_parede)) x += sign(hspd);
            hspd = 0;
        }
        x += hspd;
        
        // Colisão Vertical
        if (place_meeting(x, y + vspd, obj_parede)) {
            while (!place_meeting(x, y + sign(vspd), obj_parede)) y += sign(vspd);
            vspd = 0;
        }
        y += vspd;
        
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
        
        // Colisões
        if (place_meeting(x + hspd, y, obj_parede)) {
            while (!place_meeting(x + sign(hspd), y, obj_parede)) x += sign(hspd);
            hspd = 0;
        }
        x += hspd;
        
        if (place_meeting(x, y + vspd, obj_parede)) {
            while (!place_meeting(x, y + sign(vspd), obj_parede)) y += sign(vspd);
            vspd = 0;
        }
        y += vspd;
        
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
        
        if (place_meeting(x + hspd, y, obj_parede)) hspd = 0;
        if (place_meeting(x, y + vspd, obj_parede)) vspd = 0;
        
        x += hspd;
        y += vspd;
        
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