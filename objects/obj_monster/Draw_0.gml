draw_self();

// 1. Telegraph (Visualização do ataque antes de sair)
if (state == MO_STATE.CHANNELING && current_attack != undefined) {
    draw_set_alpha(0.4);
    draw_set_color(current_attack.color);
    
    var _dir = point_direction(x, y, target_x, target_y);
    var _range = current_attack.range;
    var _w = current_attack.width;
    
    if (current_attack.shape == "cone") {
        var _x1 = x + lengthdir_x(_range, _dir - _w/2);
        var _y1 = y + lengthdir_y(_range, _dir - _w/2);
        var _x2 = x + lengthdir_x(_range, _dir + _w/2);
        var _y2 = y + lengthdir_y(_range, _dir + _w/2);
        draw_triangle(x, y, _x1, _y1, _x2, _y2, false);
    }
    else if (current_attack.shape == "line") {
        var _lx = x + lengthdir_x(_range, _dir);
        var _ly = y + lengthdir_y(_range, _dir);
        draw_line_width(x, y, _lx, _ly, _w);
    }
    else if (current_attack.shape == "circle") {
        // Linha de mira
        draw_line(x, y, target_x, target_y);
        draw_circle(target_x, target_y, 5, false);
    }
    else if (current_attack.shape == "area") {
        draw_circle(target_x, target_y, _w, false);
        draw_line(x, y, target_x, target_y); // Linha conectando
    }
    else if (current_attack.shape == "self") {
        draw_circle(x, y, _w, false);
    }
    
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// 2. Barra de Vida
var _pct = (hp / max_hp) * 100;
draw_healthbar(x-20, y-35, x+20, y-30, _pct, c_black, c_red, c_green, 0, true, true);

// 3. Chance de Captura (Debug/HUD)
var _cap_chance = calculate_capture_chance(id) * 100;
draw_set_halign(fa_center);
draw_set_font(-1);
draw_set_color(c_fuchsia);
draw_text_transformed(x, y-50, string_format(_cap_chance, 1, 0) + "% Captura", 0.75, 0.75, 0);

// 4. Debug Label
if (debug_open) {
    draw_set_color(c_yellow);
    draw_text(x, y-70, "DEBUG EDIT");
}

// Reset
draw_set_color(c_white);
draw_set_halign(fa_left);

