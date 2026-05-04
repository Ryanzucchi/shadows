/// @description UI da Party e Controles

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

if (!variable_instance_exists(id, "show_status_menu")) show_status_menu = false;
if (keyboard_check_pressed(vk_f2)) show_status_menu = !show_status_menu;

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1); // Usa a fonte padrão

// ==========================================
// TELA DE STATUS COMPLETA (F2)
// ==========================================
if (show_status_menu) {
    var _mx = _gui_w / 2 - 300;
    var _my = _gui_h / 2 - 250;
    
    draw_set_alpha(0.9);
    draw_set_color(c_black);
    draw_roundrect(_mx, _my, _mx + 600, _my + 500, false);
    draw_set_alpha(1);
    
    draw_set_color(c_aqua);
    draw_roundrect(_mx, _my, _mx + 600, _my + 500, true);
    
    draw_set_halign(fa_center);
    draw_text(_mx + 300, _my + 15, "=== MENU DE STATUS DA EQUIPE (F2) ===");
    draw_set_halign(fa_left);
    
    draw_set_color(c_yellow);
    draw_text(_mx + 20, _my + 50, "JOGADOR - Level: " + string(global.player_level) + " / " + string(global.player_max_level));
    
    var _py = _my + 90;
    for (var i = 0; i < array_length(global.party); i++) {
        var _mon = global.party[i];
        
        draw_set_color(c_aqua);
        draw_text(_mx + 20, _py, "[" + string(i+1) + "] " + _mon.name);
        
        draw_set_color(c_white);
        draw_text(_mx + 200, _py, "Nível: " + string(_mon.level) + "/100");
        draw_text(_mx + 320, _py, "Humor: " + _mon.mood);
        draw_text(_mx + 450, _py, "Personalidade: " + _mon.personality);
        
        _py += 20;
        draw_set_color(c_silver);
        draw_text(_mx + 20, _py, "   HP: " + string(ceil(_mon.hp)) + "/" + string(_mon.max_hp));
        draw_text(_mx + 150, _py, "Atk: " + string(_mon.atk));
        draw_text(_mx + 250, _py, "Spd: " + string(_mon.spd));
        if (_mon.is_summoned) {
            draw_set_color(c_lime);
            draw_text(_mx + 350, _py, ">> INVOCADO NO MAPA <<");
        }
        
        _py += 30;
    }
    
    draw_set_color(c_yellow);
    draw_set_halign(fa_center);
    draw_text(_mx + 300, _my + 460, "Pressione F2 para fechar este menu.");
    draw_set_halign(fa_left);
    
    exit; // Sai do Draw GUI para não desenhar a HUD padrão por cima
}

// ==========================================
// 1. MENU DE CONTROLES (Esquerda)
// ==========================================
var _cx = 10;
var _cy = 10;

draw_set_color(c_yellow);
draw_text(_cx, _cy, "--- CONTROLES ---");
draw_set_color(c_white);
draw_text(_cx, _cy + 20, "WASD / Setas : Mover");
draw_text(_cx, _cy + 40, "SHIFT        : Correr");
draw_text(_cx, _cy + 60, "Espaço / K   : Dash");
draw_text(_cx, _cy + 80, "C            : Capturar Inimigo");
draw_text(_cx, _cy + 100,"Botão Esq.   : Atirar Magia");
draw_text(_cx, _cy + 120,"1 a 6        : Invocar/Recolher Party");
draw_text(_cx, _cy + 140,"F2           : Status Completo (Lvl/Humor)");

// ==========================================
// 2. STATUS DO JOGADOR (Esquerda Inferior)
// ==========================================
_cy += 140;
draw_set_color(c_lime);
draw_text(_cx, _cy, "--- STATUS ---");
draw_set_color(c_white);
draw_text(_cx, _cy + 20, "Level: " + string(global.player_level) + " / " + string(global.player_max_level));
draw_text(_cx, _cy + 40, "HP: " + string(ceil(hp)));
draw_text(_cx, _cy + 60, "Estado: " + string(state));
draw_text(_cx, _cy + 80, "Box: " + string(array_length(global.box)) + " monstros guardados");

// ==========================================
// 3. EXIBIR A PARTY (Direita)
// ==========================================
var _px = _gui_w - 250;
if (_px < _gui_w / 2) _px = _gui_w / 2; // Evita bugar em telas pequenas
var _py = 10;

var _is_dangerous = array_length(global.party) > global.player_level;

if (_is_dangerous) {
    draw_set_color(c_red);
    draw_text(_px, _py, "!!! PARTY PERIGOSA !!!");
} else {
    draw_set_color(c_aqua);
    draw_text(_px, _py, "--- SUA EQUIPE ---");
}

_py += 25;

if (array_length(global.party) == 0) {
    draw_set_color(c_gray);
    draw_text(_px, _py, "Nenhum monstro na equipe.");
} else {
    for (var i = 0; i < array_length(global.party); i++) {
        var _mon = global.party[i];
        
        // Cores baseadas no elemento
        var _col = c_white;
        switch (_mon.element) {
            case "fogo":   _col = c_red; break;
            case "agua":   _col = c_blue; break;
            case "grama":  _col = c_lime; break;
            case "sombra": _col = c_purple; break;
            case "terra":  _col = c_orange; break;
            case "luz":    _col = c_yellow; break;
            default:       _col = c_ltgray; break;
        }
        
        draw_set_color(_col);
        
        var _txt_prefix = _mon.is_summoned ? "[OUT] " : "";
        draw_text(_px, _py, string(i+1) + ". " + _txt_prefix + _mon.name + " (Lvl." + string(_mon.level) + ")");
        
        draw_set_color(c_white);
        _py += 15;
        draw_text(_px, _py, "   HP: " + string(ceil(_mon.hp)) + "/" + string(_mon.max_hp));
        _py += 25; // Espaço pro próximo
    }
}

// ==========================================
// 4. MENSAGEM DE CAPTURA PENDENTE (Centro)
// ==========================================
if (global.capture_pending) {
    var _mid_x = _gui_w / 2;
    draw_set_halign(fa_center); // Centraliza o texto
    
    draw_set_color(c_red);
    draw_text(_mid_x, 50, "!!! LIMITE DA EQUIPE ATINGIDO !!!");
    
    draw_set_color(c_white);
    draw_text(_mid_x, 70, "Monstro capturado: " + global.capture_pending_monster.name);
    
    draw_set_color(c_yellow);
    draw_text(_mid_x, 100, "[ 1 ] Adicionar na Equipe (PARTY PERIGOSA)");
    draw_text(_mid_x, 120, "[ 2 ] Enviar para a Box (Armazém)");
    
    draw_set_halign(fa_left); // Volta ao normal
}