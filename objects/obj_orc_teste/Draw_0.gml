draw_self();

// --- 1. VISUALIZAÇÃO DO ATAQUE (TELEGRAPH) ---
if (state == MO_STATE.CHANNELING && current_active_attack != undefined) {
    draw_set_alpha(0.5);
    draw_set_color(current_active_attack.color);
    
    // Desenha linha de mira
    draw_line_width(x, y, target_x, target_y, 2);
    
    // Barra de Carga (Vermelha enchendo)
    var _pct = 1 - (channel_timer / current_active_attack.channel_time);
    draw_set_color(c_black);
    draw_rectangle(x-20, y-50, x+20, y-45, false);
    draw_set_color(c_red);
    draw_rectangle(x-20, y-50, x-20 + (40 * _pct), y-45, false);
    
    draw_set_alpha(1);
}

// --- 2. DEBUG VISUAL (Obrigatório) ---
draw_set_font(-1);
draw_set_halign(fa_center);

// Texto do Estado (Ex: CHASE, COOLDOWN)
var _txt = "UNKNOWN";
var _col = c_white;

switch(state) {
    case MO_STATE.IDLE: _txt = "IDLE"; _col = c_white; break;
    case MO_STATE.CHASE: _txt = "CHASE"; _col = c_yellow; break;
    case MO_STATE.CHANNELING: _txt = "CARREGANDO!"; _col = c_orange; break;
    case MO_STATE.ATTACKING: _txt = "ATK!"; _col = c_red; break;
    case MO_STATE.COOLDOWN: _txt = "WAIT"; _col = c_gray; break;
}

draw_set_color(_col);
draw_text(x, y - 65, _txt);

// --- 2.1 CHANCE DE CAPTURA ---
var _cap_chance = calculate_capture_chance(id) * 100;
draw_set_color(c_fuchsia);
draw_text_transformed(x, y - 115, string_format(_cap_chance, 1, 0) + "% Captura", 0.75, 0.75, 0);

// --- 3. BARRA DE COOLDOWN DO ESPECIAL ---
// Mostra uma barra azul para saber quando o especial volta
if (special_cooldown > 0) {
    var _cd_total = special_atk.cooldown_max;
    var _cd_pct = special_cooldown / _cd_total;
    
    draw_set_color(c_black);
    draw_rectangle(x-15, y-80, x+15, y-76, false);
    
    draw_set_color(c_aqua);
    // A barra diminui conforme o CD acaba
    draw_rectangle(x-15, y-80, x-15 + (30 * (1-_cd_pct)), y-76, false);
    
    // Mostra segundos restantes
    draw_set_color(c_white);
    draw_text_transformed(x, y-95, string(ceil(special_cooldown/60)) + "s", 0.5, 0.5, 0);
} else {
    // Se estiver pronto, avisa!
    draw_set_color(c_aqua);
    draw_text_transformed(x, y-95, "SPEC OK!", 0.5, 0.5, 0);
}

// Reset
draw_set_halign(fa_left);
draw_set_color(c_white);