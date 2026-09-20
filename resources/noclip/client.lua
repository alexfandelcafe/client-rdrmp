local no_clip = false
local no_clip_requested = false
local no_clip_speeds = { 10.0, 50.0, 100.0, 300.0 }
local no_clip_speed_index = 2;

local PROMPT_GENERIC_DBUFFER =
{
    "GENERIC_DBUFFER64_0",
    "GENERIC_DBUFFER64_1",
    "GENERIC_DBUFFER64_2",
    "GENERIC_DBUFFER64_3",
    "GENERIC_DBUFFER64_4",
    "GENERIC_DBUFFER32_0",
    "GENERIC_DBUFFER32_1",
    "GENERIC_DBUFFER32_2",
    "GENERIC_DBUFFER32_3",
    "GENERIC_DBUFFER32_4"
}



-- Register a trigger so we can toggle the noclip from chatbox (See 'server.lua' to get more infos)
event.register("noclip:toggle")
event.add_handler("noclip:toggle", function()

    -- We don't just toggle noclip here, instead we're requesting it, this is important bcs the order
    -- of 'set_mover_frozen' function below cause a snap to the ground if not called in the same order
    no_clip_requested = true
end)



local function draw_prompt(_prompt, _icon_string, _string)

    natives.ui.ui_set_string(PROMPT_GENERIC_DBUFFER[_prompt + 1], _string)
    natives.hud.ui_set_prompt_icon_string(_prompt, _icon_string)
    natives.hud.ui_set_prompt_string(_prompt, PROMPT_GENERIC_DBUFFER[_prompt + 1])
end



local function remove_prompts()

    for i = 0, 10 do

        natives.hud.ui_hide_prompt(i)
    end
end



-- Some functions helper
local function get_actor_vector(_actor, _correction_angle)

	local heading = natives.actor.get_heading(_actor) + _correction_angle

	heading = heading * (math.pi / 180)

    return vector3
    (
        math.cos(heading) * -1.0,
        0.0,
        math.sin(heading)
    )
end



local function no_clip_update()

    local local_player_actor = natives.actor.get_player_actor(-1)

    local is_using_keyboard_and_mouse = natives.core.is_using_keyboard_and_mouse(0)

    -- Enable/Disable No Clip F4 (Keyboard) - X + LSTICK Click (XBOX Controller)
    if is_using_keyboard_and_mouse then

        if natives.extended.is_key_pressed("F4") then

            no_clip_requested = true
        end

    else

        -- We want to make sure to handle the digital inputs only for controller, bcs otherwise on keyboard it would toggle the noclip with T + Space bar
        if natives.core.is_digital_action_down("@GENERIC.ZOOM_RADAR", 1, 0) and natives.core.is_digital_action_pressed("@FOOT.JUMP", 1, 0) then

            no_clip_requested = true
        end
    end

    if no_clip_requested then

        no_clip_requested = false

        no_clip = not no_clip

        if no_clip then

            -- Freeze the player actor ONLY if not already frozen (e.g. from an other script)
            if not natives.entity.is_mover_frozen(local_player_actor) then

                natives.entity.set_mover_frozen(local_player_actor, true)
            end

            -- Disable player controls while still keeping camera control
            natives.actor.set_player_control(-1, false, 1, 1)

            -- Show a notification the no clip has been enabled
            natives.hud.print_small_b("No Clip <green>On", 0.5, true, 0, 0, 0, 0)
        else

            -- Unfreeze the player actor ONLY if currently frozen
            if natives.entity.is_mover_frozen(local_player_actor) then

                natives.entity.set_mover_frozen(local_player_actor, false)
            end

            -- Give player control Back
            natives.actor.set_player_control(-1, true, 0, 0)

            -- Show a notification the no clip has been disabled
            natives.hud.print_small_b("No Clip <red>Off", 0.5, true, 0, 0, 0, 0)

            -- Remove Drawn Prompts
            remove_prompts()
        end
    end

    if not no_clip or chat.is_open() then

        -- Don't do anything if no clip is off (or if chatbox is currently open)
        return
    end

    local stick_dead_zone = 0.02

    local speed = no_clip_speeds[no_clip_speed_index]

    local input_lower_raise = { "@GENERIC.TARGET", "@GENERIC.FIRE" }

    if is_using_keyboard_and_mouse then

        input_lower_raise = { "@FOOT.CROUCH", "@FOOT.JUMP" }
    end

    -- Display inputs prompt on the bottom right corner of the screen
    draw_prompt(0, "{@UI.CANCELMINIGAME}", "Exit")
    draw_prompt(1, "{"..input_lower_raise[1].."}{"..input_lower_raise[2].."}", "Lower/Raise")
    draw_prompt(2, "{@UI.PREVIOUS_TAB}{@UI.NEXT_TAB}", "Speed (Boost {@FOOT.SPRINT}) [x"..speed.."]")
    draw_prompt(3, "{@CAMERA.UP}{@CAMERA.DOWN}{@CAMERA.LEFT}{@CAMERA.RIGHT}", "Camera")
    draw_prompt(4, "{@GENERIC.MOVE_FORWARD}{@GENERIC.MOVE_LEFT}{@GENERIC.MOVE_BACK}{@GENERIC.MOVE_RIGHT}", "Move")

    -- Exit with BACKSPACE (Keyboard) - B (XBOX Controller)
    if natives.core.is_digital_action_pressed("@UI.CANCELMINIGAME", 1, 0) then

        no_clip_requested = true
    end

    -- Handle speed change using Q/E (Keyboard) - LB/RB (XBOX Controller)
    if natives.core.is_digital_action_pressed("@UI.PREVIOUS_TAB", 1, 0) then

        if no_clip_speed_index > 1 then

            no_clip_speed_index = no_clip_speed_index - 1

            speed = no_clip_speeds[no_clip_speed_index]

            natives.hud.print_small_b("No Clip Speed <red>x"..speed, 0.5, true, 0, 0, 0, 0)
        end

    elseif natives.core.is_digital_action_pressed("@UI.NEXT_TAB", 1, 0) then

        if no_clip_speed_index < #no_clip_speeds then

            no_clip_speed_index = no_clip_speed_index + 1

            speed = no_clip_speeds[no_clip_speed_index]

            natives.hud.print_small_b("No Clip Speed <red>x"..speed, 0.5, true, 0, 0, 0, 0)
        end
    end

    -- Handle speed boost x2 using LSHIFT (Keyboard) - A (XBOX Controller)
    if natives.core.is_digital_action_down("@FOOT.SPRINT", 1, 0) then

        speed = speed * 2.0
    end

    local position = natives.actor.get_position(local_player_actor)
    local movement_speed = natives.builtin.timestep() * speed

    -- Handle both keyboard & controller movements at the same time
    local move_x = natives.core.get_analogue_action("@GENERIC.MOVE_X", 1, 1)
    local move_y = natives.core.get_analogue_action("@GENERIC.MOVE_Y", 1, 1)

    if move_y < -stick_dead_zone or move_y > stick_dead_zone then

        position = position + get_actor_vector(local_player_actor, 90) * move_y * movement_speed
    end

    if move_x < -stick_dead_zone or move_x > stick_dead_zone then

        position = position + get_actor_vector(local_player_actor, 180) * move_x * movement_speed
    end

    -- Handle going up/down (Both keyboard & controller) LCTRL/SPACEBAR (Keyboard) - LT/RT (XBOX Controller)
    if natives.core.is_digital_action_down(input_lower_raise[1], 1, 0) then

        position.y = position.y - movement_speed

    elseif natives.core.is_digital_action_down(input_lower_raise[2], 1, 0) then

        position.y = position.y + movement_speed
    end

    -- Finally update the player position accordingly
    natives.actor.teleport_actor(local_player_actor, position, false, false, false)

    -- Simply tie player heading to camera heading
    local camera_heading = natives.object.get_object_heading(natives.cam.get_game_camera())

    natives.actor.set_actor_heading(local_player_actor, camera_heading, false)
end



thread.create(function()

    while true do

        no_clip_update()

        thread.wait(0)
    end
end)



-- When the chat is opened and noclip is on, we want to input remove prompts
event.add_handler("core:on_chat_open", function()

    if no_clip then

        remove_prompts()
    end
end)



-- When the chat has been closed and noclip is on, we want to block inputs correctly (bcs when chat is closed/open it mess with this native)
event.add_handler("core:on_chat_close", function()

    if no_clip then

        -- Disable player controls while still keeping camera control
        natives.actor.set_player_control(-1, false, 1, 1)
    end
end)