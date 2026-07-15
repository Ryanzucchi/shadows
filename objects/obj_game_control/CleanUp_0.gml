/// @description Limpeza de Estruturas de Dados
if (ds_exists(global.effectiveness, ds_type_grid)) {
    ds_grid_destroy(global.effectiveness);
    show_debug_message("Grid global.effectiveness destruído com sucesso (Clean Up).");
}
