/// @description Configurações Padrão
// Estas variáveis existem para evitar erro se você esquecer de configurar no filho
nome = "Base";
hp_max = 10;
hp_atual = hp_max;
velocidade = 1;
state = "IDLE";
personalidade = 0; // 0=Passivo, 1=Agressivo...

// Variáveis de Combate
raio_visao = 100;
raio_ataque = 20;
dano = 1;
timer_ataque = 0;
pode_atacar = true;

// Sprites (Deixe como -1 ou undefined aqui)
spr_idle = -1;
spr_walk = -1;
spr_attack = -1;
spr_hurt = -1;
spr_death = -1;

// --- DEBUG ---
modo_debug = true; // Mude para false quando for lançar o jogo