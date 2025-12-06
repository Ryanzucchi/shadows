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