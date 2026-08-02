/// @description Inicialização do NPC Vendedor Alquimista

npc_name = "Morgana a Alquimista";
dialog_text = "Olá jovem bruxa! Precisa de poções ou frascos de captura para suas jornadas?";
is_open = false;
player_nearby = false;
selected_shop_idx = 0;

// Itens à venda na Loja
shop_items = [
    { item: global.item_database.pocao_hp_p, price: 15 },
    { item: global.item_database.pocao_hp_g, price: 45 },
    { item: global.item_database.pocao_mana_p, price: 20 },
    { item: global.item_database.pocao_mana_g, price: 50 },
    { item: global.item_database.frasco_captura, price: 25 },
    { item: global.item_database.elixir_alquimico, price: 60 }
];
