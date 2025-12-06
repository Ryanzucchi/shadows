/// @description Animar e Destruir
sprite_index = spr_dust[face];

// Se a animação chegou ao fim, destrói o objeto
if (image_index >= image_number - 1) {
    instance_destroy();
}