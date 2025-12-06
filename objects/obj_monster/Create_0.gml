/// @description Configuração Base do Monstro

// --- 1. Atributos Padrão (Filhos podem mudar isso) ---
name = "Monstro Base";
hp_max = 100;
hp = hp_max;
spd = 2;            // Velocidade máxima
chase_spd = 2.5;    // Velocidade ao perseguir
xp_value = 10;      // Quanto de XP dá ao morrer

// --- 2. Tipos e Comportamento ---
types = [ELEMENT.NORMAL, -1]; // Array com 2 tipos (Enum ELEMENT)
behavior = BEHAVIOR.AGRESSIVO; // Enum BEHAVIOR (Passivo, Agressivo, etc)

// --- 3. Combate e Golpes ---
// Slot 0: Ataque Automático (Básico)
// Slot 1: Ataque Ativo (Especial)
moveset = array_create(2, undefined); 
move_cooldowns = array_create(2, 0);

// --- 4. Máquina de Estados e IA ---
state = "IDLE";     // Estados: IDLE, WANDER, CHASE, ATTACK, COOLDOWN, HIT, DEATH
state_timer = 0;    // Contador genérico para estados
target = noone;     // Alvo atual
aggro_range = 200;  // Distância para ver o inimigo
attack_range = 150; // Distância para começar a atacar
face_dir = 0;       // Direção que está olhando (0-360)

// --- 5. Sprites (Opcional: configura sprites dinamicamente) ---
spr_idle = sprite_index;
spr_walk = sprite_index;
spr_attack = sprite_index;
spr_death = spr_death_normal_down; // Exemplo de sprite genérico de morte

// --- 6. FUNÇÕES BASE (Métodos) ---

// Função: Receber Dano
take_damage = function(_amount, _type) {
    // Aqui entra cálculo de fraqueza/resistência futuramente
    // var _mult = global.effectiveness[# _type, types[0]];
    // _amount *= _mult;
    
    hp -= _amount;
    
    // Efeito visual de Hit
    image_blend = c_red;
    alarm[0] = 10; // Alarm para voltar a cor normal
    
    if (hp <= 0) {
        state = "DEATH";
        state_timer = 0;
    } else {
        // Se for passivo e tomou dano, vira agressivo contra quem bateu
        if (behavior == BEHAVIOR.PASSIVO) {
            state = "CHASE";
            target = instance_nearest(x, y, obj_jogador);
        }
    }
};

// Função: Checar se tem alguém perto (IA)
check_aggro = function() {
    target = noone;
    
    // Se estiver morto, ignora
    if (state == "DEATH") return;

    // Lógica para achar alvo
    var _player = instance_nearest(x, y, obj_jogador);
    
    if (_player != noone) {
        var _dist = point_distance(x, y, _player.x, _player.y);
        
        // Regras de Comportamento
        if (behavior == BEHAVIOR.PASSIVO) {
            // Não faz nada a menos que atacado (tratado no take_damage)
        }
        else if (behavior == BEHAVIOR.AGRESSIVO) {
            if (_dist < aggro_range) {
                target = _player;
                state = "CHASE";
            }
        }
        else if (behavior == BEHAVIOR.CACADOR) {
            // Visão muito maior
            if (_dist < aggro_range * 2.5) {
                target = _player;
                state = "CHASE";
            }
        }
    }
};

// Função: Realizar Ataque
perform_attack = function(_slot_index) {
    if (!instance_exists(target)) return;
    
    var _move = moveset[_slot_index];
    if (is_undefined(_move)) return; // Se não tiver golpe, sai
    
    var _dir = point_direction(x, y, target.x, target.y);
    
    // Cria o Skillshot (Projétil)
    var _inst = instance_create_layer(x, y, "Instances", obj_skillshot);
    _inst.owner = id;
    _inst.move_data = _move;
    _inst.dir = _dir;
    
    // Ajuste visual se for golpe de área
    if (_move.shape == "circle_aoe") {
        _inst.x = target.x;
        _inst.y = target.y;
    }
};