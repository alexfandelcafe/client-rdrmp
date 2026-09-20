-- A work in progress DLC weapons loader
-- Only melee torch is loaded yet



local Weapons =
{
    WEAPON_THROWN_ZombieSpit = 32,
    WEAPON_MELEE_TORCH = 33,
    WEAPON_SHOTGUN_Blunderbuss = 34,
    WEAPON_THROWN_HolyWater = 35,
    WEAPON_THROWN_ZombieBait = 36,
    WEAPON_THROWN_ZombieBoomBait = 37
}



local function init()

    -- Load the DLC PTFX pack (This will load the fire on the torch for example)
    natives.fx.load_ptfx_dlc_assets("zombiePack_core")

    -- Load the audio data packs (Will load the fire sound when waving the torch, but for some reason it doesn't load the sound when being idle with the torch)
    natives.audio.load_audio_metadata("sounds", "dlc6_sounds.dat", "DLC6")
end



local function init_melee_torch()

    local data =
    {
        0,
        0,
        46,
        20,
        20,
        -1,
        "MELEE_TORCH",
        "TORCH",
        "melee_torch01x",
        "",
        "",
        35,
        0.15,
        0.0,
        0.4,
        0.0,
        0.0,
        "MEL_Torch",
        500.0,
        0.0,
        "trc",
        "",
        "<none>",
        "donothing",
        "DoNothing",
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        "TORCH_IDLE",
        "",
        "wrist_r_Attachment",
        0.8,
        15.0,
        0.8,
        15.0,
        0.0,
        1.0,
        0.6,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        "AIMER_SIMPLE",
        0,
        0,
        0.5,
        0.03,
        1,
        8.0,
        8.0
    }

    -- Init the torch weapon model
	natives.weapon.init_native_weaponenum_melee(Weapons.WEAPON_MELEE_TORCH, "base_melee", data)
	natives.weapon.resolve_dlc_weaponenum(Weapons.WEAPON_MELEE_TORCH)
	
    -- Attach the fire effect on the torch
	natives.weapon.add_idlefx_to_weapon(Weapons.WEAPON_MELEE_TORCH, "TORCH_IDLE", vector3(0.0, 0.35, -0.15))

    -- Make sure to unlock the torch so it can be obtained by the player
	natives.weapon.set_weaponenum_locked(Weapons.WEAPON_MELEE_TORCH, false)
end







thread.create(function()

    init()

    init_melee_torch()

end)