local player_locomotion = {}

event.register("locomotion:update")
event.register("locomotion:remove")

-- Cliente -> servidor
event.add_handler("locomotion:update", function(_client, _gait)
    if type(_client) ~= "number" then
        return
    end

    if type(_gait) ~= "number" then
        return
    end

    player_locomotion[_client] = _gait

    -- Replicar a todos los demás clientes
    for id, _ in pairs(player.list()) do
        if id ~= _client then
            event.trigger_on_client(
                "locomotion:update",
                id,
                _client,
                _gait
            )
        end
    end
end)

-- Cuando entra un jugador nuevo, mandarle el estado
-- actual de todos los jugadores que ya estaban conectados.
event.add_handler("core:on_player_joined", function(_client, _name)
    for player_id, gait in pairs(player_locomotion) do
        if player_id ~= _client then
            event.trigger_on_client(
                "locomotion:update",
                _client,
                player_id,
                gait
            )
        end
    end
end)

-- Limpiar al salir y avisar a los clientes
event.add_handler("core:on_player_left", function(_client, _name)
    player_locomotion[_client] = nil

    event.trigger_on_client(
        "locomotion:remove",
        -1,
        _client
    )
end)