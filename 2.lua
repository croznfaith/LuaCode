_G._AimbotCurrentPC = nil

local function ApplyHardAimbot()
    pcall(function()
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end
        
        -- 'char' is the BP_PlayerPawn from your 2nd screenshot
        local char = pc:GetPlayerCharacterSafety()
        if not slua.isValid(char) then return end

        local wm = char.WeaponManagerComponent
        if not slua.isValid(wm) then return end

        local weapon = wm.CurrentWeaponReplicated
        if not slua.isValid(weapon) then return end

        local entity = weapon.ShootWeaponEntityComp
        if not slua.isValid(entity) then return end

  entity.GameDeviationFactor = 0.5
  entity.WeaponAimInTime = 20
  entity.SwitchFromIdleToBackpackTime = 0.15
  entity.SwitchFromBackpackToIdleTime = 0.15
  entity.ShotGunHorizontalSpread = 0.0
  entity.ShotGunVerticalSpread = 0.0
  entity.RecoilKick = 0.2
    entity.RecoilKickADS = 0.2
    entity.AnimationKick = 0.2
    entity.AccessoriesVRecoilFactor = 0.6
    entity.AccessoriesHRecoilFactor = 0.6
    entity.GameDeviationFactor = 0.3
    if entity.RecoilInfo then
        entity.RecoilInfo.VerticalRecoilMin = 0.2
        entity.RecoilInfo.VerticalRecoilMax = 0.2
        entity.RecoilInfo.RecoilSpeedVertical = 0.2
        entity.RecoilInfo.RecoilSpeedHorizontal = 0.15
        entity.RecoilInfo.VerticalRecoveryMax = 0.2
    end
    entity.RecoilModifierStand = 0.2
    entity.RecoilModifierCrouch = 0.2
    entity.RecoilModifierProne = 0.2
        -- From Screenshot 1: BP_ShootWeaponBase.uasset
        if entity.AutoAimingConfig then
            for _, range in ipairs({"OuterRange", "InnerRange"}) do
                local cfg = entity.AutoAimingConfig[range]
                if cfg then
                    cfg.Speed = 8
                    cfg.RangeRate = 2
                    cfg.SpeedRate = 5
                    cfg.RangeRateSight = 2
                    cfg.SpeedRateSight = 4
                    cfg.CrouchRate = 4
                    cfg.ProneRate = 4
                    cfg.DyingRate = 0
                    
                    -- Adding adsorb values from screenshot 1
                    cfg.adsorbMaxRange = 200
                    cfg.adsorbMinRange = 20
                    cfg.adsorbMinAttenuationDis = 100
                    cfg.adsorbMaxAttenuationDis = 8000
                    cfg.adsorbActiveMinRange = 20
                end
            end
            entity.AutoAimingConfig = entity.AutoAimingConfig
        end

        -- From Screenshot 2: BP_PlayerPawn.uasset -> Export 517
        -- BP_AutoAimingComponent_C is attached to the player (char), NOT the weapon!
        pcall(function()
            local aimComp = char.BP_AutoAimingComponent_C 
                         or char.BP_AutoAimingComponent 
                         or char.AutoAimingComponent
            
            if slua.isValid(aimComp) and aimComp.Bones then
                -- Try the direct format you requested
                pcall(function() aimComp.Bones[0] = "head" end)
                pcall(function() aimComp.Bones[1] = "head" end)
                pcall(function() aimComp.Bones[2] = "head" end)
                
                -- Also try slua array setter just in case
                pcall(function() aimComp.Bones:Set(0, "head") end)
                pcall(function() aimComp.Bones:Set(1, "head") end)
                pcall(function() aimComp.Bones:Set(2, "head") end)
            end
        end)
        
    end)
end

local function AttachAimbotTimer()
    pcall(function()
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if not slua.isValid(pc) then return end
        if pc == _G._AimbotCurrentPC then return end
        _G._AimbotCurrentPC = pc
        if pc.AddGameTimer then
            pc:AddGameTimer(0.1, true, function()
                if not slua.isValid(_G._AimbotCurrentPC) then
                    _G._AimbotCurrentPC = nil
                    return
                end
                ApplyHardAimbot()
            end)
        end
    end)
end

-- Attach now
AttachAimbotTimer()

-- Also set up a global watcher that re-attaches on new match
pcall(function()
    local pc = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(pc) and pc.AddGameTimer then
        pc:AddGameTimer(2.0, true, function()
            if not slua.isValid(_G._AimbotCurrentPC) then
                _G._AimbotCurrentPC = nil
                AttachAimbotTimer()
            end
        end)
    end
end)