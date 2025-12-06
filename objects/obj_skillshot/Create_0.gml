attack_data = undefined;
owner = noone;
target_type = noone;

dist_traveled = 0;
life_timer = 0; // Para ataques estáticos (area/self)
max_life = 60;  // Duração padrão para areas

hit_list = ds_list_create(); // Para garantir que area/cone só bata 1 vez por tick ou por cast