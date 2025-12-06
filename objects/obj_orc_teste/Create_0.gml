/// @description Configuração do Orc

// 1. Carrega as variáveis e lógica do novo obj_monster
event_inherited(); 

// 2. Personaliza os atributos (Usando os nomes NOVOS do obj_monster)
name = "Orc Guerreiro";
hp_max = 50;
hp = hp_max;

spd = 1.2;          // Era "velocidade"
aggro_range = 250;  // Era "raio_visao"
attack_range = 50;  // Era "raio_ataque"

// 3. Define os Sprites
spr_idle = spr_orc;
spr_walk = spr_orc;   // Se tiver animação de andar, troque aqui
spr_attack = spr_orc; // Se tiver animação de ataque, troque aqui
spr_death = spr_orc;  // Sprite de morte

// Atualiza o sprite inicial
sprite_index = spr_idle;

// 4. Configura os Golpes (A nova forma de atacar)
// O obj_monster vai ler isso e criar o projétil/hitbox automaticamente
if (variable_global_exists("move_library")) {
    // Slot 0: Ataque Básico (Automático) - Vamos usar um golpe "melee" curto
    // Se não tiver golpe criado na library, crie um "soco" ou "corte" no obj_game_control
    // Por enquanto, usaremos o 'ember' como teste ou crie um novo:
    
    // Exemplo de golpe físico para Orc (Adicione isso no obj_game_control depois):
    // global.move_library.slash = new Move("Corte", ELEMENT.NORMAL, 10, 45, "cone", 60, 0, c_white);
    
    moveset[0] = global.move_library.ember; // Usando Ember temporariamente para testar
}