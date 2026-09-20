event.register("chat:add_message")
event.add_handler("chat:add_message", function(_msg)

    chat.add_message(_msg)
end)



event.register("chat:teleport")
event.add_handler("chat:teleport", function(_position)

    local local_player_actor = natives.actor.get_player_actor(-1)

    natives.actor.teleport_actor(local_player_actor, _position, false, false, false)

    local message = "Teleported to "..string.format("%.1f", _position.x)..", "..string.format("%.1f", _position.y)..", "..string.format("%.1f", _position.z)

    natives.hud.print_small_b(message, 1.5, true)
end)



event.register("chat:draw_notification")
event.add_handler("chat:draw_notification", function(_msg)

    natives.hud.print_small_b(_msg, 1.5, true)
end)



event.register("chat:kill_player")
event.add_handler("chat:kill_player", function()

    local local_player_actor = natives.actor.get_player_actor(-1)

    natives.health.kill_actor(local_player_actor)
end)