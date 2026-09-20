local remote_locomotion = {}

local SEND_INTERVAL = 100
local APPLY_INTERVAL = 25

local function get_remote_actor(_client)
    local remote_player = player.get(_client)

    if not remote_player then
        return nil
    end

    if not remote_player.actor then
        return nil
    end

    if remote_player.actor == 0 then
        return nil
    end

    return remote_player.actor
end

--------------------------------------------------
-- RECIBIR LOCOMOCION
--------------------------------------------------

event.register("locomotion:update")

event.add_handler("locomotion:update", function(_client, _gait)
    if type(_client) ~= "number" then
        return
    end

    if type(_gait) ~= "number" then
        return
    end

    remote_locomotion[_client] = {
        gait = _gait,
        applied = nil
    }
end)

--------------------------------------------------
-- ELIMINAR JUGADOR
--------------------------------------------------

event.register("locomotion:remove")

event.add_handler("locomotion:remove", function(_client)
    if type(_client) ~= "number" then
        return
    end

    remote_locomotion[_client] = nil
end)

--------------------------------------------------
-- ENVIAR LOCOMOCION DEL JUGADOR LOCAL
--------------------------------------------------

thread.create(function()

    local last_gait = nil
    local last_send_time = 0

    while true do

        local local_actor = natives.actor.get_player_actor(-1)

        if local_actor ~= 0 then

            local gait = natives.entity.get_actor_gait_type(local_actor)

            local current_time =
                math.floor(natives.core.get_current_game_time() * 1000)

            local gait_changed = gait ~= last_gait
            local heartbeat =
                (current_time - last_send_time) >= SEND_INTERVAL

            if gait_changed or heartbeat then

                event.trigger_on_server(
                    "locomotion:update",
                    gait
                )

                last_gait = gait
                last_send_time = current_time
            end
        end

        thread.wait(25)
    end
end)

--------------------------------------------------
-- APLICAR LOCOMOCION A ACTORES REMOTOS
--------------------------------------------------

thread.create(function()

    while true do

        for client_id, state in pairs(remote_locomotion) do

            local actor = get_remote_actor(client_id)

            if actor then

                if state.applied ~= state.gait then

                    -- Cambia el gait del actor remoto.
                    natives.actor.actor_pop_next_gait(
                        actor,
                        state.gait,
                        false
                    )

                    -- Fuerza al actor a procesar el nuevo estado.
                    natives.actor.actor_force_next_update(actor)

                    state.applied = state.gait
                end
            end
        end

        thread.wait(APPLY_INTERVAL)
    end
end)

--------------------------------------------------
-- LIMPIEZA
--------------------------------------------------

event.add_handler("core:on_resource_stop", function(_name)

    if _name ~= CURRENT_RESOURCE_NAME then
        return
    end

    remote_locomotion = {}
end)