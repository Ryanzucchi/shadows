enum MO_STATE {
    IDLE,
    CHASE,
    CHANNELING,
    ATTACKING,
    COOLDOWN,
    HURT
}

function create_attack(_nome, _tipo, _dano, _cd, _chan, _forma, _range, _spd, _cor, _largura, _efeito) constructor {
    name = _nome;
    element = _tipo;
    damage = _dano;
    cooldown_max = _cd;      
    channel_time = _chan;
    shape = _forma; // "circle", "line", "cone", "area", "self"
    range = _range;
    proj_speed = _spd;
    color = _cor;
    width = _largura;
    effect = _efeito; // "none", "push", "pierce", "stun"
}

// --- 1. TABELA DE FRAQUEZAS ELEMENTAIS ---
function get_type_effectiveness(_atk, _def) {
    var _val = 1.0;
    
    switch(_atk) {
        case "fogo": 
            if (_def == "grama" || _def == "inseto" || _def == "metal") _val = 2.0;
            if (_def == "agua" || _def == "terra" || _def == "dragao") _val = 0.5;
            break;
        case "agua": 
            if (_def == "fogo" || _def == "terra" || _def == "metal") _val = 2.0;
            if (_def == "grama" || _def == "dragao") _val = 0.5;
            break;
        case "grama": 
            if (_def == "agua" || _def == "terra") _val = 2.0;
            if (_def == "fogo" || _def == "inseto" || _def == "metal" || _def == "dragao") _val = 0.5;
            break;
        case "terra": 
            if (_def == "fogo" || _def == "metal" || _def == "luz") _val = 2.0;
            if (_def == "grama" || _def == "inseto") _val = 0.5;
            break;
        case "metal": 
            if (_def == "luz" || _def == "terra" || _def == "grama") _val = 2.0;
            if (_def == "fogo" || _def == "agua" || _def == "metal") _val = 0.5;
            break;
        case "sombra": 
            if (_def == "luz" || _def == "normal") _val = 2.0;
            if (_def == "inseto") _val = 0.5;
            break;
        case "luz": 
            if (_def == "sombra" || _def == "dragao") _val = 2.0;
            if (_def == "metal" || _def == "grama") _val = 0.5;
            break;
        case "inseto": 
            if (_def == "grama" || _def == "sombra") _val = 2.0;
            if (_def == "fogo" || _def == "metal" || _def == "terra") _val = 0.5;
            break;
        case "dragao": 
            if (_def == "dragao") _val = 2.0;
            if (_def == "metal") _val = 0.5;
            break;
        case "normal":
            if (_def == "metal") _val = 0.5; // Normal bate fraco em metal
            break;
    }
    return _val;
}

// --- 2. BANCO DE DADOS COMPLETO (50 GOLPES) ---
global.attack_database = {
    fogo: {
        basics: [
            new create_attack("Faísca", "fogo", 5, 40, 10, "line", 250, 7, c_orange, 4, "none"),
            new create_attack("Brasa", "fogo", 8, 60, 15, "circle", 200, 5, c_red, 6, "none")
        ],
        specials: [
            new create_attack("Lança-Chamas", "fogo", 20, 300, 60, "cone", 220, 7, c_orange, 45, "pierce"),
            new create_attack("Explosão Solar", "fogo", 35, 400, 50, "area", 0, 0, c_yellow, 100, "push"),
            new create_attack("Parede de Fogo", "fogo", 15, 200, 30, "line", 300, 0, c_red, 20, "pierce") // Vel 0 = Parede
        ]
    },
    agua: {
        basics: [
            new create_attack("Bolha", "agua", 4, 30, 5, "circle", 220, 5, c_aqua, 5, "none"),
            new create_attack("Jato d'Água", "agua", 7, 50, 10, "line", 280, 9, c_blue, 5, "push")
        ],
        specials: [
            new create_attack("Hidro Bomba", "agua", 30, 350, 70, "line", 450, 12, c_navy, 15, "push"),
            new create_attack("Marejada", "agua", 25, 300, 60, "cone", 200, 5, c_blue, 90, "push"),
            new create_attack("Redemoinho", "agua", 10, 180, 40, "area", 0, 0, c_aqua, 80, "none")
        ]
    },
    grama: {
        basics: [
            new create_attack("Folha Navalha", "grama", 6, 40, 10, "line", 260, 10, c_lime, 6, "pierce"),
            new create_attack("Semente", "grama", 5, 35, 8, "circle", 200, 6, c_green, 4, "none")
        ],
        specials: [
            new create_attack("Chicote de Vinha", "grama", 15, 150, 30, "line", 150, 15, c_green, 5, "none"),
            new create_attack("Raio Solar", "grama", 40, 500, 90, "line", 600, 25, c_white, 12, "pierce"),
            new create_attack("Tempestade de Folhas", "grama", 25, 300, 50, "cone", 250, 9, c_lime, 60, "none")
        ]
    },
    sombra: {
        basics: [
            new create_attack("Orbe Sombrio", "sombra", 8, 50, 20, "circle", 250, 5, c_purple, 8, "none"),
            new create_attack("Espinho Negro", "sombra", 7, 45, 10, "line", 280, 8, c_black, 4, "none")
        ],
        specials: [
            new create_attack("Vazio", "sombra", 30, 300, 60, "area", 0, 0, c_black, 100, "none"),
            new create_attack("Pesadelo", "sombra", 20, 250, 40, "line", 350, 10, c_maroon, 10, "pierce"),
            new create_attack("Pulso Escuro", "sombra", 25, 200, 30, "self", 0, 0, c_purple, 120, "push")
        ]
    },
    inseto: {
        basics: [
            new create_attack("Ferrão", "inseto", 5, 25, 5, "line", 120, 12, c_lime, 3, "none"),
            new create_attack("Tiro de Teia", "inseto", 3, 80, 15, "circle", 300, 9, c_white, 6, "none")
        ],
        specials: [
            new create_attack("Zumbido", "inseto", 15, 180, 40, "self", 0, 0, c_olive, 90, "stun"),
            new create_attack("Tesoura X", "inseto", 20, 200, 30, "cone", 100, 15, c_green, 60, "none"),
            new create_attack("Enxame", "inseto", 25, 400, 60, "area", 0, 0, c_yellow, 100, "none")
        ]
    },
    normal: {
        basics: [
            new create_attack("Investida", "normal", 8, 40, 10, "line", 100, 8, c_white, 10, "push"),
            new create_attack("Arranhão", "normal", 6, 30, 5, "cone", 60, 10, c_ltgray, 45, "none")
        ],
        specials: [
            new create_attack("Hiper Raio", "normal", 50, 600, 100, "line", 500, 20, c_white, 25, "pierce"),
            new create_attack("Estrela Cadente", "normal", 15, 120, 20, "circle", 300, 12, c_yellow, 30, "none"),
            new create_attack("Rugido", "normal", 0, 300, 30, "self", 0, 0, c_white, 150, "push")
        ]
    },
    metal: {
        basics: [
            new create_attack("Tiro de Ferro", "metal", 8, 45, 15, "line", 300, 15, c_dkgray, 3, "none"),
            new create_attack("Porrada", "metal", 10, 60, 10, "cone", 50, 10, c_gray, 45, "push")
        ],
        specials: [
            new create_attack("Canhão de Luz", "metal", 30, 300, 60, "line", 400, 8, c_silver, 10, "pierce"),
            new create_attack("Chuva de Estilhaços", "metal", 15, 150, 30, "cone", 200, 9, c_gray, 60, "pierce"),
            new create_attack("Esmagamento Titânico", "metal", 40, 450, 80, "area", 0, 0, c_dkgray, 100, "stun")
        ]
    },
    dragao: {
        basics: [
            new create_attack("Sopro", "dragao", 10, 60, 15, "cone", 150, 8, c_teal, 30, "none"),
            new create_attack("Garra de Dragão", "dragao", 12, 50, 10, "cone", 80, 12, c_lime, 60, "none")
        ],
        specials: [
            new create_attack("Meteoro Draco", "dragao", 50, 600, 90, "area", 0, 0, c_orange, 150, "none"),
            new create_attack("Pulso do Dragão", "dragao", 25, 200, 40, "circle", 350, 10, c_purple, 15, "push"),
            new create_attack("Fúria", "dragao", 30, 300, 50, "self", 0, 0, c_red, 100, "push")
        ]
    },
    luz: {
        basics: [
            new create_attack("Raio de Luz", "luz", 8, 50, 10, "line", 300, 20, c_yellow, 4, "pierce"),
            new create_attack("Brilho", "luz", 5, 40, 5, "circle", 200, 8, c_white, 6, "stun")
        ],
        specials: [
            new create_attack("Julgamento", "luz", 45, 500, 80, "area", 0, 0, c_yellow, 120, "none"),
            new create_attack("Prisma", "luz", 15, 150, 30, "cone", 250, 10, c_aqua, 30, "none"),
            new create_attack("Lança Sagrada", "luz", 25, 250, 50, "line", 400, 12, c_yellow, 10, "pierce")
        ]
    },
    terra: {
        basics: [
            new create_attack("Lama", "terra", 8, 50, 15, "line", 150, 6, c_maroon, 6, "none"),
            new create_attack("Pedrada", "terra", 12, 80, 20, "circle", 200, 7, c_gray, 8, "none")
        ],
        specials: [
            new create_attack("Terremoto", "terra", 30, 400, 60, "self", 0, 0, c_maroon, 150, "stun"),
            new create_attack("Deslizamento", "terra", 20, 200, 40, "cone", 180, 6, c_maroon, 60, "push"),
            new create_attack("Fissura", "terra", 50, 600, 100, "line", 350, 4, c_black, 20, "pierce")
        ]
    }
};

// ============================================================================
// SISTEMAS CORE (DATA-DRIVEN)
// Contém: Leveling, Party, Box, Database de Monstros e Sistema de Captura
// ============================================================================

// --- Variáveis Globais do Jogador ---
global.player_level = 1;
global.player_max_level = 6;
global.party = []; // Array de referências de struct de monstros. Limite: player_level
global.box = [];   // Armazém de monstros capturados
global.capture_pending = false; // Flag para UI lidar com party cheia
global.capture_pending_monster = undefined;

// --- GERENCIAMENTO DE EQUIPE ---

/**
 * @function party_add_monster(monster_data)
 * @description Tenta adicionar o monstro na party com base no level do jogador.
 * @param {Struct} _monster_data
 * @returns {String} "added", "box", ou "pending"
 */
function party_add_monster(_monster_data) {
    // Clona o struct para não compartilhar a mesma instância de memória
    var _new_monster = variable_clone(_monster_data);
    
    if (array_length(global.party) < global.player_level) {
        array_push(global.party, _new_monster);
        show_debug_message("Monstro adicionado a equipe!");
        return "added";
    } else {
        // Opção do jogador quando capturar acima do limite:
        // Enviar pra Box, Trocar, ou Party Perigosa
        global.capture_pending_monster = _new_monster;
        global.capture_pending = true;
        show_debug_message("Equipe cheia. Aguardando escolha do jogador...");
        return "pending";
    }
}

/**
 * @function party_add_dangerous(monster_data)
 * @description Força a entrada na equipe, causando uma "Party Perigosa".
 */
function party_add_dangerous(_monster_data) {
    array_push(global.party, _monster_data);
    show_debug_message("ATENÇÃO: Monstro adicionado em PARTY PERIGOSA! Pode se rebelar!");
}

/**
 * @function box_add_monster(monster_data)
 */
function box_add_monster(_monster_data) {
    array_push(global.box, _monster_data);
    show_debug_message("Monstro enviado para a BOX com sucesso.");
}

// --- BANCO DE DADOS DE MONSTROS ---

// --- SISTEMA DE PERSONALIDADE E HUMOR ---
global.moods_db = [
    "Feliz", "Triste", "Agressivo", "Medroso", "Preguiçoso",
    "Eufórico", "Faminto", "Cansado", "Focado", "Confuso",
    "Irritado", "Calmo", "Ansioso", "Brincalhão"
];

global.personalities_db = [
    "Corajoso", "Covarde", "Leal", "Teimoso", "Curioso",
    "Protetor", "Caçador", "Gentil", "Malicioso", "Sábio",
    "Impulsivo", "Calculista", "Desastrado", "Estrategista", "Arrogante",
    "Tímido", "Feroz", "Dócil", "Vingativo", "Piedoso",
    "Ganancioso", "Altruísta", "Desconfiado", "Ingênuo", "Vaidoso",
    "Estoico", "Dramático", "Solitário", "Sociável", "Aventureiro",
    "Cauteloso", "Apressado", "Meticuloso", "Desleixado", "Focado",
    "Distraído", "Passivo", "Dominante", "Submisso", "Rebelde",
    "Leal", "Traiçoeiro", "Otimista", "Pessimista", "Realista",
    "Sonhador", "Competitivo", "Pacifista", "Sádico", "Masoca"
];

/**
 * @function monster_update_stats(monster_data)
 * @description Atualiza os status escalonando pelo nível (1 a 100)
 */
function monster_update_stats(_data) {
    var _lv = _data.level;
    // Exemplo de escala: a cada level ganha 10% do status base
    _data.max_hp = _data.base_hp + (_data.base_hp * (_lv - 1) * 0.1);
    _data.atk = _data.base_atk + (_data.base_atk * (_lv - 1) * 0.1);
    _data.spd = _data.base_spd + ((_lv - 1) * 0.01);
    
    if (_data.hp > _data.max_hp) _data.hp = _data.max_hp;
}

/**
 * @function create_monster_data(name, element, max_hp, atk, spd, capture_rate, base_xp) constructor
 * @description Construtor principal para os monstros.
 */
function create_monster_data(_name, _element_1, _element_2, _max_hp, _atk, _spd, _capture_rate, _base_xp, _basic_atk = undefined, _special_atk = undefined) constructor {
    name = _name;
    element = _element_1; // Compatibilidade com código legado
    element_1 = _element_1;
    element_2 = _element_2;
    
    base_hp = _max_hp;
    base_atk = _atk;
    base_spd = _spd;
    
    max_hp = base_hp;
    hp = max_hp;
    atk = base_atk;
    spd = base_spd;
    
    capture_rate = _capture_rate; // 0.0 a 1.0
    base_xp = _base_xp;
    
    level = 1; // 1 a 100
    current_xp = 0;
    
    // Humores e Personalidades únicos por instância
    mood = global.moods_db[irandom(array_length(global.moods_db)-1)];
    personality = global.personalities_db[irandom(array_length(global.personalities_db)-1)];
    
    // Controle de Invocação
    is_summoned = false;
    summon_id = noone;

    // Liga os ataques ao banco de ataques ou usa os passados por parâmetro
    if (_basic_atk != undefined) {
        basic_atk = _basic_atk;
    } else {
        var _db = variable_struct_get(global.attack_database, _element_1);
        if (_db != undefined) {
            basic_atk = _db.basics[0];
        } else {
            basic_atk = global.attack_database.normal.basics[0];
        }
    }
    
    if (_special_atk != undefined) {
        special_atk = _special_atk;
    } else {
        var _db = variable_struct_get(global.attack_database, _element_1);
        if (_db != undefined) {
            special_atk = _db.specials[0];
        } else {
            special_atk = global.attack_database.normal.specials[0];
        }
    }

    // Retorna todos os ataques básicos que este monstro pode aprender (baseados nos seus dois elementos)
    get_learnable_basics = function() {
        var _list = [];
        
        // Elemento 1
        var _db1 = variable_struct_get(global.attack_database, element_1);
        if (_db1 != undefined) {
            for (var i = 0; i < array_length(_db1.basics); i++) {
                array_push(_list, _db1.basics[i]);
            }
        }
        
        // Elemento 2 (se houver e for diferente)
        if (element_2 != "nenhum" && element_2 != element_1) {
            var _db2 = variable_struct_get(global.attack_database, element_2);
            if (_db2 != undefined) {
                for (var i = 0; i < array_length(_db2.basics); i++) {
                    array_push(_list, _db2.basics[i]);
                }
            }
        }
        
        return _list;
    }
    
    // Retorna todos os ataques especiais que este monstro pode aprender (baseados nos seus dois elementos)
    get_learnable_specials = function() {
        var _list = [];
        
        // Elemento 1
        var _db1 = variable_struct_get(global.attack_database, element_1);
        if (_db1 != undefined) {
            for (var i = 0; i < array_length(_db1.specials); i++) {
                array_push(_list, _db1.specials[i]);
            }
        }
        
        // Elemento 2 (se houver e for diferente)
        if (element_2 != "nenhum" && element_2 != element_1) {
            var _db2 = variable_struct_get(global.attack_database, element_2);
            if (_db2 != undefined) {
                for (var i = 0; i < array_length(_db2.specials); i++) {
                    array_push(_list, _db2.specials[i]);
                }
            }
        }
        
        return _list;
    }
}

global.monster_db = {
    orc_teste: new create_monster_data("Orc Teste", "sombra", "nenhum", 50, 10, 1.2, 0.5, 10),
    slime_fogo: new create_monster_data("Slime Ignis", "fogo", "nenhum", 60, 12, 1.5, 0.7, 15),
    pombo_vento: new create_monster_data("Pombo Cinza", "normal", "nenhum", 40, 8, 2.0, 0.9, 8)
};

// --- SISTEMA DE CAPTURA ---

/**
 * @function calculate_capture_chance(monster_inst)
 * @description Retorna a chance de captura do monstro de 0.0 a 1.0.
 */
function calculate_capture_chance(_monster_inst) {
    if (!instance_exists(_monster_inst)) return 0.0;
    if (!variable_instance_exists(_monster_inst, "monster_data")) return 0.0;
    
    var _data = _monster_inst.monster_data;
    
    // 1. FATOR DE FORÇA (Player Level vs Monster Stats)
    var _player_strength = global.player_level * 20; 
    var _monster_strength = (_data.max_hp * 0.5) + _data.atk;
    
    // Força relativa: Se o player for mais forte, o fator é > 1.0 (ajuda na captura)
    var _strength_factor = _player_strength / max(1, _monster_strength);
    
    // 2. FATOR DE HP (Quanto menos vida o monstro tem, mais fácil)
    var _hp_factor = 1.0 - (_monster_inst.hp / _monster_inst.max_hp);
    
    // 3. CHANCE FINAL
    var _chance = _data.capture_rate * _hp_factor * _strength_factor;
    
    // Regras Extremas:
    // Mínimo de 2% de chance.
    // Se o HP estiver cheio, a chance é fixa em 1% (quase impossível sem bater).
    if (_hp_factor <= 0) _chance = 0.01;
    return clamp(_chance, 0.02, 1.0);
}

/**
 * @function capture_logic(monster_inst)
 * @description Tenta capturar o monstro alvo aplicando a fórmula matemática de chance, baseada em nível e vida.
 * @param {Id.Instance} _monster_inst A instância do monstro no mapa.
 * @returns {Bool} true se capturado, false caso contrário.
 */
function capture_logic(_monster_inst) {
    if (!instance_exists(_monster_inst)) return false;
    if (!variable_instance_exists(_monster_inst, "monster_data")) {
        show_debug_message("Este monstro não possui dados (não data-driven).");
        return false;
    }
    
    var _data = _monster_inst.monster_data;
    var _chance = calculate_capture_chance(_monster_inst);
    var _roll = random(1.0);
    
    show_debug_message("=== TENTATIVA DE CAPTURA ===");
    show_debug_message("Chance Final: " + string(_chance*100) + "% | Dado(Sorte): " + string(_roll*100));
    
    if (_roll <= _chance) {
        // Atualiza a struct com a vida do momento
        _data.hp = _monster_inst.hp;
        
        party_add_monster(_data);
        
        // Efeitos de captura com os assets que o game já possui (se aplicável)
        instance_destroy(_monster_inst);
        return true;
    } else {
        return false;
    }
}