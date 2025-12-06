// 1. Puxa a lógica do Pai (IMPORTANTE!)
event_inherited();

// 2. Configura SÓ o que é único desse bicho
nome = "Orc de Teste";
hp_max = 50;
hp_atual = hp_max;
velocidade = 1.2;
raio_visao = 180;
raio_ataque = 25;

// 3. Linka os Sprites (Aqui você usa as imagens que mandou)
spr_idle = spr_orc;
spr_walk = spr_orc;
spr_attack = spr_orc; // ou 02
spr_hurt = spr_orc;
spr_death = spr_orc;

// Define o sprite inicial
sprite_index = spr_orc;