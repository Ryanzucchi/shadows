// ============================================================================
// BANCO DE DADOS UNIVERSAL DE ITENS E MAGIAS (DATA-DRIVEN)
// ============================================================================

// --- 1. CONSTRUTOR DE ITENS ---
function create_item_data(_id, _name, _type, _desc, _hp_heal, _mana_heal, _value, _color) constructor {
    item_id = _id;
    name = _name;
    type = _type; // "consumable", "capture", "material", "key"
    description = _desc;
    heal_hp = _hp_heal;
    heal_mana = _mana_heal;
    value = _value;
    color = _color;
}

// --- 2. BANCO DE DADOS UNIVERSAL DE ITENS ---
global.item_database = {
    pocao_hp_p: new create_item_data("pocao_hp_p", "Poção de Vida Pê", "consumable", "Restaura 30 de HP do monstrinho ou da bruxa.", 30, 0, 15, c_red),
    pocao_hp_g: new create_item_data("pocao_hp_g", "Poção de Vida Gê", "consumable", "Restaura 80 de HP do monstrinho ou da bruxa.", 80, 0, 45, c_maroon),
    pocao_mana_p: new create_item_data("pocao_mana_p", "Poção de Mana Pê", "consumable", "Restaura 40 de Mana da bruxa.", 0, 40, 20, c_blue),
    pocao_mana_g: new create_item_data("pocao_mana_g", "Poção de Mana Gê", "consumable", "Restaura 100 de Mana da bruxa.", 0, 100, 50, c_navy),
    frasco_captura: new create_item_data("frasco_captura", "Frasco de Captura", "capture", "Frasco alquímico para capturar monstros enfraquecidos.", 0, 0, 25, c_fuchsia),
    elixir_alquimico: new create_item_data("elixir_alquimico", "Elixir Alquímico", "consumable", "Restaura 50 de HP e 50 de Mana.", 50, 50, 60, c_purple),
    erva_cura: new create_item_data("erva_cura", "Erva de Cura", "material", "Erva medicinal usada na preparação de poções.", 10, 0, 5, c_green)
};

// --- 3. CONSTRUTOR DE MAGIAS DO TOMO ---
function create_spell_data(_id, _name, _element, _mana_cost, _desc, _attack_struct) constructor {
    spell_id = _id;
    name = _name;
    element = _element;
    mana_cost = _mana_cost;
    description = _desc;
    attack = _attack_struct;
}

// --- 4. BANCO DE DADOS DE MAGIAS DO TOMO MÁGICO (MOUSE LEFT) ---
global.spell_database = {
    faisca: new create_spell_data("faisca", "Faísca Incandescente", "fogo", 8, "Dispara uma pequena fagulha de fogo rápida.", global.attack_database.fogo.basics[0]),
    brasa: new create_spell_data("brasa", "Brasa Mística", "fogo", 12, "Lança uma esfera concentrada de calor.", global.attack_database.fogo.basics[1]),
    bolha: new create_spell_data("bolha", "Bolha D'Água", "agua", 6, "Projétil leve de água com baixo custo de mana.", global.attack_database.agua.basics[0]),
    jato_agua: new create_spell_data("jato_agua", "Jato D'Água", "agua", 14, "Disparo d'água perfurante que empurra alvos.", global.attack_database.agua.basics[1]),
    folha_navalha: new create_spell_data("folha_navalha", "Folha Navalha", "grama", 10, "Lâmina vegetal cortante que atravessa inimigos.", global.attack_database.grama.basics[0]),
    orbe_sombria: new create_spell_data("orbe_sombria", "Orbe Sombrio", "sombra", 15, "Esfera escura que inflige alto dano elemental.", global.attack_database.sombra.basics[0]),
    raio_luz: new create_spell_data("raio_luz", "Raio de Luz", "luz", 12, "Feixe luminoso rápido que atordoa o alvo.", global.attack_database.luz.basics[0])
};

// --- 5. INVENTÁRIO INICIAL DO JOGADOR ---
global.player_inventory = [
    { item: global.item_database.pocao_hp_p, count: 5 },
    { item: global.item_database.pocao_mana_p, count: 3 },
    { item: global.item_database.frasco_captura, count: 10 }
];

// Moedas do jogador (Economia)
global.player_coins = 150;

// Magia equipada no Tomo para disparar no Mouse Left (padrão inicial: Faísca)
global.equipped_spell = global.spell_database.faisca;
