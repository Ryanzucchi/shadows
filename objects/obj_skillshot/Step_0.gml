// Verifica se os dados existem, senão destrói para evitar erro
if (is_undefined(move_data)) { 
    instance_destroy(); 
    exit; 
}

lifetime++;

// --- Lógica de Movimento ---
var _spd = move_data.spd;
var _dir = dir;

if (move_data.shape == "linear" || move_data.shape == "cone") {
    x += lengthdir_x(_spd, _dir);
    y += lengthdir_y(_spd, _dir);
    
    // Destruir se bater na parede (apenas skillshots lineares)
    if (place_meeting(x, y, obj_parede)) {
        instance_destroy();
        exit;
    }
}

// --- Lógica de Colisão (Dano) ---
var _radius = 10; // Raio padrão para projétil linear
if (move_data.shape != "linear") {
    _radius = move_data.range; // Raio do golpe em área
}

var _list = ds_list_create();

// Tenta executar a colisão. 
// Se der erro de argumentos aqui, tente remover o último ', false' (o argumento ordered).
// Padrão GMS2 atual: 8 argumentos.
collision_circle_list(x, y, _radius, obj_jogador, false, true, _list, false);

var _num_hits = ds_list_size(_list);

if (_num_hits > 0 && instance_exists(owner)) {
    // Garante que não é friendly fire (dono batendo nele mesmo)
    if (owner.object_index != obj_jogador) {
        for (var i = 0; i < _num_hits; i++) {
            var _hit_instance = _list[| i];
            
            // Verifica se a instância atingida ainda existe
            if (instance_exists(_hit_instance)) {
                // APLICAR DANO AQUI
                // Exemplo: _hit_instance.hp -= move_data.base_power;
                // show_debug_message("Atingiu o jogador com: " + move_data.name);
            }
            
            // Se for linear, o projétil some no primeiro impacto
            if (move_data.shape == "linear") {
                instance_destroy();
                break; 
            }
        }
    }
}

// Limpa a memória da lista (Essencial!)
ds_list_destroy(_list);

// Destroi o objeto se o tempo de vida acabar
if (lifetime > max_lifetime) instance_destroy();