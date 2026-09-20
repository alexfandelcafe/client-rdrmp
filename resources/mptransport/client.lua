--- mptransport Resource By Evil Blunt
-- This script mimics the transport script from Red Dead Redemptions Multiplayer.
-- Teleport to each region by using the Transport Post located in each region.
-- Thanks to K3rhos for RDRMP and help on Lua coding.

local mp_transport_propset = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
local mp_transport_mp_text = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
local mp_transport_propset_blip = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
local mp_transport_context = {0, 0, 0, 0}
local mp_transport_index = 1
local mp_transport_in_use = false
local mp_transport_loading_check = false
local request_time = 0

local mp_transport =
{
    {
        name = "henv_region",
        teleport = { pos = vector3(-785.9983, 92.3670, 2429.9731), h = 51.8 },
        propset = { pos = vector3(-932.066101, 90.825981, 2415.326172), h = -15.3529 },
    },
    {
        name = "thiv_region",
        teleport = { pos = vector3(101.9139, 73.1091, 2322.7966), h = -51.0 },
        propset = { pos = vector3(124.963326, 73.286247, 2298.677734), h = -88.1073 },
    },
    {
        name = "armv_region",
        teleport = { pos = vector3(-2174.8779, 16.2192, 2612.1245), h = -93.0 },
        propset = { pos = vector3(-2173.340332, 16.449478, 2632.490234), h = -91.7604 },
    },
    {
        name = "uprv_region",
        teleport = { pos = vector3(-283.5134, 84.4150, 2082.5632), h = -175.3 },
        propset = { pos = vector3(-191.371689, 83.413719, 2070.765625), h = -96.5107 },
    },
    {
        name = "mtpv_region",
        teleport = { pos = vector3(-415.4058, 152.5081, 1658.3547), h = 19.9 },
        propset = { pos = vector3(-416.563599, 151.118408, 1610.496094), h = -71.096939 },
    },
    {
        name = "blkv_region",
        teleport = { pos = vector3(735.8718, 78.3059, 1255.4010), h = 180.0 },
        propset = { pos = vector3(680.854614, 78.305878, 1343.675903), h = 91.267349 },
    },
    {
        name = "behv_region",
        teleport = { pos = vector3(-112.4753, 117.7625, 1404.6558), h = -45.2 },
        propset = { pos = vector3(-74.763901, 116.846123, 1412.886597), h = -117.407791 },
    },
    {
        name = "rwfv_region",
        teleport = { pos = vector3(-3222.7070, 16.2142, 2700.2136), h = 118.6 },
        propset = { pos = vector3(-3259.117920, 15.968304, 2705.893799), h = 5.335275 },
    },
    {
        name = "benv_region",
        teleport = { pos = vector3(-3689.5247, 8.0954, 3456.2620), h = 94.6 },
        propset = { pos = vector3(-3684.345947, 8.981985, 3489.655029), h = -0.885853 },
    },
    {
        name = "ratv_region",
        teleport = { pos = vector3(-3687.8213, 41.7716, 2147.8994), h = -45.8 },
        propset = { pos = vector3(-3639.435059, 42.275795, 2138.159668), h = 134.874023 },
    },
    {
        name = "plnv_region",
        teleport = { pos = vector3(-3135.2666, 43.3561, 3717.7427), h = -156.2 },
        propset = { pos = vector3(-3094.240479, 45.176472, 3765.177734), h = -90.082245 },
    },
    {
        name = "lshv_region",
        teleport = { pos = vector3(-1699.9269, 8.0, 4266.8486), h = 0.0 },
        propset = { pos = vector3(-1695.865479, 8.031379, 4263.268555), h = 1.107304 },
    },
    {
        name = "chuv_region",
        teleport = { pos = vector3(-2749.1995, 32.1254, 4266.1646), h = -74.0 },
        propset = { pos = vector3(-2759.820557, 32.125431, 4275.815430), h = -113.443886 },
    },
    {
        name = "escv_region",
        teleport = { pos = vector3(-4265.4355, 19.1414, 4475.8091), h = 31.9 },
        propset = { pos = vector3(-4279.045898, 18.363495, 4471.134277), h = 56.046673 },
    },
    {
        name = "casv_region",
        teleport = { pos = vector3(-770.4711, 12.8012, 3728.5217), h = 92.7 },
        propset = { pos = vector3(-790.903625, 13.013046, 3734.054688), h = 52.674507 },
    },
    {
        name = "emtv_region",
        teleport = { pos = vector3(-491.3854, 18.9276, 3884.1348), h = -123.3 },
        propset = { pos = vector3(-447.023132, 21.239044, 3926.397461), h = -94.874420 },
    },
    {
        name = "fodv_region",
        teleport = { pos = vector3(-702.4553, 63.2472, 3333.5334), h = -24.3 },
        propset = { pos = vector3(-692.897949, 63.247177, 3323.711914), h = -64.804680 },
    }
}


-- Some utility functions
local function GET_GAME_TIMER()

    return math.floor(natives.core.get_current_game_time() * 1000)
end



local function get_time_taken(time1, time2)

    return GET_GAME_TIMER() - time1 > time2
end



-- Clear all input contexts
local function remove_contexts()

    for i = 1, #mp_transport_context do

        if natives.game.is_script_use_context_valid(mp_transport_context[i]) then

            natives.game.release_script_use_context(mp_transport_context[i])
        end
    end
end



-- Check if at least one propset object is valid
local function is_mp_transport_propsets_valid()

    for i = 1, #mp_transport do

        if natives.object.is_object_valid(mp_transport_propset[i]) then

            return true
        end
    end

    return false
end



-- Check the distance between player position and every propsets
local function get_distance_to_mp_transport_propsets(_player_position, _distance)

    for i = 1, #mp_transport do

        local propset_position = natives.object.get_object_position(mp_transport_propset[i])

        if vector3.distance(_player_position, propset_position) <= _distance then

            return true
        end
    end

    return false
end



-- Create propsets if player is within 90.0m from it
-- if not the propset is deleted
local function create_mp_transport_propsets(_player_position)

    for i = 1, #mp_transport do

        if vector3.distance(_player_position, mp_transport[i].propset.pos) <= 90.0 then

            if not natives.object.is_object_valid(mp_transport_propset[i]) then

                local refGroupPath = "$/tune/refGroups/refgroups/mp_transport"

                natives.object.request_asset(refGroupPath, 7)

                local asset_id = natives.object.get_asset_id(refGroupPath, 7)

                natives.stream.streaming_request_propset(asset_id)

                while not natives.stream.streaming_is_propset_loaded(asset_id) do

                    thread.wait(0)
                end

                mp_transport_propset[i] = natives.object.create_propset_in_layout(natives.object.find_named_layout("PlayerLayout"), "", refGroupPath, mp_transport[i].propset.pos, vector3(0.0, mp_transport[i].propset.h, 0.0))

                mp_transport_propset_blip[i] = natives.hud.add_blip_for_object(mp_transport_propset[i], 396, 0.0, 2, 0)

                natives.hud.set_blip_name(mp_transport_propset_blip[i], "mp_TELEPORT_tis")
                natives.hud.set_blip_scale(mp_transport_propset_blip[i], 1.0)
                natives.hud.set_blip_priority(mp_transport_propset_blip[i], 2)
                natives.hud.set_blip_color(mp_transport_propset_blip[i], 1.0, 1.0, 1.0, 1.0)

                local objectLayout = natives.object.get_layout_from_object(mp_transport_propset[i])
                local objectIterator = natives.object.create_object_iterator(objectLayout)

                natives.object.iterate_in_layout(objectIterator, objectLayout)

                local iteratorObject = natives.object.start_object_iterator(objectIterator)

                while natives.object.is_object_valid(iteratorObject) do

                    natives.physics.set_physinst_frozen(natives.prop.get_physinst_from_object(iteratorObject), true)

                    iteratorObject = natives.object.object_iterator_next(objectIterator)
                end

                natives.object.destroy_iterator(objectIterator)

                if natives.stream.streaming_is_propset_loaded(asset_id) then

                    natives.stream.streaming_evict_propset(asset_id)
                end
            end

        else

            if natives.object.is_object_valid(mp_transport_propset[i]) then

                if natives.hud.is_blip_valid(mp_transport_propset_blip[i]) then

                    natives.hud.remove_blip(mp_transport_propset_blip[i])
                end

                natives.object.destroy_object(mp_transport_propset[i])
            end
        end
    end
end



-- Create a 3D text above the propset position under 20m
-- if not in this area, the text get deleted
local function create_mp_transport_mp_texts(_player_position, _camera_heading)

    for i = 1, #mp_transport do

        local propset_position = natives.object.get_object_position(mp_transport_propset[i])

        if vector3.distance(_player_position, propset_position) <= 20.0 then

            if not natives.object.is_object_valid(mp_transport_mp_text[i]) then

                mp_transport_mp_text[i] = natives.gravestone.create_mp_text(mp_transport_propset[i], "", "mp_TELEPORT_tis", vector3(propset_position.x, propset_position.y + 2.0, propset_position.z), vector3(0.0, _camera_heading, 0.0), 0xFCAF17)
            end
        else

            if natives.object.is_object_valid(mp_transport_mp_text[i]) then

                natives.object.destroy_object(mp_transport_mp_text[i])
            end
        end
    end
end



-- Update the 3D text rotation to always face the game camera heading
local function update_mp_transport_mp_texts(_camera_heading)

    for i = 1, #mp_transport do

        if natives.object.is_object_valid(mp_transport_mp_text[i]) then

            natives.object.set_object_orientation(mp_transport_mp_text[i], vector3(0.0, _camera_heading, 0.0))
        end
    end
end



-- Global update function
local function mp_transport_update()

    -- We make sure that 'multiplayer' string table is loaded
    -- it will be needed to get the GXT entries from original multiplayer
    if not natives.stringtable.has_string_table_loaded("multiplayer") then

        natives.stringtable.request_string_table("multiplayer")
    end

    local local_player_actor = natives.actor.get_player_actor(-1)
    local local_player_position = natives.object.get_object_position(local_player_actor)

    if not natives.hud.hud_is_fading() and natives.hud.hud_is_faded() and mp_transport_loading_check then

        remove_contexts()

	    natives.actor.teleport_actor_with_heading(local_player_actor, mp_transport[mp_transport_index].teleport.pos, mp_transport[mp_transport_index].teleport.h, true, true, true)
        natives.cam.camera_reset(0)

        if get_time_taken(request_time, 4000) then

            natives.hud.hud_fade_in_now(1.0, 0.0)

            mp_transport_loading_check = false
            mp_transport_in_use = false
            mp_transport_index = 1

            -- Restore player controls
            natives.actor.set_player_control(-1, true, 0, 0)
        end
    end

    create_mp_transport_propsets(local_player_position)

	if is_mp_transport_propsets_valid() then

        local game_camera = natives.cam.get_game_camera()
        local camera_heading = natives.object.get_object_heading(game_camera)

        update_mp_transport_mp_texts(camera_heading)

        if not mp_transport_in_use then

            create_mp_transport_mp_texts(local_player_position, camera_heading)

            if get_distance_to_mp_transport_propsets(local_player_position, 2.0) then

                if not natives.game.is_script_use_context_valid(mp_transport_context[1]) and not natives.vehicles.is_actor_riding_vehicle(local_player_actor) and not natives.riding.is_actor_riding(local_player_actor) then

                    mp_transport_context[1] = natives.game.add_script_use_context("mp_teleport", 30, "@GENERIC.USE", "", "", "", "", -1, "HUD_MENU_SELECT_MASTER")
                else

                    if natives.game.is_script_use_context_pressed(mp_transport_context[1]) then

                        mp_transport_index = 1
                        mp_transport_in_use = true

                        remove_contexts()

                        mp_transport_context[1] = natives.game.add_script_use_context("mp_exit_teleport", 10, "@GENERIC.USE", "", "", "", "", -1, "")
                        mp_transport_context[2] = natives.game.add_script_use_context(mp_transport[mp_transport_index].name, 10, "@UI.ACCEPT", "", "", "", "", -1, "")
                        mp_transport_context[3] = natives.game.add_script_use_context_stick("pass_coach_previousdest", 10, "@UI.NAVIGATE_UP", "", "", "", "", -1, "")
                        mp_transport_context[4] = natives.game.add_script_use_context_stick("pass_coach_nextdest", 10, "@UI.NAVIGATE_DOWN", "", "", "", "", -1, "")

                        -- Block player controls
                        natives.actor.set_player_control(-1, false, 1, 1)
                    end
                end
            else

                remove_contexts()
            end
        else

            -- Remove all 3D texts
            for i = 1, #mp_transport_mp_text do

                if natives.object.is_object_valid(mp_transport_mp_text[i]) then

                    natives.object.destroy_object(mp_transport_mp_text[i])
                end
            end

            -- Handle inputs
            local cancel_pressed = natives.game.is_script_use_context_pressed(mp_transport_context[1])
            local accept_pressed = natives.game.is_script_use_context_pressed(mp_transport_context[2])
            local up_pressed = natives.game.is_script_use_context_pressed(mp_transport_context[3])
            local down_pressed = natives.game.is_script_use_context_pressed(mp_transport_context[4])

            if cancel_pressed then

                remove_contexts()

                mp_transport_in_use = false
                mp_transport_index = 1

                -- Restore player controls
                natives.actor.set_player_control(-1, true, 0, 0)
            end

            if accept_pressed then

                if not natives.hud.hud_is_fading() then

                    natives.hud.hud_fade_to_loading_screen()
                end

				request_time = GET_GAME_TIMER()

				mp_transport_loading_check = true
            end

            if up_pressed or down_pressed then

                if up_pressed then

                    if mp_transport_index == 1 then

                        mp_transport_index = #mp_transport
                    else

                        mp_transport_index = mp_transport_index - 1
                    end

                elseif down_pressed then

                    if mp_transport_index == #mp_transport then

                        mp_transport_index = 1
                    else

                        mp_transport_index = mp_transport_index + 1
                    end
                end

				natives.game.set_use_context_text(mp_transport_context[2], mp_transport[mp_transport_index].name, "", "", 0, 0)
            end
        end
    end
end



thread.create(function()

    while true do

        mp_transport_update()

        thread.wait(0)
    end
end)



event.add_handler("core:on_resource_stop", function(_name)

    if _name == CURRENT_RESOURCE_NAME then

        -- We're cleaning everything on resource stop
        for i = 1, #mp_transport do

            if natives.object.is_object_valid(mp_transport_propset[i]) then

                if natives.hud.is_blip_valid(mp_transport_propset_blip[i]) then

                    natives.hud.remove_blip(mp_transport_propset_blip[i])
                end

                natives.object.destroy_object(mp_transport_propset[i])
            end

            if natives.object.is_object_valid(mp_transport_mp_text[i]) then

                natives.object.destroy_object(mp_transport_mp_text[i])
            end
        end
    end
end)