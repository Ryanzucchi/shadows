// --- Enumeração de Tipos ---
enum ELEMENT {
    SOMBRA, AGUA, FOGO, GRAMA, LUZ, DRAGAO, INSETO, 
    NORMAL, VOADOR, MINERIO, ELETRICO, PEDRA, PSIQUICO
}

// --- Enumeração de Comportamentos ---
enum BEHAVIOR {
    PASSIVO, AGRESSIVO, TERRITORIAL, CACADOR
}

// --- Cores para Debug/Draw ---
global.type_colors = array_create(13);
global.type_colors[ELEMENT.SOMBRA] = c_dkgray;
global.type_colors[ELEMENT.AGUA] = c_blue;
global.type_colors[ELEMENT.FOGO] = c_red;
global.type_colors[ELEMENT.GRAMA] = c_green;
global.type_colors[ELEMENT.LUZ] = c_yellow;
global.type_colors[ELEMENT.ELETRICO] = c_orange;
global.type_colors[ELEMENT.PEDRA] = c_grey;
global.type_colors[ELEMENT.PSIQUICO] = c_fuchsia;
global.type_colors[ELEMENT.DRAGAO] = c_maroon;
global.type_colors[ELEMENT.INSETO] = c_lime;
global.type_colors[ELEMENT.NORMAL] = c_white;
global.type_colors[ELEMENT.VOADOR] = c_aqua;
global.type_colors[ELEMENT.MINERIO] = c_ltgray;

// --- Tabela de Eficácia (Multiplicadores) ---
global.effectiveness = ds_grid_create(13, 13);
ds_grid_clear(global.effectiveness, 1.0);

var set_eff = function(attacker, defender, mult) {
    global.effectiveness[# attacker, defender] = mult;
};

// Configurando regras (Exemplos):
set_eff(ELEMENT.AGUA, ELEMENT.FOGO, 2.0);
set_eff(ELEMENT.AGUA, ELEMENT.PEDRA, 2.0);
set_eff(ELEMENT.AGUA, ELEMENT.ELETRICO, 0.5);
set_eff(ELEMENT.AGUA, ELEMENT.GRAMA, 0.5);

set_eff(ELEMENT.FOGO, ELEMENT.GRAMA, 2.0);
set_eff(ELEMENT.FOGO, ELEMENT.INSETO, 2.0);
set_eff(ELEMENT.FOGO, ELEMENT.AGUA, 0.5);
set_eff(ELEMENT.FOGO, ELEMENT.PEDRA, 0.5);

set_eff(ELEMENT.SOMBRA, ELEMENT.PSIQUICO, 2.0);
set_eff(ELEMENT.SOMBRA, ELEMENT.LUZ, 2.0);
set_eff(ELEMENT.LUZ, ELEMENT.SOMBRA, 2.0);

// Nota: O construtor legado "Move" e a "global.move_library" foram removidos 
// pois a criação de ataques real é gerenciada no script centralizado "scr_combat_logic" 
// por meio do construtor "create_attack" e de "global.attack_database".