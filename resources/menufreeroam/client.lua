-- client.lua


-- =========================================================
-- MENU
-- =========================================================

local MENU = {
    open = false,
    pushed = false,
    page = "main",
    options = {}
}


local UI_LAYER = "HudGamerList"


-- =========================================================
-- SPAWNED ENTITIES
-- =========================================================

local SPAWNED_HORSE = 0
local SPAWNED_VEHICLE = 0


-- =========================================================
-- GXT STRINGS
-- =========================================================

local GXT = {
    main_title = "RDRMP_MENU_TITLE",
    main_desc = "RDRMP_MENU_DESC",

    skins_title = "RDRMP_SKINS_TITLE",
    skins_desc = "RDRMP_SKINS_DESC",

    weapons_title = "RDRMP_WEAPONS_TITLE",
    weapons_desc = "RDRMP_WEAPONS_DESC",

    horses_title = "RDRMP_HORSES_TITLE",
    horses_desc = "RDRMP_HORSES_DESC",

    vehicles_title = "RDRMP_VEHICLES_TITLE",
    vehicles_desc = "RDRMP_VEHICLES_DESC"
}


local close_menu
local go_to_page


-- =========================================================
-- UTILIDADES
-- =========================================================

local function print_message(_text)

    natives.builtin.printstring(_text)
    natives.builtin.printnl()
end


local function notify(_text)

    natives.hud.print_small_b(
        _text,
        0.5,
        true,
        0,
        0,
        0,
        0
    )
end


local function register_strings()

    natives.extended.ui_add_string(
        GXT.main_title,
        "RDRMP MENU"
    )

    natives.extended.ui_add_string(
        GXT.main_desc,
        "Selecciona una opcion"
    )


    natives.extended.ui_add_string(
        GXT.skins_title,
        "SKINS"
    )

    natives.extended.ui_add_string(
        GXT.skins_desc,
        "Selecciona una skin"
    )


    natives.extended.ui_add_string(
        GXT.weapons_title,
        "ARMAS"
    )

    natives.extended.ui_add_string(
        GXT.weapons_desc,
        "Selecciona un arma"
    )


    natives.extended.ui_add_string(
        GXT.horses_title,
        "CABALLOS"
    )

    natives.extended.ui_add_string(
        GXT.horses_desc,
        "Selecciona un caballo"
    )


    natives.extended.ui_add_string(
        GXT.vehicles_title,
        "VEHICULOS"
    )

    natives.extended.ui_add_string(
        GXT.vehicles_desc,
        "Selecciona un vehiculo"
    )
end


-- =========================================================
-- HUD GAMER LIST
-- =========================================================

local function push_hud_gamer_list()

    if MENU.pushed then
        return
    end


    natives.ui.ui_push(
        UI_LAYER
    )


    natives.ui.ui_include(
        UI_LAYER
    )


    natives.ui.ui_enable(
        UI_LAYER
    )


    natives.ui.ui_activate(
        UI_LAYER
    )


    MENU.pushed = true
end


local function reset_items()

    natives.net_ui.net_player_list_reset()


    natives.net_ui.net_player_list_set_template(
        4
    )


    natives.net_ui.net_player_list_set_header(
        1,
        "Common_Null"
    )


    natives.net_ui.net_player_list_set_header(
        2,
        "Common_Null"
    )


    natives.net_ui.net_player_list_set_header(
        3,
        "Common_Null"
    )


    natives.net_ui.net_player_list_set_header(
        4,
        "Common_Null"
    )
end


-- =========================================================
-- SPAWN POSITION
-- =========================================================

local function get_spawn_transform()

    local player_actor =
        natives.actor.get_player_actor(-1)


    if player_actor == 0 then
        return nil, nil
    end


    local player_position =
        natives.actor.get_position(
            player_actor
        )


    local heading =
        natives.actor.get_heading(
            player_actor
        )


    local radians =
        heading * (math.pi / 180.0)


    local forward = vector3(
        -math.cos(radians),
        0.0,
        math.sin(radians)
    )


    local spawn_position =
        player_position +
        (forward * 3.0)


    spawn_position.y =
        spawn_position.y + 0.2


    local rotation = vector3(
        0.0,
        heading,
        0.0
    )


    return spawn_position, rotation
end


-- =========================================================
-- DESTROY HORSE
-- =========================================================

local function destroy_spawned_horse()

    if SPAWNED_HORSE == 0 then
        return
    end


    if natives.entity.is_actor_valid(
        SPAWNED_HORSE
    ) then

        natives.object.destroy_actor(
            SPAWNED_HORSE
        )
    end


    SPAWNED_HORSE = 0
end


-- =========================================================
-- DESTROY VEHICLE
-- =========================================================

local function destroy_spawned_vehicle()

    if SPAWNED_VEHICLE == 0 then
        return
    end


    if natives.entity.is_actor_valid(
        SPAWNED_VEHICLE
    ) then

        natives.object.destroy_actor(
            SPAWNED_VEHICLE
        )
    end


    SPAWNED_VEHICLE = 0
end


-- =========================================================
-- SKINS
-- =========================================================

local function change_skin(
    _model,
    _name
)

    natives.object.switch_player_to_enum(
        _model,
        0
    )


    notify(
        "Skin: " .. _name
    )


    print_message(
        "Skin seleccionada: " .. _name
    )
end


-- =========================================================
-- WEAPONS
-- =========================================================

local function give_weapon(
    _weapon_enum,
    _name
)

    local player_actor =
        natives.actor.get_player_actor(-1)


    if player_actor == 0 then
        return
    end


    natives.inventory.give_weapon_to_actor(
        player_actor,
        _weapon_enum,
        0.0,
        true,
        false
    )


    local ammo_type =
        natives.weapon.get_ammo_enum(
            _weapon_enum
        )


    natives.inventory.actor_set_inv_ammo(
        player_actor,
        ammo_type,
        9999.0,
        false
    )


    notify(
        "Arma: " .. _name
    )


    print_message(
        "Arma entregada: " .. _name
    )
end


local function give_all_weapons()

    local player_actor =
        natives.actor.get_player_actor(-1)


    if player_actor == 0 then
        return
    end


    for weapon_enum = 0, 37 do

        natives.inventory.give_weapon_to_actor(
            player_actor,
            weapon_enum,
            0.0,
            false,
            false
        )


        local ammo_type =
            natives.weapon.get_ammo_enum(
                weapon_enum
            )


        natives.inventory.actor_set_inv_ammo(
            player_actor,
            ammo_type,
            9999.0,
            false
        )
    end


    notify(
        "Todas las armas"
    )


    print_message(
        "Todas las armas entregadas"
    )
end


-- =========================================================
-- HORSES
-- =========================================================

local function spawn_horse(
    _model,
    _name
)

    local layout =
        natives.object.find_named_layout(
            "PlayerLayout"
        )


    if layout == 0 then

        notify(
            "PlayerLayout no encontrado"
        )

        return
    end


    local spawn_position
    local rotation


    spawn_position,
    rotation =
        get_spawn_transform()


    if not spawn_position then

        notify(
            "Jugador no disponible"
        )

        return
    end


    destroy_spawned_horse()


    local horse =
        natives.object.create_actor_in_layout(
            layout,
            "rdrmp_menu_horse",
            _model,
            spawn_position,
            rotation
        )


    if horse == 0 then

        notify(
            "No se pudo crear el caballo"
        )

        return
    end


    SPAWNED_HORSE = horse


    natives.entity.set_actor_rideable(
        horse,
        true
    )


    natives.actor.set_allow_ride_by_player(
        horse,
        true
    )


    notify(
        "Caballo: " .. _name
    )


    print_message(
        "Caballo creado: " .. _name
    )
end


-- =========================================================
-- VEHICLES
-- =========================================================

local function spawn_vehicle(
    _model,
    _name
)

    local layout =
        natives.object.find_named_layout(
            "PlayerLayout"
        )


    if layout == 0 then

        notify(
            "PlayerLayout no encontrado"
        )

        return
    end


    local spawn_position
    local rotation


    spawn_position,
    rotation =
        get_spawn_transform()


    if not spawn_position then

        notify(
            "Jugador no disponible"
        )

        return
    end


    destroy_spawned_vehicle()


    local vehicle =
        natives.object.create_actor_in_layout(
            layout,
            "rdrmp_menu_vehicle",
            _model,
            spawn_position,
            rotation
        )


    if vehicle == 0 then

        notify(
            "No se pudo crear el vehiculo"
        )

        return
    end


    SPAWNED_VEHICLE = vehicle


    natives.vehicles.start_vehicle(
        vehicle
    )


    natives.vehicles.set_vehicle_engine_running(
        vehicle,
        true
    )


    natives.vehicles.set_vehicle_allowed_to_drive(
        vehicle,
        true
    )


    natives.vehicles.enable_vehicle_seat(
        vehicle,
        0,
        true
    )


    natives.vehicles.set_vehicle_passengers_allowed(
        vehicle,
        true
    )


    local player_actor =
        natives.actor.get_player_actor(-1)


    if player_actor ~= 0 then

        natives.vehicles.set_actor_in_vehicle(
            player_actor,
            vehicle,
            0
        )
    end


    notify(
        "Vehiculo: " .. _name
    )


    print_message(
        "Vehiculo creado: " .. _name
    )
end


-- =========================================================
-- MAIN OPTIONS
-- =========================================================

local function get_main_options()

    return {

        {
            text = "Skins",

            action = function()

                go_to_page(
                    "skins"
                )
            end
        },


        {
            text = "Armas",

            action = function()

                go_to_page(
                    "weapons"
                )
            end
        },


        {
            text = "Caballos",

            action = function()

                go_to_page(
                    "horses"
                )
            end
        },


        {
            text = "Vehiculos",

            action = function()

                go_to_page(
                    "vehicles"
                )
            end
        },


        {
            text = "Eliminar caballo",

            action = function()

                destroy_spawned_horse()

                notify(
                    "Caballo eliminado"
                )
            end
        },


        {
            text = "Eliminar vehiculo",

            action = function()

                destroy_spawned_vehicle()

                notify(
                    "Vehiculo eliminado"
                )
            end
        },


        {
            text = "Cerrar",

            action = function()

                close_menu()
            end
        }
    }
end


-- =========================================================
-- SKIN OPTIONS
-- =========================================================

local function get_skin_options()

    return {

        {
            text = "MP Player 01",
            action = function()
                change_skin(837, "MP Player 01")
            end
        },

        {
            text = "MP Player 02",
            action = function()
                change_skin(838, "MP Player 02")
            end
        },

        {
            text = "MP Player 03",
            action = function()
                change_skin(839, "MP Player 03")
            end
        },

        {
            text = "MP Player 04",
            action = function()
                change_skin(840, "MP Player 04")
            end
        },

        {
            text = "MP Player 05",
            action = function()
                change_skin(841, "MP Player 05")
            end
        },

        {
            text = "MP Player 06",
            action = function()
                change_skin(842, "MP Player 06")
            end
        },

        {
            text = "MP Player 07",
            action = function()
                change_skin(843, "MP Player 07")
            end
        },

        {
            text = "MP Player 08",
            action = function()
                change_skin(844, "MP Player 08")
            end
        },

        {
            text = "MP Player 09",
            action = function()
                change_skin(847, "MP Player 09")
            end
        },

        {
            text = "MP Player 10",
            action = function()
                change_skin(851, "MP Player 10")
            end
        },

        {
            text = "MP Player 11",
            action = function()
                change_skin(849, "MP Player 11")
            end
        },

        {
            text = "MP Player 12",
            action = function()
                change_skin(850, "MP Player 12")
            end
        },

        {
            text = "MP Player 13",
            action = function()
                change_skin(848, "MP Player 13")
            end
        },

        {
            text = "MP Player 14",
            action = function()
                change_skin(852, "MP Player 14")
            end
        },

        {
            text = "MP Player 15",
            action = function()
                change_skin(845, "MP Player 15")
            end
        },

        {
            text = "MP Player 16",
            action = function()
                change_skin(846, "MP Player 16")
            end
        },

        {
            text = "MP Player 17",
            action = function()
                change_skin(859, "MP Player 17")
            end
        },

        {
            text = "MP Player 18",
            action = function()
                change_skin(857, "MP Player 18")
            end
        },

        {
            text = "MP Player 19",
            action = function()
                change_skin(853, "MP Player 19")
            end
        },

        {
            text = "MP Player 20",
            action = function()
                change_skin(855, "MP Player 20")
            end
        },

        {
            text = "MP Player 21",
            action = function()
                change_skin(856, "MP Player 21")
            end
        },

        {
            text = "MP Player 22",
            action = function()
                change_skin(858, "MP Player 22")
            end
        },

        {
            text = "MP Player 23",
            action = function()
                change_skin(854, "MP Player 23")
            end
        },

        {
            text = "MP Player 24",
            action = function()
                change_skin(860, "MP Player 24")
            end
        },

        {
            text = "MP Player 25",
            action = function()
                change_skin(861, "MP Player 25")
            end
        },

        {
            text = "MP Player 26",
            action = function()
                change_skin(864, "MP Player 26")
            end
        },

        {
            text = "MP Player 27",
            action = function()
                change_skin(862, "MP Player 27")
            end
        },

        {
            text = "MP Player 28",
            action = function()
                change_skin(868, "MP Player 28")
            end
        },

        {
            text = "MP Player 29",
            action = function()
                change_skin(867, "MP Player 29")
            end
        },

        {
            text = "MP Player 30",
            action = function()
                change_skin(863, "MP Player 30")
            end
        },

        {
            text = "MP Player 31",
            action = function()
                change_skin(865, "MP Player 31")
            end
        },

        {
            text = "MP Player 32",
            action = function()
                change_skin(866, "MP Player 32")
            end
        },

        {
            text = "MP Player 33",
            action = function()
                change_skin(871, "MP Player 33")
            end
        },

        {
            text = "MP Player 34",
            action = function()
                change_skin(876, "MP Player 34")
            end
        },

        {
            text = "MP Player 35",
            action = function()
                change_skin(872, "MP Player 35")
            end
        },

        {
            text = "MP Player 36",
            action = function()
                change_skin(873, "MP Player 36")
            end
        },

        {
            text = "MP Player 37",
            action = function()
                change_skin(874, "MP Player 37")
            end
        },

        {
            text = "MP Player 38",
            action = function()
                change_skin(875, "MP Player 38")
            end
        },

        {
            text = "MP Player 39",
            action = function()
                change_skin(870, "MP Player 39")
            end
        },

        {
            text = "MP Player 40",
            action = function()
                change_skin(869, "MP Player 40")
            end
        },

        {
            text = "MP Player 41",
            action = function()
                change_skin(881, "MP Player 41")
            end
        },

        {
            text = "MP Player 42",
            action = function()
                change_skin(882, "MP Player 42")
            end
        },

        {
            text = "MP Player 43",
            action = function()
                change_skin(878, "MP Player 43")
            end
        },

        {
            text = "MP Player 44",
            action = function()
                change_skin(877, "MP Player 44")
            end
        },

        {
            text = "MP Player 45",
            action = function()
                change_skin(879, "MP Player 45")
            end
        },

        {
            text = "MP Player 46",
            action = function()
                change_skin(883, "MP Player 46")
            end
        },

        {
            text = "MP Player 47",
            action = function()
                change_skin(884, "MP Player 47")
            end
        },

        {
            text = "MP Player 48",
            action = function()
                change_skin(880, "MP Player 48")
            end
        },

        {
            text = "MP Player 49",
            action = function()
                change_skin(885, "MP Player 49")
            end
        },

        {
            text = "MP Player 50",
            action = function()
                change_skin(886, "MP Player 50")
            end
        },

        {
            text = "MP Player 51",
            action = function()
                change_skin(889, "MP Player 51")
            end
        },

        {
            text = "MP Player 52",
            action = function()
                change_skin(890, "MP Player 52")
            end
        },

        {
            text = "MP Player 53",
            action = function()
                change_skin(892, "MP Player 53")
            end
        },

        {
            text = "MP Player 54",
            action = function()
                change_skin(891, "MP Player 54")
            end
        },

        {
            text = "MP Player 55",
            action = function()
                change_skin(887, "MP Player 55")
            end
        },

        {
            text = "MP Player 56",
            action = function()
                change_skin(888, "MP Player 56")
            end
        },

        {
            text = "MP Player 57",
            action = function()
                change_skin(893, "MP Player 57")
            end
        },

        {
            text = "MP Player 58",
            action = function()
                change_skin(894, "MP Player 58")
            end
        },

        {
            text = "MP Player 59",
            action = function()
                change_skin(895, "MP Player 59")
            end
        },

        {
            text = "MP Player 60",
            action = function()
                change_skin(900, "MP Player 60")
            end
        },

        {
            text = "MP Player 61",
            action = function()
                change_skin(898, "MP Player 61")
            end
        },

        {
            text = "MP Player 62",
            action = function()
                change_skin(896, "MP Player 62")
            end
        },

        {
            text = "MP Player 63",
            action = function()
                change_skin(899, "MP Player 63")
            end
        },

        {
            text = "MP Player 64",
            action = function()
                change_skin(897, "MP Player 64")
            end
        },

        {
            text = "MP Player 65",
            action = function()
                change_skin(903, "MP Player 65")
            end
        },

        {
            text = "MP Player 66",
            action = function()
                change_skin(901, "MP Player 66")
            end
        },

        {
            text = "MP Player 67",
            action = function()
                change_skin(902, "MP Player 67")
            end
        },

        {
            text = "MP Player 68",
            action = function()
                change_skin(906, "MP Player 68")
            end
        },

        {
            text = "MP Player 69",
            action = function()
                change_skin(908, "MP Player 69")
            end
        },

        {
            text = "MP Player 70",
            action = function()
                change_skin(907, "MP Player 70")
            end
        },

        {
            text = "MP Player 71",
            action = function()
                change_skin(904, "MP Player 71")
            end
        },

        {
            text = "MP Player 72",
            action = function()
                change_skin(905, "MP Player 72")
            end
        },

        {
            text = "MP Player 73",
            action = function()
                change_skin(915, "MP Player 73")
            end
        },

        {
            text = "MP Player 74",
            action = function()
                change_skin(912, "MP Player 74")
            end
        },

        {
            text = "MP Player 75",
            action = function()
                change_skin(916, "MP Player 75")
            end
        },

        {
            text = "MP Player 76",
            action = function()
                change_skin(914, "MP Player 76")
            end
        },

        {
            text = "MP Player 77",
            action = function()
                change_skin(913, "MP Player 77")
            end
        },

        {
            text = "MP Player 78",
            action = function()
                change_skin(940, "MP Player 78")
            end
        },

        {
            text = "MP Player 79",
            action = function()
                change_skin(909, "MP Player 79")
            end
        },

        {
            text = "MP Player 80",
            action = function()
                change_skin(911, "MP Player 80")
            end
        },

        {
            text = "MP Player 81",
            action = function()
                change_skin(910, "MP Player 81")
            end
        },

        {
            text = "MP Player 82",
            action = function()
                change_skin(922, "MP Player 82")
            end
        },

        {
            text = "MP Player 83",
            action = function()
                change_skin(923, "MP Player 83")
            end
        },

        {
            text = "MP Player 84",
            action = function()
                change_skin(924, "MP Player 84")
            end
        },

        {
            text = "MP Player 85",
            action = function()
                change_skin(925, "MP Player 85")
            end
        },

        {
            text = "MP Player 86",
            action = function()
                change_skin(928, "MP Player 86")
            end
        },

        {
            text = "MP Player 87",
            action = function()
                change_skin(929, "MP Player 87")
            end
        },

        {
            text = "MP Player 88",
            action = function()
                change_skin(930, "MP Player 88")
            end
        },

        {
            text = "MP Player 89",
            action = function()
                change_skin(931, "MP Player 89")
            end
        },

        {
            text = "MP Player 90",
            action = function()
                change_skin(927, "MP Player 90")
            end
        },

        {
            text = "MP Player 91",
            action = function()
                change_skin(924, "MP Player 91")
            end
        },

        {
            text = "MP Player 92",
            action = function()
                change_skin(918, "MP Player 92")
            end
        },

        {
            text = "MP Player 93",
            action = function()
                change_skin(917, "MP Player 93")
            end
        },

        {
            text = "MP Player 94",
            action = function()
                change_skin(920, "MP Player 94")
            end
        },

        {
            text = "MP Player 95",
            action = function()
                change_skin(920, "MP Player 95")
            end
        },

        {
            text = "MP Player 96",
            action = function()
                change_skin(939, "MP Player 96")
            end
        },

        {
            text = "MP Player 97",
            action = function()
                change_skin(925, "MP Player 97")
            end
        },

        {
            text = "MP Player 98",
            action = function()
                change_skin(933, "MP Player 98")
            end
        },

        {
            text = "MP Player 99",
            action = function()
                change_skin(926, "MP Player 99")
            end
        },

        {
            text = "MP Player 100",
            action = function()
                change_skin(936, "MP Player 100")
            end
        },

        {
            text = "MP Player 101",
            action = function()
                change_skin(938, "MP Player 101")
            end
        },

        {
            text = "MP Player 102",
            action = function()
                change_skin(937, "MP Player 102")
            end
        },

        {
            text = "MP Player 103",
            action = function()
                change_skin(919, "MP Player 103")
            end
        },

        {
            text = "MP Player 104",
            action = function()
                change_skin(921, "MP Player 104")
            end
        },

        {
            text = "MP Player 105",
            action = function()
                change_skin(932, "MP Player 105")
            end
        },

        {
            text = "MP Player 106",
            action = function()
                change_skin(934, "MP Player 106")
            end
        },

        {
            text = "MP Player 107",
            action = function()
                change_skin(935, "MP Player 107")
            end
        },

        {
            text = "Volver",
            action = function()
                go_to_page("main")
            end
        }
    }
end


-- =========================================================
-- WEAPON OPTION HELPER
-- =========================================================

local function create_weapon_option(
    _text,
    _weapon_enum,
    _name
)

    return {
        text = _text,

        action = function()

            give_weapon(
                _weapon_enum,
                _name
            )
        end
    }
end


-- =========================================================
-- PISTOLS
-- =========================================================

local function get_pistol_options()

    return {

        create_weapon_option(
            "Volcanic Pistol",
            0,
            "Volcanic Pistol"
        ),

        create_weapon_option(
            "Semi-Auto Pistol",
            1,
            "Semi-Auto Pistol"
        ),

        create_weapon_option(
            "High Power Pistol",
            2,
            "High Power Pistol"
        ),

        create_weapon_option(
            "Mauser Pistol",
            3,
            "Mauser Pistol"
        ),

        {
            text = "Volver",

            action = function()
                go_to_page("weapons")
            end
        }
    }
end


-- =========================================================
-- REVOLVERS
-- =========================================================

local function get_revolver_options()

    return {

        create_weapon_option(
            "Cattleman Revolver",
            4,
            "Cattleman Revolver"
        ),

        create_weapon_option(
            "Schofield Revolver",
            5,
            "Schofield Revolver"
        ),

        create_weapon_option(
            "Double Action Revolver",
            6,
            "Double Action Revolver"
        ),

        create_weapon_option(
            "LeMat Revolver",
            7,
            "LeMat Revolver"
        ),

        {
            text = "Volver",

            action = function()
                go_to_page("weapons")
            end
        }
    }
end


-- =========================================================
-- REPEATERS
-- =========================================================

local function get_repeater_options()

    return {

        create_weapon_option(
            "Carbine Repeater",
            8,
            "Carbine Repeater"
        ),

        create_weapon_option(
            "Winchester Repeater",
            9,
            "Winchester Repeater"
        ),

        create_weapon_option(
            "Henry Repeater",
            10,
            "Henry Repeater"
        ),

        create_weapon_option(
            "Evans Repeater",
            11,
            "Evans Repeater"
        ),

        {
            text = "Volver",

            action = function()
                go_to_page("weapons")
            end
        }
    }
end


-- =========================================================
-- RIFLES
-- =========================================================

local function get_rifle_options()

    return {

        create_weapon_option(
            "Springfield Rifle",
            12,
            "Springfield Rifle"
        ),

        create_weapon_option(
            "Bolt Action Rifle",
            13,
            "Bolt Action Rifle"
        ),

        create_weapon_option(
            "Buffalo Rifle",
            14,
            "Buffalo Rifle"
        ),

        create_weapon_option(
            "Anti-Tank Rifle",
            31,
            "Anti-Tank Rifle"
        ),

        {
            text = "Volver",

            action = function()
                go_to_page("weapons")
            end
        }
    }
end


-- =========================================================
-- SHOTGUNS
-- =========================================================

local function get_shotgun_options()

    return {

        create_weapon_option(
            "Sawed-Off Shotgun",
            15,
            "Sawed-Off Shotgun"
        ),

        create_weapon_option(
            "Double Barrel Shotgun",
            16,
            "Double Barrel Shotgun"
        ),

        create_weapon_option(
            "Pump Action Shotgun",
            17,
            "Pump Action Shotgun"
        ),

        create_weapon_option(
            "Semi-Auto Shotgun",
            18,
            "Semi-Auto Shotgun"
        ),

        {
            text = "Volver",

            action = function()
                go_to_page("weapons")
            end
        }
    }
end


-- =========================================================
-- SNIPER RIFLES
-- =========================================================

local function get_sniper_options()

    return {

        create_weapon_option(
            "Rolling Block Rifle",
            19,
            "Rolling Block Rifle"
        ),

        create_weapon_option(
            "Carcano Rifle",
            20,
            "Carcano Rifle"
        ),

        {
            text = "Volver",

            action = function()
                go_to_page("weapons")
            end
        }
    }
end


-- =========================================================
-- MELEE
-- =========================================================

local function get_melee_options()

    return {

        create_weapon_option(
            "Knife",
            22,
            "Knife"
        ),

        {
            text = "Volver",

            action = function()
                go_to_page("weapons")
            end
        }
    }
end


-- =========================================================
-- THROWABLES
-- =========================================================

local function get_throwable_options()

    return {

        create_weapon_option(
            "Fire Bottle",
            23,
            "Fire Bottle"
        ),

        create_weapon_option(
            "Dynamite",
            24,
            "Dynamite"
        ),

        create_weapon_option(
            "Throwing Knife",
            25,
            "Throwing Knife"
        ),

        create_weapon_option(
            "Tomahawk",
            29,
            "Tomahawk"
        ),

        {
            text = "Volver",

            action = function()
                go_to_page("weapons")
            end
        }
    }
end


-- =========================================================
-- SPECIAL WEAPONS
-- =========================================================

local function get_special_weapon_options()

    return {

        create_weapon_option(
            "Lasso",
            21,
            "Lasso"
        ),

        create_weapon_option(
            "Gatling",
            26,
            "Gatling"
        ),

        create_weapon_option(
            "Browning",
            27,
            "Browning"
        ),

        create_weapon_option(
            "Cannon",
            28,
            "Cannon"
        ),

        create_weapon_option(
            "Short Bow",
            30,
            "Short Bow"
        ),

        {
            text = "Volver",

            action = function()
                go_to_page("weapons")
            end
        }
    }
end


-- =========================================================
-- DLC / UNDEAD
-- =========================================================

local function get_dlc_weapon_options()

    return {

        create_weapon_option(
            "Zombie Spit",
            32,
            "Zombie Spit"
        ),

        create_weapon_option(
            "Torch",
            33,
            "Torch"
        ),

        create_weapon_option(
            "Blunderbuss",
            34,
            "Blunderbuss"
        ),

        create_weapon_option(
            "Holy Water",
            35,
            "Holy Water"
        ),

        create_weapon_option(
            "Zombie Bait",
            36,
            "Zombie Bait"
        ),

        create_weapon_option(
            "Zombie Boom Bait",
            37,
            "Zombie Boom Bait"
        ),

        {
            text = "Volver",

            action = function()
                go_to_page("weapons")
            end
        }
    }
end


-- =========================================================
-- WEAPON CATEGORIES
-- =========================================================

local function get_weapon_options()

    return {

        {
            text = "Dar todas las armas",

            action = function()
                give_all_weapons()
            end
        },


        {
            text = "Pistolas",

            action = function()
                go_to_page("weapon_pistols")
            end
        },


        {
            text = "Revolveres",

            action = function()
                go_to_page("weapon_revolvers")
            end
        },


        {
            text = "Repetidores",

            action = function()
                go_to_page("weapon_repeaters")
            end
        },


        {
            text = "Rifles",

            action = function()
                go_to_page("weapon_rifles")
            end
        },


        {
            text = "Escopetas",

            action = function()
                go_to_page("weapon_shotguns")
            end
        },


        {
            text = "Francotiradores",

            action = function()
                go_to_page("weapon_snipers")
            end
        },


        {
            text = "Cuerpo a cuerpo",

            action = function()
                go_to_page("weapon_melee")
            end
        },


        {
            text = "Lanzables",

            action = function()
                go_to_page("weapon_throwables")
            end
        },


        {
            text = "Armas especiales",

            action = function()
                go_to_page("weapon_special")
            end
        },


        {
            text = "DLC / Undead",

            action = function()
                go_to_page("weapon_dlc")
            end
        },


        {
            text = "Volver",

            action = function()
                go_to_page("main")
            end
        }
    }
end


-- =========================================================
-- HORSE OPTIONS
-- =========================================================

local function get_horse_options()

    return {

        {
            text = "Horse 01",

            action = function()

                spawn_horse(
                    976,
                    "Horse 01"
                )
            end
        },


        {
            text = "Horse 02",

            action = function()

                spawn_horse(
                    977,
                    "Horse 02"
                )
            end
        },


        {
            text = "Horse 03",

            action = function()

                spawn_horse(
                    978,
                    "Horse 03"
                )
            end
        },


        {
            text = "Horse 04",

            action = function()

                spawn_horse(
                    979,
                    "Horse 04"
                )
            end
        },


        {
            text = "Horse 05",

            action = function()

                spawn_horse(
                    980,
                    "Horse 05"
                )
            end
        },


        {
            text = "Horse 06",

            action = function()

                spawn_horse(
                    981,
                    "Horse 06"
                )
            end
        },


        {
            text = "Mula 01",

            action = function()

                spawn_horse(
                    1000,
                    "Mula 01"
                )
            end
        },


        {
            text = "Mula 02",

            action = function()

                spawn_horse(
                    1001,
                    "Mula 02"
                )
            end
        },


        {
            text = "Volver",

            action = function()

                go_to_page(
                    "main"
                )
            end
        }
    }
end


-- =========================================================
-- VEHICLE OPTIONS
-- =========================================================

local function get_vehicle_options()

    return {

        {
            text = "Stagecoach",

            action = function()

                spawn_vehicle(
                    1177,
                    "Stagecoach"
                )
            end
        },


        {
            text = "Stagecoach 002",

            action = function()

                spawn_vehicle(
                    1178,
                    "Stagecoach 002"
                )
            end
        },


        {
            text = "Stagecoach 003",

            action = function()

                spawn_vehicle(
                    1179,
                    "Stagecoach 003"
                )
            end
        },


        {
            text = "Car",

            action = function()

                spawn_vehicle(
                    1194,
                    "Car"
                )
            end
        },


        {
            text = "Truck",

            action = function()

                spawn_vehicle(
                    1193,
                    "Truck"
                )
            end
        },


        {
            text = "Wagon",

            action = function()

                spawn_vehicle(
                    1195,
                    "Wagon"
                )
            end
        },


        {
            text = "Coach",

            action = function()

                spawn_vehicle(
                    1202,
                    "Coach"
                )
            end
        },


        {
            text = "Volver",

            action = function()

                go_to_page(
                    "main"
                )
            end
        }
    }
end


-- =========================================================
-- UPDATE PAGE
-- =========================================================

local function update_page_options()

    if MENU.page == "main" then

        MENU.options =
            get_main_options()


    elseif MENU.page == "skins" then

        MENU.options =
            get_skin_options()


    elseif MENU.page == "weapons" then

        MENU.options =
            get_weapon_options()


    elseif MENU.page == "horses" then

        MENU.options =
            get_horse_options()


    elseif MENU.page == "vehicles" then

        MENU.options =
            get_vehicle_options()

	elseif MENU.page == "weapon_pistols" then

    MENU.options =
        get_pistol_options()


elseif MENU.page == "weapon_revolvers" then

    MENU.options =
        get_revolver_options()


elseif MENU.page == "weapon_repeaters" then

    MENU.options =
        get_repeater_options()


elseif MENU.page == "weapon_rifles" then

    MENU.options =
        get_rifle_options()


elseif MENU.page == "weapon_shotguns" then

    MENU.options =
        get_shotgun_options()


elseif MENU.page == "weapon_snipers" then

    MENU.options =
        get_sniper_options()


elseif MENU.page == "weapon_melee" then

    MENU.options =
        get_melee_options()


elseif MENU.page == "weapon_throwables" then

    MENU.options =
        get_throwable_options()


elseif MENU.page == "weapon_special" then

    MENU.options =
        get_special_weapon_options()


elseif MENU.page == "weapon_dlc" then

    MENU.options =
        get_dlc_weapon_options()


    else

        MENU.page = "main"

        MENU.options =
            get_main_options()
    end
end


-- =========================================================
-- PAGE TITLE
-- =========================================================

local function get_page_title()

    if MENU.page == "skins" then
        return GXT.skins_title
    end


    if MENU.page == "weapons" then
        return GXT.weapons_title
    end


    if MENU.page == "horses" then
        return GXT.horses_title
    end


    if MENU.page == "vehicles" then
        return GXT.vehicles_title
    end


    return GXT.main_title
end


-- =========================================================
-- PAGE DESCRIPTION
-- =========================================================

local function get_page_description()

    if MENU.page == "skins" then
        return GXT.skins_desc
    end


    if MENU.page == "weapons" then
        return GXT.weapons_desc
    end


    if MENU.page == "horses" then
        return GXT.horses_desc
    end


    if MENU.page == "vehicles" then
        return GXT.vehicles_desc
    end


    return GXT.main_desc
end


-- =========================================================
-- BUILD MENU
-- =========================================================

local function build_menu()

    update_page_options()


    reset_items()


    natives.net_ui.net_player_list_set_title(
        get_page_title()
    )


    natives.net_ui.net_player_list_set_description(
        get_page_description()
    )


    -- =====================================================
    -- IMPORTANTE
    --
    -- El segundo argumento de ADD_ITEM es el SLOT.
    --
    -- El menu nativo de RDR dibuja los items de esta forma:
    --
    -- Item 1 -> slot n-1
    -- Item 2 -> slot n-2
    -- Item 3 -> slot n-3
    -- ...
    -- Item n -> slot 0
    --
    -- NO pasar 0 a todos.
    -- =====================================================

    local option_count =
        #MENU.options


    for i = 1, option_count do

        local slot =
            option_count - i


        natives.net_ui.net_player_list_add_item(
            MENU.options[i].text,
            slot
        )
    end


    if option_count > 0 then

        natives.net_ui.net_player_list_set_highlight(
            0
        )
    end
end


-- =========================================================
-- GO TO PAGE
-- =========================================================

go_to_page = function(_page)

    MENU.page = _page


    update_page_options()


    if MENU.open then

        build_menu()


        natives.ui.ui_refresh(
            UI_LAYER
        )
    end
end


-- =========================================================
-- GET SELECTED OPTION
-- =========================================================

local function get_selected_option()

    local selected_index =
        natives.ui.ui_get_selected_index(
            UI_LAYER,
            true
        )


    if selected_index == nil then
        return nil
    end


    if selected_index < 0 then
        return nil
    end


    local option_index =
        selected_index + 1


    if option_index < 1 then
        return nil
    end


    if option_index > #MENU.options then
        return nil
    end


    return MENU.options[option_index]
end


-- =========================================================
-- SELECT
-- =========================================================

local function select_current()

    local option =
        get_selected_option()


    if option == nil then
        return
    end


    if option.action == nil then
        return
    end


    option.action()
end


-- =========================================================
-- OPEN
-- =========================================================

local function open_menu()

    if MENU.open then
        return
    end


    push_hud_gamer_list()


    MENU.open = true
    MENU.page = "main"


    update_page_options()


    build_menu()


    natives.hud.ui_enter(
        UI_LAYER
    )


    natives.ui.ui_focus(
        UI_LAYER
    )


    natives.ui.ui_refresh(
        UI_LAYER
    )
end


-- =========================================================
-- CLOSE
-- =========================================================

close_menu = function()

    if not MENU.open then
        return
    end


    MENU.open = false


    natives.net_ui.net_player_list_reset()


    if natives.ui.ui_isfocused(
        UI_LAYER
    ) then

        natives.ui.ui_unfocus(
            UI_LAYER
        )
    end


    natives.ui.ui_restore(
        UI_LAYER
    )


    natives.ui.ui_refresh(
        UI_LAYER
    )
end


-- =========================================================
-- INPUT
-- =========================================================

thread.create(function()

    while true do

        if not MENU.open then

            if natives.extended.is_key_pressed(
                "F5"
            ) then

                open_menu()
            end

        else

            -- HudGamerList maneja UP/DOWN.

            if natives.extended.is_key_pressed(
                "ESCAPE"
            ) then

                if MENU.page ~= "main" then

                    go_to_page(
                        "main"
                    )

                else

                    close_menu()
                end


            elseif natives.extended.is_key_pressed(
                "ENTER"
            ) then

                select_current()
            end
        end


        thread.wait(0)
    end
end)


-- =========================================================
-- RESOURCE START
-- =========================================================

register_strings()


-- =========================================================
-- RESOURCE STOP
-- =========================================================

event.add_handler(
    "core:on_resource_stop",
    function()

        close_menu()


        destroy_spawned_horse()
        destroy_spawned_vehicle()


        if MENU.pushed then

            natives.net_ui.net_player_list_reset()


            if natives.ui.ui_isfocused(
                UI_LAYER
            ) then

                natives.ui.ui_unfocus(
                    UI_LAYER
                )
            end


            natives.ui.ui_restore(
                UI_LAYER
            )


            natives.ui.ui_refresh(
                UI_LAYER
            )


            natives.ui.ui_pop(
                UI_LAYER
            )


            MENU.pushed = false
        end


        natives.extended.ui_remove_string(
            GXT.main_title
        )


        natives.extended.ui_remove_string(
            GXT.main_desc
        )


        natives.extended.ui_remove_string(
            GXT.skins_title
        )


        natives.extended.ui_remove_string(
            GXT.skins_desc
        )


        natives.extended.ui_remove_string(
            GXT.weapons_title
        )


        natives.extended.ui_remove_string(
            GXT.weapons_desc
        )


        natives.extended.ui_remove_string(
            GXT.horses_title
        )


        natives.extended.ui_remove_string(
            GXT.horses_desc
        )


        natives.extended.ui_remove_string(
            GXT.vehicles_title
        )


        natives.extended.ui_remove_string(
            GXT.vehicles_desc
        )
    end
)