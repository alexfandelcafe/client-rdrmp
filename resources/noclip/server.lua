-- Register a command to toggle the noclip from the chatbox
event.trigger("chat:register_command", "noclip", "Toggle noclip mode.", nil, function(_client, _args)

    event.trigger_on_client("noclip:toggle", _client)

    return true
end)