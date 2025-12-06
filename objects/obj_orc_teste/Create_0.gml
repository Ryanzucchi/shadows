// 1. IMPORTANTE: Carrega as variáveis do pai primeiro
event_inherited(); 

// 2. Personaliza
name = "Orc Guerreiro";
hp_max = 150;
hp = hp_max;
spd = 1.5;
types = [ELEMENT.PEDRA, -1]; // Tipo Pedra
behavior = BEHAVIOR.AGRESSIVO;

// 3. Define Sprites Específicos (se você tiver)
// spr_idle = spr_orc_idle;
// spr_walk = spr_orc_walk;

// 4. Define Golpes (Usando a biblioteca global)
if (variable_global_exists("move_library")) {
    moveset[0] = global.move_library.ember; // Exemplo: Orc cospe fogo fraco
    moveset[1] = global.move_library.flamethrower; // E ataque forte
}