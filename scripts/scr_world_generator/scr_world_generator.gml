// ============================================================================
// GERADOR DE MUNDO E TILEMAP DE CHÃO
// ============================================================================

/**
 * @function init_world_ground()
 * @description Preenche o mapa do mundo aberto com tiles de chão (TileSet2) de forma contínua e orgânica.
 */
function init_world_ground() {
    var _layer_name = "ts_terra";
    var _lay_id = layer_get_id(_layer_name);
    
    if (_lay_id == -1) {
        _lay_id = layer_create(400, _layer_name);
    }
    
    var _map_id = layer_tilemap_get_id(_lay_id);
    if (_map_id == -1 || !tilemap_get_tileset(_map_id)) {
        // Cria a camada de tilemap com TileSet2 de 300x300 tiles (4800px x 4800px)
        _map_id = layer_tilemap_create(_lay_id, 0, 0, TileSet2, 300, 300);
    }
    
    // Dimensões do mapa em tiles (300 x 300 tiles de 16x16 = 4800px x 4800px)
    var _cols = 300;
    var _rows = 300;
    
    for (var _gx = 0; _gx < _cols; _gx++) {
        for (var _gy = 0; _gy < _rows; _gy++) {
            // Algoritmo de ruído determinístico para gerar variações naturais no terreno
            var _hash = floor(abs(sin(_gx * 12.9898 + _gy * 78.233) * 43758.5453)) % 100;
            var _tile_idx = 81; // Tile de grama principal
            
            if (_hash < 70) {
                _tile_idx = 81; // Grama verde base
            } else if (_hash < 88) {
                _tile_idx = 83; // Detalhe de relva/folhagem
            } else if (_hash < 96) {
                _tile_idx = 80; // Mancha de terra suave
            } else {
                _tile_idx = 87; // Detalhe de pequena vegetação
            }
            
            tilemap_set(_map_id, _tile_idx, _gx, _gy);
        }
    }
    
    show_debug_message("=== TILEMAP DE CHÃO DO MUNDO GERADO COM SUCESSO (300x300 tiles)! ===");
}
