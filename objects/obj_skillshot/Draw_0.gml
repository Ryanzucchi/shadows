if (attack_data == undefined) exit;

var _shape = attack_data.shape;
var _elem = attack_data.element;
var _w = attack_data.width;
var _len = attack_data.range;
var _time = current_time / 100; // Timer global para animações
var _life = variable_instance_exists(id, "life_timer") ? life_timer : 0;

draw_set_alpha(1);

switch (_elem) {
    
    // --- 1. FOGO (Partículas, chamas vivas) ---
    case "fogo":
        draw_set_color(choose(c_orange, c_red, c_yellow));
        
        if (_shape == "cone") {
            // Lança-chamas: Vários círculos aleatórios saindo da origem
            var _amount = 15; 
            for (var i = 0; i < _amount; i++) {
                var _dist = random(_len);
                var _spread = (_w / _len) * _dist;
                var _ang_offset = random_range(-_spread/2, _spread/2);
                var _px = x + lengthdir_x(_dist, image_angle + _ang_offset);
                var _py = y + lengthdir_y(_dist, image_angle + _ang_offset);
                var _s = random_range(2, 6) * (1 - _dist/_len); 
                draw_set_alpha(0.5);
                draw_circle(_px, _py, _s, false);
            }
        } 
        else if (_shape == "area" || _shape == "self") {
            // Explosão: Círculos expandindo
            draw_circle(x, y, _w, false);
            draw_set_color(c_yellow);
            draw_circle(x, y, _w * 0.7, false);
            draw_set_alpha(0.4);
            draw_circle(x, y, _w * 1.2, true);
        }
        else { 
            // Bola de Fogo / Linha: Núcleo + Rastro
            draw_circle(x, y, _w, false);
            draw_set_color(c_yellow);
            draw_circle(x + random_range(-2, 2), y + random_range(-2, 2), _w*0.6, false);
            // Rastro
            draw_set_alpha(0.3);
            draw_set_color(c_red);
            draw_circle(x - lengthdir_x(_w, direction), y - lengthdir_y(_w, direction), _w*0.8, false);
        }
        break;

    // --- 2. ÁGUA (Ondas, bolhas, azul suave) ---
    case "agua":
        draw_set_color(c_aqua);
        
        if (_shape == "line" || _shape == "cone") {
            // Efeito de onda senoidal
            var _segments = 8;
            var _seg_len = 15;
            var _lx = x;
            var _ly = y;
            draw_set_alpha(0.7);
            
            for (var i = 0; i < _segments; i++) {
                var _wave = sin(_time + i) * 6;
                var _nx = x - lengthdir_x(i*_seg_len, direction) + lengthdir_x(_wave, direction + 90);
                var _ny = y - lengthdir_y(i*_seg_len, direction) + lengthdir_y(_wave, direction + 90);
                draw_circle(_lx, _ly, _w - (i*0.5), false);
                _lx = _nx; 
                _ly = _ny;
            }
        } else {
            // Bolha: Círculo translúcido com brilho
            draw_set_alpha(0.3);
            draw_circle(x, y, _w, false);
            draw_set_alpha(0.8);
            draw_circle(x, y, _w, true); // Contorno
            draw_set_color(c_white);
            draw_circle(x - _w/3, y - _w/3, _w/4, false); // Brilho especular
        }
        break;

    // --- 3. GRAMA (Folhas girando, verde vibrante) ---
    case "grama":
        draw_set_color(c_lime);
        
        // Núcleo
        draw_circle(x, y, _w/2, false);
        
        // Folhas orbitando (triângulos)
        var _rot_speed = current_time * 0.4;
        var _num_leaves = 4;
        for (var i = 0; i < _num_leaves; i++) {
            var _ang = _rot_speed + (i * (360/_num_leaves));
            var _lx = x + lengthdir_x(_w, _ang);
            var _ly = y + lengthdir_y(_w, _ang);
            // Desenha triângulo (folha) apontando pra fora
            draw_triangle(_lx, _ly, 
                          _lx + lengthdir_x(8, _ang+140), _ly + lengthdir_y(8, _ang+140),
                          _lx + lengthdir_x(8, _ang-140), _ly + lengthdir_y(8, _ang-140), false);
        }
        break;

    // --- 4. SOMBRA (Roxo escuro, pulsante, glitch) ---
    case "sombra":
        draw_set_color(c_black);
        
        // Núcleo negro tremendo
        var _sx = x + random_range(-2, 2);
        var _sy = y + random_range(-2, 2);
        draw_circle(_sx, _sy, _w * 0.8, false);
        
        // Aura roxa
        draw_set_color(c_purple);
        draw_set_alpha(0.5);
        draw_circle(x, y, _w, true);
        draw_circle(x, y, _w + 2 + sin(_time)*2, true); // Pulsação
        
        // Partículas de "sugada" (linhas indo pro centro)
        if (random(1) > 0.7) {
            var _px = x + random_range(-30, 30);
            var _py = y + random_range(-30, 30);
            draw_line(_px, _py, x, y);
        }
        break;

    // --- 5. INSETO (Enxame de pequenos pontos, verde oliva) ---
    case "inseto":
        draw_set_color(c_olive);
        
        // Em vez de 1 forma grande, desenha várias pequenas (enxame)
        var _swarm_size = 10; 
        for (var i = 0; i < _swarm_size; i++) {
            var _ox = random_range(-_w, _w);
            var _oy = random_range(-_w, _w);
            // Vibração rápida
            _ox += random_range(-2, 2);
            draw_circle(x + _ox, y + _oy, 2, false);
        }
        // Linhas de velocidade (zumbido)
        draw_set_alpha(0.2);
        draw_line(x-_w, y-_w, x+_w, y+_w);
        draw_line(x-_w, y+_w, x+_w, y-_w);
        break;

    // --- 6. NORMAL (Branco/Cinza, limpo, shockwaves) ---
    case "normal":
        draw_set_color(c_white);
        draw_circle(x, y, _w, false);
        draw_set_color(c_ltgray);
        draw_set_alpha(0.5);
        draw_circle(x, y, _w * 1.3, true); // Anel de ar
        break;

    // --- 7. METAL (Cinza azulado, formas angulares/afiadas) ---
    case "metal":
        draw_set_color(c_ltgray);
        // Desenha Losango (Diamante) em vez de círculo
        draw_triangle(x-_w, y, x, y-_w*1.5, x+_w, y, false);
        draw_triangle(x-_w, y, x, y+_w*1.5, x+_w, y, false);
        
        // Brilho metálico (linha branca cruzando)
        draw_set_color(c_white);
        draw_set_alpha(0.8);
        draw_line(x-_w/2, y-_w/2, x+_w/2, y+_w/2);
        break;

    // --- 8. DRAGÃO (Energia caótica, azul/laranja misturados) ---
    case "dragao":
        draw_set_color(c_teal);
        draw_circle(x, y, _w, false);
        
        // Bordas de fogo laranja (energia instável)
        draw_set_color(c_orange);
        draw_set_alpha(0.6);
        for (var i = 0; i < 360; i+=45) {
            var _d = _w + random(5);
            var _dx = x + lengthdir_x(_d, i + _time*10);
            var _dy = y + lengthdir_y(_d, i + _time*10);
            draw_circle(_dx, _dy, 3, false);
        }
        break;

    // --- 9. LUZ (Amarelo brilhante, raios/lasers) ---
    case "luz":
        draw_set_color(c_white);
        draw_circle(x, y, _w*0.5, false); // Centro branco puro
        
        draw_set_color(c_yellow);
        draw_set_alpha(0.4);
        draw_circle(x, y, _w*1.2, false); // Halo amarelo
        
        // Raios saindo (Estrela)
        draw_set_alpha(0.8);
        var _ray_len = _w * 2;
        draw_line(x - _ray_len, y, x + _ray_len, y);
        draw_line(x, y - _ray_len, x, y + _ray_len);
        
        if (_shape == "line") {
            // Laser contínuo
            draw_line_width(x, y, x-lengthdir_x(40, direction), y-lengthdir_y(40, direction), _w*0.8);
        }
        break;

    // --- 10. TERRA (Marrom, formas quadradas/pedras) ---
    case "terra":
        var _brown = make_color_rgb(139, 69, 19);
        draw_set_color(_brown);
        
        if (_shape == "line" || _shape == "cone") {
            // Pedras voando (quadrados girando)
            var _ang_rot = -current_time;
            var _size = _w;
            // Desenha quadrado rotacionado manualmente (simples) ou retângulo
            draw_rectangle(x-_size/2, y-_size/2, x+_size/2, y+_size/2, false);
            
            // Rastros de poeira
            draw_set_color(c_gray);
            draw_circle(x - lengthdir_x(10, direction), y - lengthdir_y(10, direction), 4, false);
        } 
        else {
            // Fissura / Terremoto
            draw_set_alpha(1);
            draw_line_width(x-_w, y, x+_w, y, 4);
            draw_line_width(x, y-_w, x, y+_w, 4);
            draw_circle(x, y, _w, true);
        }
        break;
        
    // --- PADRÃO DE SEGURANÇA ---
    default:
        draw_set_color(c_white);
        draw_circle(x, y, _w, true);
        draw_text(x, y, "?");
        break;
}

// Reset final
draw_set_alpha(1);
draw_set_color(c_white);