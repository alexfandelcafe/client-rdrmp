local function collect_keys(_t, _sort)

    local key = {}

	for k in pairs(_t) do

		key[#key + 1] = k
	end

    table.sort(key, _sort)

	return key
end



local function sorted_pairs(_t, _sort)

	local keys = collect_keys(_t, _sort)

    local i = 0

    return function()

        i = i + 1

        if keys[i] then

            return keys[i], _t[keys[i]]
		end
	end
end



local locations =
{
    ["agave viejo"]         = vector3(-1545.03, 15.03, 3913.46),
    ["armadillo"]           = vector3(-2175.62, 16.31, 2613.50),
    ["beecher's hope"]      = vector3(-83.45, 117.68, 1374.10),
    ["benedict point"]      = vector3(-3686.96, 8.62, 3493.24),
    ["blackwater"]          = vector3(711.18, 78.31, 1252.763),
    ["casa madrugada"]      = vector3(-788.78, 13.04, 3729.81),
    ["chuparosa"]           = vector3(-2714.70, 32.37, 4251.90),
    ["cochinay"]            = vector3(-739.29, 179.10, 784.69),
    ["coot's chapel"]       = vector3(-1793.48, 23.78, 2836.85),
    ["el matadero"]         = vector3(-455.44, 20.84, 3926.91),
    ["el presidio"]         = vector3(-698.10, 63.25, 3323.25),
    ["escalera"]            = vector3(-4279.04, 18.07, 4447.64),
    ["fort mercer"]         = vector3(-2622.53, 68.08, 3390.51),
    ["gaptooth breach"]     = vector3(-4461.66, 7.78, 3310.42),
    ["lake don julio"]      = vector3(-1955.07, 24.82, 3255.67),
    ["las hermanas"]        = vector3(-1700.31, 8.08, 4242.14),
    ["manzanita post"]      = vector3(-428.16, 151.34, 1615.59),
    ["mcfarlane's ranch"]   = vector3(-887.08, 90.19, 2420.53),
    ["nosalida"]            = vector3(-4701.72, 3.04, 3958.90),
    ["pacific union camp"]  = vector3(-273.95, 84.31, 2113.30),
    ["plainview"]           = vector3(-3126.40, 43.57, 3724.13),
    ["rathskeller fork"]    = vector3(-3661.76, 42.23, 2124.70),
    ["ridgewood farm"]      = vector3(-3275.14, 15.89, 2719.86),
    ["serendipity's wreck"] = vector3(325.34, 74.29, 1939.81),
    ["thieve's landing"]    = vector3(111.55, 73.29, 2318.82),
    ["tumbleweed"]          = vector3(-4007.25, 28.46, 2935.45),
    ["tesoro azul"]         = vector3(-3288.00, 38.20, 4547.00),
    ["torquemada"]          = vector3(376.66, 76.30, 3459.57),
    ["twin rocks"]          = vector3(-2425.06, 25.00, 2138.93),
}



local weather_list =
{
    "CLEAR",
	"FAIR",
	"CLOUDY",
	"RAINY",
	"STORMY",
	"SNOWY",
	"INTERIOR_CLEAR",
	"INTERIOR_FAIR",
	"INTERIOR_CLOUDY",
	"INTERIOR_RAINY",
	"INTERIOR_STORMY",
	"INTERIOR_SNOWY",
	"CAVE",
	"THIEVES",
	"FOREST",
	"LOCATION_A",
	"LOCATION_B",
	"LOCATION_C",
	"INTERIOR_THIEVES",
	"INTERIOR_FOREST",
	"INTERIOR_LOCATION_A",
	"INTERIOR_LOCATION_B",
	"INTERIOR_LOCATION_C"
}



COMMANDS =
{
    ["help"] =
    {
        handler = function(_client, _args)

            local commands_list = ""

            for name, data in sorted_pairs(COMMANDS) do

                commands_list = commands_list.."> <font color='#00FF00'>"..name.."</font>"

                if data.syntax then

                    commands_list = commands_list.." <font color='#C0C0C0'>"..data.syntax.."</font>"
                end

                if data.description then

                    commands_list = commands_list.."<br><font color='#808080'>("..data.description..")</font>"
                end

                commands_list = commands_list.."<br>"
            end

            event.trigger_on_client("chat:add_message", _client, "Commands list:<br>"..commands_list.."")

            return true
        end
    },

    ["time"] =
    {
        syntax = "[hour]",
        description = "(/!\\ UNIMPLEMENTED /!\\) Set world time for all players. Value range from 0-23.",
        handler = function(_client, _args)

            local time = tonumber(_args, 10)

            if not time then

                return false
            end

            if time > 23 then

                event.trigger_on_client("chat:add_message", _client, "<font color='#ff8000'>Invalid time (Hours between 0 to 23).</font>")
            else

                print("TODO: Re-implement this feature")

                --[[
                game.gameplay.set_time(time)

                local time_type = "AM"

                if time > 12 then
                    
                    time = time - 12

                    time_type = "PM"
                end

                local player = game.player.get(_client)

                event.trigger_on_client("chat:draw_notification", -1, player.name.." updated time to "..time..":00 "..time_type)
                ]]
            end

            return true
        end
    },

    ["weather"] =
    {
        syntax = "[weather id]",
        description = "(/!\\ UNIMPLEMENTED /!\\) Set world weather for all players. Value range from 0-22.",
        handler = function(_client, _args)

            local weather = tonumber(_args, 10)

            if not weather then

                return false
            end

            if weather > 22 then

                event.trigger_on_client("chat:add_message", _client, "<font color='#ff8000'>Invalid weather id.</font>")
            else

                print("TODO: Re-implement this feature")

                --[[
                game.gameplay.set_weather(weather)

                local player = game.player.get(_client)

                event.trigger_on_client("chat:draw_notification", -1, player.name.." updated weather to "..weather_list[weather + 1])
                ]]
            end

            return true
        end
    },

    ["tp"] =
    {
        syntax = "[location]",
        description = "Teleport your player to a specific location. See /tplist for more infos.",
        handler = function(_client, _args)

            local position = locations[_args]

            if position then

                event.trigger_on_client("chat:teleport", _client, position)

                return true
            end

            event.trigger_on_client("chat:add_message", _client, "<font color='#ff8000'>Failed to teleport, invalid location name.</font>")

            return true
        end
    },

    ["tplist"] =
    {
        description = "List of teleport command used with /tp.",
        handler = function(_client, _args)

            local tp_list = ""

            for name in pairs(locations) do

                tp_list = tp_list.."> <font color='#00FF00'>tp</font> <font color='#C0C0C0'>"..name.."</font><br>"
            end

            event.trigger_on_client("chat:add_message", _client, "Tp list:<br>"..tp_list.."")

            return true
        end
    },

    ["tpid"] =
    {
        syntax = "[player id]",
        description = "Teleport yourself to a specific player by id.",
        handler = function(_client, _args)

            local value = tonumber(_args, 10)

            if not value then

                return false
            end

            if value == _client then

                event.trigger_on_client("chat:add_message", _client, "<font color='#ff8000'>Failed to teleport, you can't teleport to yourself.</font>")
            else

                local player = player.get(value)

                if player then

                    event.trigger_on_client("chat:teleport", _client, player.position)
                else

                    event.trigger_on_client("chat:add_message", _client, "<font color='#ff8000'>Failed to teleport, player doesn't exist.</font>")
                end
            end

            return true
        end
    },

    ["model"] =
    {
        syntax = "[model id]",
        description = "Change your player model by enum id.",
        handler = function(_client, _args)

            local value = tonumber(_args, 10)

            if not value then

                return false
            end

            player.set_model(_client, value)

            return true
        end
    },

    ["killme"] =
    {
        description = "This will respawn you at the nearest hospital. Useful if you're stuck.",
        handler = function(_client, _args)

            event.trigger_on_client("chat:kill_player", _client)

            return true
        end
    },

    ["kick"] =
    {
        syntax = "[player id]",
        description = "(/!\\ UNIMPLEMENTED /!\\) Used to kick a specific player by id. (Admin only)",
        handler = function(_client, _args)

            local value = tonumber(_args, 10)

            if not value then

                return false
            end

            print("TODO: Re-implement this feature")

            --[[
            if not game.player.is_from_group(_client, "admin") then
                
                event.trigger_on_client("chat:add_message", _client, "<font color='#ff8000'>Failed to kick player, you don't have the required privileges.</font>")

                return true
            end

            local src_player = game.player.get(_client)
            local dst_player = game.player.get(value)

            if dst_player then
            
                game.player.kick(value)

                event.trigger_on_client("chat:draw_notification", -1, src_player.name.." [format][color:red]kicked[/format] player "..dst_player.name)
            else

                event.trigger_on_client("chat:add_message", _client, "<font color='#ff8000'>Failed to kick player, invalid player id.</font>")
            end
            ]]

            return true
        end
    }
}



--- Register this event so we can later register commands from other scripts.
-- @param _command (string) The command itself without the slash.
-- @param _description (string) The command description (Make it simple)
-- @param _syntax (string) This is the syntax of the commands that will be shown when calling /help, useful to explain parameters of your command
-- @param _handler (function) This is the function that will be called when typing the command
event.register("chat:register_command")
event.add_handler("chat:register_command", function(_command, _description, _syntax, _handler)

    COMMANDS[_command] =
    {
        syntax = _syntax,
        description = _description,
        handler = _handler
    }
end)



--- Triggered when a player send a chat command in the chatbox.
-- @param _client (number) The command sender id.
-- @param _command (string) The command itself without the slash. ('/help' would output 'help')
-- @param _args (string) The args list as a string separated by spaces (some deserialization is required to extract multiple args)
event.add_handler("core:on_chat_command", function(_client, _command, _args)

    local data = COMMANDS[_command]

    if data then

        local success = data.handler(_client, _args)

        if not success then

            event.trigger_on_client("chat:add_message", _client, "<font color='#ff8000'>Invalid command args.</font>")
        end
    else

        event.trigger_on_client("chat:add_message", _client, "<font color='#ff8000'>The command doesn't exist. Type /help to see the list.</font>")
    end
end)