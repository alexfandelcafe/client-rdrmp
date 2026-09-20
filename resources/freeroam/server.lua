--- Triggered when a player join the server.
-- @param _client (number) The ID of the player who joined.
-- @param _name (string) The name of the player who joined.
event.add_handler("core:on_player_joined", function(_client, _name)

    -- Here we're sending a chat message to every connected players that a player joined the server. (Except to the player who just joined)
    for id, _ in pairs(player.list()) do

        if id ~= _client then
            
            event.trigger_on_client("chat:add_message", id, "<font color='#66ff66'>".._name.." (".._client..")</font> joined the game.")
        end
    end
end)



--- Triggered when a player leave the server.
-- @param _client (number) The ID of the player who left.
-- @param _name (string) The name of the player who left.
event.add_handler("core:on_player_left", function(_client, _name)

    -- Here we're sending a chat message to every connected players that a player left the server. (Except to the player who just left)
    for id, _ in pairs(player.list()) do

        if id ~= _client then
            
            event.trigger_on_client("chat:add_message", id, "<font color='#ff6666'>".._name.." (".._client..")</font> left the game.")
        end
    end
end)