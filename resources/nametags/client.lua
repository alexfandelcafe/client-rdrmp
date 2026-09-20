local players_nametag = {}



-- Utility function
local function direction_to_euler(_direction)

    local dir = _direction:normalized()

    local pitch = math.asin(-dir.y)
    local yaw = math.atan(dir.x, dir.z)

    local rad_to_deg = 180.0 / math.pi

    return vector3(pitch * rad_to_deg, yaw * rad_to_deg, 0.0)
end



local function nametags_start()

    -- Pre fill for players nametags table
    for i = 1, 33 do

        players_nametag[i] = nil
    end
end



local function nametags_update()

    local game_camera = natives.cam.get_game_camera()
    local camera_dir = natives.camera.get_camera_direction(game_camera)
    local camera_rotation = direction_to_euler(camera_dir)

    for i, nametag in pairs(players_nametag) do

        local player = player.get(i - 1)

        if player then

            local player_position = natives.actor.get_position(player.actor)

            player_position.y = player_position.y + 2.0

            natives.object.set_object_position(nametag, player_position)
            natives.object.set_object_orientation(nametag, camera_rotation)
        end
    end
end



-- Create a nametag above player head.
local function create_player_nametag(_client, _name, _islocal)

    -- Don't do anything if it's the local player
    if _islocal then

        return
    end

    local player = player.get(_client)

    -- Don't do anything if player is invalid
    if not player then

        return
    end

    -- Store the player name on a GXTEntry
    natives.extended.ui_add_string("PLAYER_NAMETAG_".._client, _name)

    -- Create the physical 3D text above head
    local nametag = natives.gravestone.create_mp_text(player.actor, "", "PLAYER_NAMETAG_".._client, vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0), 0xFFFFFF)

    -- Store the nametag in a table
    players_nametag[_client + 1] = nametag
end



local function remove_player_nametag(_client, _name, _islocal)

    -- Don't do anything if it's the local player
    if _islocal then

        return
    end

    -- Remove the nametag above head
    if players_nametag[_client + 1] ~= nil and natives.object.is_object_valid(players_nametag[_client + 1]) then

        natives.object.destroy_object(players_nametag[_client + 1])
    end

    -- Remove the previously registered GXTEntry
    natives.extended.ui_remove_string("PLAYER_NAMETAG_".._client)

    -- Remove the nametag from the table
    players_nametag[_client + 1] = nil
end



local function remove_players_nametag()

    for i, _ in pairs(players_nametag) do

        remove_player_nametag(i - 1, nil, false)
    end
end



thread.create(function()

    nametags_start()

    while true do

        nametags_update()

        thread.wait(0)
    end
end)



--- Triggered when a player join the server.
-- @param _client (number) The ID of the player who joined.
-- @param _name (string) The name of the player who joined.
-- @param _islocal (boolean) Is local player ?
event.add_handler("core:on_player_joined", create_player_nametag)



--- Triggered when a player leave the server.
-- @param _client (number) The ID of the player who left.
-- @param _name (string) The name of the player who left.
-- @param _islocal (boolean) Is local player ?
event.add_handler("core:on_player_left", remove_player_nametag)



--- Triggered when the resource is stopped.
-- @param _name (string) The name of the resource stopped.
event.add_handler("core:on_resource_stop", function(_name)

    if _name == CURRENT_RESOURCE_NAME then

        remove_players_nametag()
    end
end)