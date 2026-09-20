-- Vars
local previous_health
local start_regen_timer = false
local timer = 0.0

-- Config Vars
local time_before_regen = 5.0 -- 5 sec by default
local regen_multiplier = 4.0 -- x4 by default



-- Player regen script
local function health_regen_start()
    
    local local_player_actor = natives.actor.get_player_actor(-1)

    previous_health = natives.health.get_actor_health(local_player_actor)
end



local function health_regen_update()

    local local_player_actor = natives.actor.get_player_actor(-1)

    local current_health = natives.health.get_actor_health(local_player_actor)

    -- If previous_health is different from current_health that mean we just took damage
    if current_health < previous_health then

        if current_health <= 0 then

            thread.wait(1000)
            
            natives.hud.hud_fade_to_loading_screen()

            thread.wait(1000)

            local layout = natives.object.find_named_layout("PlayerLayout")
            local model = math.random(837, 940)

            local position = vector3(-2145.7, 16.1, 2611.8)
            local rotation = vector3(0.0, 0.0, 0.0)

            local_player_actor = natives.object.respawn_player_actor_in_layout(layout, local_player_actor, "player", model, position, rotation, 0)

            -- Block the controls & godmode the player when it's respawning
            natives.actor.set_player_control(0, false, 0, 0)
            natives.actor.set_actor_invulnerability(local_player_actor, true)
            
            -- Disable default player actor voice (by default John Marston)
            natives.audio.audio_turn_off_pain_vocals(local_player_actor)
            natives.audio.audio_turn_off_vocals_effects(local_player_actor)

            -- Tell the game camera to follow the respawned player
            natives.cam.set_camera_follow_actor(local_player_actor)

            -- This is required to wait 10 sec otherwise the camera isn't gonna follow the player
            thread.wait(10000)

            -- Once we respawned properly, give back controls and remove godmode
            natives.actor.set_player_control(0, true, 0, 0)
            natives.actor.set_actor_invulnerability(local_player_actor, false)

            -- Fade the screen
            natives.hud.hud_fade_in_now(0, 0)
        else

            -- We're starting the regen timer
            start_regen_timer = true
    
            -- Make sure to reset the timer
            timer = 0.0
        end
    end

    if start_regen_timer then
        
        -- Increment the timer...
        timer = timer + natives.builtin.timestep()

        -- When the timer pass a certain amount of time we're starting the actual player regen
        if timer >= time_before_regen then

            -- Regenerate the player health...
            local max_health = natives.health.get_actor_max_health(local_player_actor)

            if current_health < max_health then
        
                natives.health.set_actor_health(local_player_actor, current_health + natives.builtin.timestep() * regen_multiplier)
            else

                -- Once the player health is full, stop the regen timer
                start_regen_timer = false
            end
        end
    end

    -- Make sure we update previous health accordingly
    previous_health = current_health
end



thread.create(function()

    health_regen_start()

    while true do

        health_regen_update()

        thread.wait(0)
    end
end)



-- Create a blip when a player join the game
-- NOTE: When a player leave the game, the blip is already internally cleaned (so it's not needed to clear the blip on player left)
local function create_player_blip(_client, _name, _islocal)

    -- Don't do anything if it's the local player
    if _islocal then
    
        return
    end

    local player = player.get(_client)

    -- Don't do anything if player is invalid
    if not player then

        return
    end

    -- Create the player blip
    local playerBlip = natives.hud.add_blip_for_actor(player.actor, 356, 0.0, 0, 0)

    -- Set blip name to player name
    natives.ui.ui_set_string("Generic_Dbuffer128_1", _name)
    natives.hud.set_blip_name(playerBlip, "Generic_Dbuffer128_1")

    -- Set a slightly smaller blip size
    natives.hud.set_blip_scale(playerBlip, 0.8)
end



--- Triggered when a player join the server.
-- @param _client (number) The ID of the player who joined.
-- @param _name (string) The name of the player who joined.
-- @param _islocal (boolean) Is local player ?
event.add_handler("core:on_player_joined", create_player_blip)