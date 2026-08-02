/// @description Inicialização de Variáveis

// --- 1. Configuração de Controle ---
gamepad_set_axis_deadzone(0, 0.25);

// --- 2. Variáveis de Movimento ---
hspd = 0;
vspd = 0;
len = 0;
dir = 0;
gp_aim_dir = 0;
lockon_target = noone; // Inimigo atualmente travado pelo Lock-on
selected_party_index = 0; // Índice do frasco/monstrinho selecionado na equipe

hp = 100;
max_hp = 100;
mana = 100;
max_mana = 100;
mana_regen = 0.2; // Regeneração de mana por frame

spd_walk = 2.0;    // Velocidade normal
spd_run  = 6.5;    // Velocidade correndo (Shift)
dash_spd = 6.0;    // Velocidade do Dash

state = "IDLE";    // Estado inicial
face = 6;          // Começa virado para baixo

// --- 3. Arrays de Sprites ---
// Copie aqui todos os seus arrays (sprite_idle, sprite_walk, etc...)
// Vou colocar resumido para não ficar gigante a resposta, mas mantenha os seus completos:

// IDLE
sprite_idle[0] = spr_idle_right;
sprite_idle[1] = spr_idle_right_up;
sprite_idle[2] = spr_idle_up;
sprite_idle[3] = spr_idle_left_up;
sprite_idle[4] = spr_idle_left;
sprite_idle[5] = spr_idle_left_down;
sprite_idle[6] = spr_idle_down;
sprite_idle[7] = spr_idle_right_down;

// WALK
sprite_walk[0] = spr_walk_right;
sprite_walk[1] = spr_walk_right_up;
sprite_walk[2] = spr_walk_up;
sprite_walk[3] = spr_walk_left_up;
sprite_walk[4] = spr_walk_left;
sprite_walk[5] = spr_walk_left_down;
sprite_walk[6] = spr_walk_down;
sprite_walk[7] = spr_walk_right_down;

// DASH
sprite_dash[0] = spr_dash_right;
sprite_dash[1] = spr_dash_right_up;
sprite_dash[2] = spr_dash_up;
sprite_dash[3] = spr_dash_left_up;
sprite_dash[4] = spr_dash_left;
sprite_dash[5] = spr_dash_left_down;
sprite_dash[6] = spr_dash_down;
sprite_dash[7] = spr_dash_right_down;

// DEATH
sprite_death[0] = spr_death_right;
sprite_death[1] = spr_death_right_up;
sprite_death[2] = spr_death_up;
sprite_death[3] = spr_death_left_up;
sprite_death[4] = spr_death_left;
sprite_death[5] = spr_death_left_down;
sprite_death[6] = spr_death_down;
sprite_death[7] = spr_death_right_down;

// Inicializa o sprite
sprite_index = sprite_idle[face];
image_speed = 1;