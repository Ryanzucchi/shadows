/// @description Limpeza do Projétil
if (ds_exists(hit_list, ds_type_list)) {
    ds_list_destroy(hit_list);
}
