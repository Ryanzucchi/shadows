if (attack_data == undefined) { instance_destroy(); exit; }

// --- EFEITO VISUAL DE TEXTO PÓS-CAPTURA ---
if (variable_instance_exists(id, "is_capture_result") && is_capture_result) {
    life_timer++;
    y -= 0.5; // Texto sobe flutuando
    if (life_timer > 60) instance_destroy(); // Some após 1 segundo
    exit; // Ignora resto da lógica de projétil
}
// --- Comportamento por Forma ---

// 1. Projéteis Móveis (Circle/Line que se movem)
if (attack_data.shape == "circle" || attack_data.shape == "line") {
    // Se for 'line' mas com velocidade 0 (Parede), não move
    if (attack_data.proj_speed > 0) {
        x += lengthdir_x(attack_data.proj_speed, direction);
        y += lengthdir_y(attack_data.proj_speed, direction);
        dist_traveled += attack_data.proj_speed;
        
        if (dist_traveled >= attack_data.range) instance_destroy();
    } else {
        // Parede estática
        life_timer++;
        if (life_timer > 120) instance_destroy(); // Dura 2 seg
    }
}

// 2. Ataques Estáticos (Area / Self / Cone instantâneo)
if (attack_data.shape == "area" || attack_data.shape == "self" || attack_data.shape == "cone") {
    life_timer++;
    // Duração visual do efeito
    if (life_timer > 30) instance_destroy(); 
}

// --- Colisão e Dano ---
var _hit_now = false;
var _victims = ds_list_create();
var _count = 0;

// A. Colisão Circular (Circle, Area, Self)
if (attack_data.shape == "circle" || attack_data.shape == "area" || attack_data.shape == "self") {
    _count = collision_circle_list(x, y, attack_data.width, target_type, false, true, _victims, false);
}
// B. Colisão Retangular Rotacionada (Line)
else if (attack_data.shape == "line") {
    // Simplificação: Line como vários círculos ou collision_line (fino)
    // Para 'width' grosso, ideal é checar colisão retangular. 
    // Vamos usar collision_line com largura simulada
    _count = collision_circle_list(x, y, attack_data.width, target_type, false, true, _victims, false); 
    // (Simplificado para este exemplo, ideal seria collision_rectangle rotacionado)
}
// C. Colisão Cone (Triângulo)
else if (attack_data.shape == "cone") {
    var _len = attack_data.range;
    var _w = attack_data.width; // Ângulo
    var _ang = image_angle;
    
    // Pega candidatos no raio
    var _candidates = ds_list_create();
    var _c_count = collision_circle_list(x, y, _len, target_type, false, true, _candidates, false);
    
    // Filtra quem está no ângulo
    for (var i = 0; i < _c_count; i++) {
        var _inst = _candidates[| i];
        var _dir_to = point_direction(x, y, _inst.x, _inst.y);
        if (abs(angle_difference(_dir_to, _ang)) < _w / 2) {
            ds_list_add(_victims, _inst);
        }
    }
    ds_list_destroy(_candidates);
    _count = ds_list_size(_victims);
}

// --- Aplica Dano ---
for (var i = 0; i < _count; i++) {
    var _vic = _victims[| i];
    
    // Verifica se já atingiu este alvo
    if (ds_list_find_index(hit_list, _vic) == -1) {
        if (variable_instance_exists(_vic, "hp")) {
            
            // --- IGNORAR FOGO AMIGO ---
            var _owner_is_ally = false;
            if (instance_exists(owner)) {
                if (owner.object_index == obj_jogador) _owner_is_ally = true;
                else if (variable_instance_exists(owner, "is_ally") && owner.is_ally) _owner_is_ally = true;
            }
            
            var _vic_is_ally = false;
            if (_vic.object_index == obj_jogador) _vic_is_ally = true;
            else if (variable_instance_exists(_vic, "is_ally") && _vic.is_ally) _vic_is_ally = true;
            
            if (owner != _vic && _owner_is_ally == _vic_is_ally) {
                continue; // Aliado não bate em aliado, inimigo não bate em inimigo
            }
            // --------------------------
            
            // Cálculo de Elemento
            var _def_type = variable_instance_exists(_vic, "type_1") ? _vic.type_1 : "normal";
            var _mult = get_type_effectiveness(attack_data.element, _def_type);
            
            var _dmg = attack_data.damage * _mult;
            _vic.hp -= _dmg;
            
            // Efeitos Especiais
            if (attack_data.effect == "push") {
                var _push_dir = point_direction(x, y, _vic.x, _vic.y);
                _vic.x += lengthdir_x(20, _push_dir); // Empurrão simples
                _vic.y += lengthdir_y(20, _push_dir);
            }
            if (attack_data.effect == "stun") {
                // Implementar lógica de stun no objeto jogador/monstro se quiser
            }
            if (attack_data.effect == "capture") {
                // Roda a matemática da captura e recebe true/false
                var _cap_result = capture_logic(_vic);
                
                // Transforma o projétil num texto flutuante
                is_capture_result = true;
                capture_msg = _cap_result ? "CAPTURADO!" : "ESCAPOU!";
                capture_color = _cap_result ? c_lime : c_red;
                
                speed = 0;
                direction = 0;
                attack_data.proj_speed = 0; // Para parar totalmente
                life_timer = 0; // Reinicia para controlar sumiço do texto
                break; // Sai do loop
            }
            
            ds_list_add(hit_list, _vic);
            
            // Se não for perfurante ("pierce") nem área persistente, destroi ao bater
            if (attack_data.shape == "circle" && attack_data.effect != "pierce" && attack_data.effect != "capture") {
                instance_destroy();
                break; 
            }
        }
    }
}

ds_list_destroy(_victims);