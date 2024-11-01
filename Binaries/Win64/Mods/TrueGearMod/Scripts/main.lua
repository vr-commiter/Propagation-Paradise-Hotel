local truegear = require "truegear"

local isFirst = true
local hookIds = {}
local resetHook = true
local leftpunchTime = 0
local rightpunchTime = 0
local healingTime = 0
local playerHealth = 100
local isPause = false
local electricScrewdriverHand = nil
local firearmSide = 0
local cutTime = 0

local leftHandPos = {X = nil, Y = nil, Z = nil}
local rightHandPos = {X = nil, Y = nil, Z = nil}
local leftHandTime = 0
local rightHandTime = 0
local leftHandSpeed = 0
local rightHandSpeed = 0

local handDryerTime = 0
local isUnlocakSound = false

function SendMessage(context)
	if isDeath == true then
		return
	end
	if context then
		print(context .. "\n")
		return
	end
	print("nil\n")
end


function PlayAngle(event,tmpAngle,tmpVertical)

	local rootObject = truegear.find_effect(event);

	local angle = (tmpAngle - 22.5 > 0) and (tmpAngle - 22.5) or (360 - tmpAngle)
	
    local horCount = math.floor(angle / 45) + 1
	local verCount = (tmpVertical > 0.1) and -4 or (tmpVertical < 0 and 8 or 0)


	for kk, track in pairs(rootObject.tracks) do
        if tostring(track.action_type) == "Shake" then
            for i = 1, #track.index do
                if verCount ~= 0 then
                    track.index[i] = track.index[i] + verCount
                end
                if horCount < 8 then
                    if track.index[i] < 50 then
                        local remainder = track.index[i] % 4
                        if horCount <= remainder then
                            track.index[i] = track.index[i] - horCount
                        elseif horCount <= (remainder + 4) then
                            local num1 = horCount - remainder
                            track.index[i] = track.index[i] - remainder + 99 + num1
                        else
                            track.index[i] = track.index[i] + 2
                        end
                    else
                        local remainder = 3 - (track.index[i] % 4)
                        if horCount <= remainder then
                            track.index[i] = track.index[i] + horCount
                        elseif horCount <= (remainder + 4) then
                            local num1 = horCount - remainder
                            track.index[i] = track.index[i] + remainder - 99 - num1
                        else
                            track.index[i] = track.index[i] - 2
                        end
                    end
                end
            end
            if track.index then
                local filteredIndex = {}
                for _, v in pairs(track.index) do
                    if not (v < 0 or (v > 19 and v < 100) or v > 119) then
                        table.insert(filteredIndex, v)
                    end
                end
                track.index = filteredIndex
            end
        elseif tostring(track.action_type) ==  "Electrical" then
            for i = 1, #track.index do
                if horCount <= 4 then
                    track.index[i] = 0
                else
                    track.index[i] = 100
                end
            end
            if horCount == 1 or horCount == 8 or horCount == 4 or horCount == 5 then
                track.index = {0, 100}
            end
        end
    end

	truegear.play_effect_by_content(rootObject)
end



function RegisterHooks()

	for k,v in pairs(hookIds) do
		UnregisterHook(k, v.id1, v.id2)
	end
		
	hookIds = {}

    local funcName = "/Game/Blueprints/Weapons/BP_WeaponBase.BP_WeaponBase_C:FinishShoot"
	local hook1, hook2 = RegisterHook(funcName, FinishShoot)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/Blueprints/BP_MotionController.BP_MotionController_C:GrabActor"
	local hook1, hook2 = RegisterHook(funcName, GrabActor)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/Blueprints/BP_Holster.BP_Holster_C:BPI_Holster_AddItem"
	local hook1, hook2 = RegisterHook(funcName, BPI_Holster_AddItem111)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/Blueprints/BP_Holster.BP_Holster_C:BPI_Holster_RemoveItem"
	local hook1, hook2 = RegisterHook(funcName, BPI_Holster_RemoveItem111)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/Blueprints/Items/BP_FlashLight.BP_FlashLight_C:ActionPressed"
	local hook1, hook2 = RegisterHook(funcName, FlashLightActionPressed)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
    
    local funcName = "/Game/Blueprints/MotionControllerPawn.MotionControllerPawn_C:ReceiveAnyDamage"
	local hook1, hook2 = RegisterHook(funcName, ReceiveAnyDamage)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/Blueprints/Items/Quest/BP_ElectricScrewdriver.BP_ElectricScrewdriver_C:ActionPressed"
	local hook1, hook2 = RegisterHook(funcName, ElectricScrewdriverActionPressed)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/Blueprints/Items/Quest/BP_ElectricScrewdriver.BP_ElectricScrewdriver_C:ActionReleased"
	local hook1, hook2 = RegisterHook(funcName, ElectricScrewdriverActionReleased)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/Blueprints/BP_MotionController.BP_MotionController_C:CheckPunchDirection"
	local hook1, hook2 = RegisterHook(funcName, CheckPunchDirection)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/Blueprints/BP_PlayerController.BP_PlayerController_C:Resume"
	local hook1, hook2 = RegisterHook(funcName, Close)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/Blueprints/Menu/BP_PauseMenu.BP_PauseMenu_C:ReceiveBeginPlay"
	local hook1, hook2 = RegisterHook(funcName, Open)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/Blueprints/BP_Holster.BP_Holster_C:UpdateSidePlayer"
	local hook1, hook2 = RegisterHook(funcName, UpdateSidePlayer)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Script/Engine.GameplayStatics:OpenLevel"
	local hook1, hook2 = RegisterHook(funcName, OpenLevel)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 } 

    local funcName = "/Game/Blueprints/Items/BP_BoltCutter.BP_BoltCutter_C:ReceiveBeginPlay"
	local hook1, hook2 = RegisterHook(funcName, CutReceiveBeginPlay)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/Blueprints/Items/BP_BoltCutter.BP_BoltCutter_C:ComputeActualLocAndAxes"
	local hook1, hook2 = RegisterHook(funcName, ComputeActualLocAndAxes)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/Blueprints/BP_PlayerController.BP_PlayerController_C:Crouch"
	local hook1, hook2 = RegisterHook(funcName, Crouch)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/Blueprints/BP_MotionController.BP_MotionController_C:ReceiveTick"
	local hook1, hook2 = RegisterHook(funcName, HandSpeedCheck)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
        
    local funcName = "/Game/Models/Hall/BP_RingBell.BP_RingBell_C:ButtonPush"
	local hook1, hook2 = RegisterHook(funcName, RingBellButtonPush)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/Blueprints/BP_DigitCode.BP_DigitCode_C:ButtonPush"
	local hook1, hook2 = RegisterHook(funcName, ButtonPush)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/Blueprints/BP_ElevatorButtonCall.BP_ElevatorButtonCall_C:ButtonPush"
	local hook1, hook2 = RegisterHook(funcName, ButtonPush)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/Blueprints/DigitCode/BP_DigitCode_Locker.BP_DigitCode_Locker_C:ButtonPush"
	local hook1, hook2 = RegisterHook(funcName, ButtonPush)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/Models/Elevator/BP_elevator_False.BP_elevator_False_C:ButtonPush"
	local hook1, hook2 = RegisterHook(funcName, ButtonPush)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/Blueprints/BP_elevator.BP_elevator_C:ButtonPush"
	local hook1, hook2 = RegisterHook(funcName, ButtonPush)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
    
    local funcName = "/Game/Blueprints/BP_HandDryer.BP_HandDryer_C:ExecuteUbergraph_BP_HandDryer"
	local hook1, hook2 = RegisterHook(funcName, ExecuteUbergraph_BP_HandDryer)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
    
    local funcName = "/Game/Blueprints/Inventory/BP_Inventory.BP_Inventory_C:OnSwitchToMap"
	local hook1, hook2 = RegisterHook(funcName, InventorySwitch)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/Blueprints/Inventory/BP_Inventory.BP_Inventory_C:OnSwitchToNote"
	local hook1, hook2 = RegisterHook(funcName, InventorySwitch)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/Blueprints/Inventory/BP_Inventory.BP_Inventory_C:OnSwitchToJournal"
	local hook1, hook2 = RegisterHook(funcName, InventorySwitch)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/Blueprints/Inventory/BP_Inventory.BP_Inventory_C:OnSwitchToInventory"
	local hook1, hook2 = RegisterHook(funcName, InventorySwitch)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/Blueprints/MotionControllerPawn.MotionControllerPawn_C:ExecuteTeleportation"
	local hook1, hook2 = RegisterHook(funcName, ExecuteTeleportation)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/Blueprints/Weapons/BP_Shotgun_Small.BP_Shotgun_Small_C:FinishShoot"
	local hook1, hook2 = RegisterHook(funcName, ShotgunSmallFinishShoot)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/Blueprints/Weapons/BP_WeaponBase.BP_WeaponBase_C:SpawnBulletChamber"
	local hook1, hook2 = RegisterHook(funcName, SpawnBulletChamber)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/Blueprints/BP_KeyLocker.BP_KeyLocker_C:GetHandRotation"
	local hook1, hook2 = RegisterHook(funcName, GetHandRotation)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
    
    local funcName = "/Game/Blueprints/BP_Door1.BP_Door1_C:UnlockSound"
	local hook1, hook2 = RegisterHook(funcName, UnlockSound)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
        
    local funcName = "/Game/Blueprints/Furnitures/BP_Door_ControlPanel.BP_Door_ControlPanel_C:BPI_Locker_Unlock"
	local hook1, hook2 = RegisterHook(funcName, UnlockSound)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }



    local funcName = "/Game/Blueprints/Items/Notes/Parents/BP_Note_MultiPage.BP_Note_MultiPage_C:TurnPageDispatch_Event_0"
	local hook1, hook2 = RegisterHook(funcName, TurnPageDispatch_Event_0)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }







    -- local funcName = "/Game/Blueprints/BPI_Furniture.BPI_Furniture_C:BPI_Furniture_Unlock"
	-- local hook1, hook2 = RegisterHook(funcName, UnlockSound)
	-- hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    -- local funcName = "/Game/Blueprints/Furnitures/BP_Door_Small.BP_Door_Small_C:BPI_Furniture_Unlock"
	-- local hook1, hook2 = RegisterHook(funcName, UnlockSound)
	-- hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    
    -- local funcName = "/Game/Blueprints/BP_ControlPanel.BP_ControlPanel_C:BPI_Locker_Unlock"
	-- local hook1, hook2 = RegisterHook(funcName, UnlockSound)
	-- hookIds[funcName] = { id1 = hook1; id2 = hook2 }
    
    -- local funcName = "/Game/Materials/Kitchen/Lift/ButtonCall/BP_LiftKitchenButtonCall.BP_LiftKitchenButtonCall_C:ButtonPush"
	-- local hook1, hook2 = RegisterHook(funcName, ButtonPush)
	-- hookIds[funcName] = { id1 = hook1; id2 = hook2 }


end

-- *******************************************************************


function GetHandRotation(self)
    if isUnlocakSound == false then
        return
    end
    isUnlocakSound = false
    if self:get():GetPropertyValue("LastHandAttach"):GetPropertyValue("hand") == 0 then 
        SendMessage("----------------------------------")
        SendMessage("LeftHandUnlockDoor")
        truegear.play_effect_by_uuid("LeftHandPickupItem")
    else
        SendMessage("----------------------------------")
        SendMessage("RightHandUnlockDoor")
        truegear.play_effect_by_uuid("RightHandPickupItem")
    end
    SendMessage(self:get():GetFullName())
    SendMessage(self:get():GetPropertyValue("UnlockAngle"))
    SendMessage(self:get():GetPropertyValue("MaxAngle"))
    SendMessage(tostring(self:get():GetPropertyValue("LastHandAttach"):GetPropertyValue("AngleOverlapCheck")))
    SendMessage(tostring(self:get():GetPropertyValue("LastHandAttach"):GetFullName()))
    SendMessage(tostring(self:get():GetPropertyValue("AlreadyOpen")))
    SendMessage(tostring(self:get():GetPropertyValue("ShouldDestroyKey")))

end


function UnlockSound(self)
    isUnlocakSound = true
    SendMessage("----------------------------------")
    SendMessage("UnlockSound")
    SendMessage(self:get():GetFullName())
end

function SpawnBulletChamber(self)
    if self:get():GetPropertyValue("MainHand"):GetPropertyValue("hand") == 0 then
        SendMessage("----------------------------------")
        SendMessage("LeftDownReload")
        truegear.play_effect_by_uuid("LeftDownReload")
    elseif self:get():GetPropertyValue("MainHand"):GetPropertyValue("hand") == 1 then
        SendMessage("----------------------------------")
        SendMessage("RightDownReload")
        truegear.play_effect_by_uuid("RightDownReload")
    end
end

function TurnPageDispatch_Event_0(self)

    if self:get():GetPropertyValue("MainHand"):GetPropertyValue("hand") == 1 then
        SendMessage("LeftHandPickupItem")
        truegear.play_effect_by_uuid("LeftHandPickupItem")
    else
        SendMessage("----------------------------------")
        SendMessage("RightHandPickupItem")
        truegear.play_effect_by_uuid("RightHandPickupItem")
    end
    SendMessage(self:get():GetFullName())
    SendMessage(tostring(self:get():GetPropertyValue("MainHand"):GetPropertyValue("hand")))
end


function ExecuteTeleportation(self)
    SendMessage("----------------------------------")
    SendMessage("Teleport")
    truegear.play_effect_by_uuid("Teleport")
    SendMessage(self:get():GetFullName())
end

local buttonPushTime = 0
function ButtonPush(self,ButtonPush)
    if os.clock() - buttonPushTime < 0.2 then
        buttonPushTime = os.clock()
        return
    end
    buttonPushTime = os.clock()
    if leftHandSpeed > rightHandSpeed then
        SendMessage("LeftHandPickupItem")
        truegear.play_effect_by_uuid("LeftHandPickupItem")
    else
        SendMessage("----------------------------------")
        SendMessage("RightHandPickupItem")
        truegear.play_effect_by_uuid("RightHandPickupItem")
    end
    SendMessage("ButtonPush")
    SendMessage(self:get():GetFullName())
    SendMessage(tostring(ButtonPush:get()))
end

function HandSpeed(p1,p2,time)
    local dx = p2.X - p1.X
    local dy = p2.Y - p1.Y
    local dz = p2.Z - p1.Z
    local dis = math.sqrt(dx * dx + dy * dy + dz * dz)
    return dis / time
end

function HandSpeedCheck(self)
    if self:get():GetPropertyValue("hand") == 0 then
        if leftHandPos.X == nil then
            leftHandPos.X = self:get():GetPropertyValue("HandTransform").Translation.X
            leftHandPos.Y = self:get():GetPropertyValue("HandTransform").Translation.Y
            leftHandPos.Z = self:get():GetPropertyValue("HandTransform").Translation.Z
            leftHandTime = os.clock()
        else
            leftHandSpeed = HandSpeed(self:get():GetPropertyValue("HandTransform").Translation,leftHandPos,os.clock() - leftHandTime)
            leftHandPos.X = self:get():GetPropertyValue("HandTransform").Translation.X
            leftHandPos.Y = self:get():GetPropertyValue("HandTransform").Translation.Y
            leftHandPos.Z = self:get():GetPropertyValue("HandTransform").Translation.Z
            leftHandTime = os.clock()
        end
    elseif self:get():GetPropertyValue("hand") == 1 then
        if rightHandPos.X == nil then
            rightHandPos.X = self:get():GetPropertyValue("HandTransform").Translation.X
            rightHandPos.Y = self:get():GetPropertyValue("HandTransform").Translation.Y
            rightHandPos.Z = self:get():GetPropertyValue("HandTransform").Translation.Z
            rightHandTime = os.clock()
        else
            rightHandSpeed = HandSpeed(self:get():GetPropertyValue("HandTransform").Translation,leftHandPos,os.clock() - rightHandTime)
            rightHandPos.X = self:get():GetPropertyValue("HandTransform").Translation.X
            rightHandPos.Y = self:get():GetPropertyValue("HandTransform").Translation.Y
            rightHandPos.Z = self:get():GetPropertyValue("HandTransform").Translation.Z
            rightHandTime = os.clock()
        end
    end
  
end

function InventorySwitch(self)
    if self:get():GetPropertyValue("SecondHand").hand == 0 then
        SendMessage("LeftHandPickupItem")
        truegear.play_effect_by_uuid("LeftHandPickupItem")
    elseif self:get():GetPropertyValue("SecondHand").hand == 1 then
        SendMessage("----------------------------------")
        SendMessage("RightHandPickupItem")
        truegear.play_effect_by_uuid("RightHandPickupItem")
    end

end

function RingBellButtonPush(self)
    if leftHandSpeed > rightHandSpeed then
        SendMessage("----------------------------------")
        SendMessage("LeftHandPickupItem")
        truegear.play_effect_by_uuid("LeftHandPickupItem")
    else
        SendMessage("----------------------------------")
        SendMessage("RightHandPickupItem")
        truegear.play_effect_by_uuid("RightHandPickupItem")
    end

    SendMessage(self:get():GetFullName())
end

function ExecuteUbergraph_BP_HandDryer(self)
    if os.clock() - handDryerTime < 0.12 then
        return
    end
    handDryerTime = os.clock()
    if #self:get():GetPropertyValue("ActualHandOverlap") == 2 then
        SendMessage("----------------------------------")
        SendMessage("LeftHandHandDryer")
        SendMessage("RightHandHandDryer")
    elseif #self:get():GetPropertyValue("ActualHandOverlap") == 1 then
        if self:get():GetPropertyValue("ActualHandOverlap")[1].hand == 0 then
            SendMessage("----------------------------------")
            SendMessage("LeftHandHandDryer")
            truegear.play_effect_by_uuid("LeftHandHandDryer")
        else
            SendMessage("----------------------------------")
            SendMessage("RightHandHandDryer")
            truegear.play_effect_by_uuid("RightHandHandDryer")
        end
    end

end

function Crouch(self)
    SendMessage("----------------------------------")
    SendMessage("Crouch")
    truegear.play_effect_by_uuid("Crouch")
    SendMessage(self:get():GetFullName())
end

function ComputeActualLocAndAxes(self)
    if self:get():GetPropertyValue("isSnapped") then
        if os.clock() - cutTime > 0.12 then
            cutTime = os.clock()
            SendMessage("----------------------------------")
            SendMessage("ComputeActualLocAndAxes")
            truegear.play_effect_by_uuid("ComputeActualLocAndAxes")
            SendMessage(self:get():GetFullName())
            SendMessage(tostring(self:get():GetPropertyValue("isSnapped")))
        end
    end
end


function CutReceiveBeginPlay(self)
    SendMessage("----------------------------------")
    SendMessage("ChestSlotOutputItem")
    truegear.play_effect_by_uuid("ChestSlotOutputItem")
    SendMessage(self:get():GetFullName())
end



function UpdateSidePlayer(self,Side)
    SendMessage("----------------------------------")
    SendMessage("UpdateSidePlayer")
    SendMessage(self:get():GetFullName())
    SendMessage(tostring(Side:get()))
    firearmSide = Side:get()
end

function OpenLevel(self)
    SendMessage("----------------------------------")
    SendMessage("OpenLevel")
    truegear.play_effect_by_uuid("LevelStarted")
    SendMessage(self:get():GetFullName())
    isPause = false
    playerHealth = 100
end

function Close(self)
    playerHealth = self:get():GetPropertyValue("PlayerPawn"):GetPropertyValue("Health")
    SendMessage("----------------------------------")
    SendMessage("Close")
    SendMessage(self:get():GetFullName())
    isPause = false
end

function Open(self)
    SendMessage("----------------------------------")
    SendMessage("Open")
    SendMessage(self:get():GetFullName())
    electricScrewdriverHand = nil
    isPause = true    
end

function CheckPunchDirection(self,Velocity,InRange)
    if self:get():GetPropertyValue("hand") == 0 then
        if os.clock() - leftpunchTime < 0.200 then
            return
        end
        leftpunchTime = os.clock()
        SendMessage("----------------------------------")
        SendMessage("LeftHandMeleeHit")
        truegear.play_effect_by_uuid("LeftHandMeleeHit")
    else
        if os.clock() - rightpunchTime < 0.200 then
            return
        end
        rightpunchTime = os.clock()
        SendMessage("----------------------------------")
        SendMessage("RightHandMeleeHit")
        truegear.play_effect_by_uuid("RightHandMeleeHit")
    end

    SendMessage(tostring(os.clock()))
    SendMessage(self:get():GetFullName())
    SendMessage(tostring(self:get():GetPropertyValue("hand")))
    
end

function ReceiveAnyDamage(self,Damage,DamageType,InstigatedBy,DamageCauser)
    playerHealth = self:get():GetPropertyValue("Health")
    if Damage:get() < 0 then
        if os.clock() - healingTime > 1 then
            SendMessage("----------------------------------")
            SendMessage("Healing")
            truegear.play_effect_by_uuid("Healing")
            healingTime = os.clock()
        end
        return
    end

    if self:get():GetPropertyValue("Health") <= 0 then
        SendMessage("----------------------------------")
        SendMessage("PlayerDeath")
        truegear.play_effect_by_uuid("PlayerDeath")
        playerHealth = 100
        return
    end

    local camera = self:get():GetPropertyValue("Controller"):GetPropertyValue("PlayerCameraManager")
	if camera:IsValid() ~= true then
		SendMessage("camera is not found")
		return
	end
	local view = camera:GetPropertyValue("ViewTarget")
	if view:IsValid() ~= true then
		SendMessage("view is not found")
		return
	end
	local playerYaw = view.POV.Rotation.Yaw

    local causerController = DamageCauser:get():GetPropertyValue("Controller")
    if causerController:IsValid() ~= true then
        SendMessage("----------------------------------")
        SendMessage("PoisonDamage")
        truegear.play_effect_by_uuid("PoisonDamage")
		SendMessage("causerController is not found")
		return
	end
    local causerControllerRotation = causerController:GetPropertyValue("ControlRotation")
    if causerControllerRotation:IsValid() ~= true then
        SendMessage("----------------------------------")
        SendMessage("PoisonDamage")
        truegear.play_effect_by_uuid("PoisonDamage")
		SendMessage("causerControlRotation is not found")
		return
	end

    local angleYaw = playerYaw - causerControllerRotation.Yaw
	angleYaw = angleYaw + 180
	if angleYaw > 360 then 
		angleYaw = angleYaw - 360
	elseif angleYaw < 0 then
		angleYaw = 360 + angleYaw
	end

    SendMessage("----------------------------------")
    SendMessage("DefaultDamage," .. angleYaw .. ",0")
    PlayAngle("DefaultDamage",angleYaw,0)
    SendMessage(self:get():GetFullName())
    SendMessage(tostring(Damage:get()))
    SendMessage(InstigatedBy:get():GetFullName())
    SendMessage(DamageCauser:get():GetFullName())
    SendMessage(tostring(self:get():GetPropertyValue("Health")))


end


function ElectricScrewdriverActionPressed(self,hand)
    if hand:get():GetPropertyValue("hand") == 0 then
        -- SendMessage("----------------------------------")
        -- SendMessage("LeftHandElectricScrewdriver")
        electricScrewdriverHand = "Left"
    else
        -- SendMessage("----------------------------------")
        -- SendMessage("RightHandElectricScrewdriver")
        electricScrewdriverHand = "Right"
    end
    -- SendMessage(self:get():GetFullName())
    -- SendMessage(tostring(hand:get():GetPropertyValue("hand")))
end

function ElectricScrewdriverActionReleased(self,hand)
    SendMessage("----------------------------------")
    SendMessage("ElectricScrewdriverActionReleased")
    SendMessage(self:get():GetFullName())
    electricScrewdriverHand = nil
end

function FlashLightActionPressed(self,hand)
    if hand:get():GetPropertyValue("hand") == 0 then
        SendMessage("----------------------------------")
        SendMessage("LeftHandPickupItem")
        truegear.play_effect_by_uuid("LeftHandPickupItem")
    else
        SendMessage("----------------------------------")
        SendMessage("RightHandPickupItem")
        truegear.play_effect_by_uuid("RightHandPickupItem")
    end
    SendMessage(self:get():GetFullName())
    SendMessage(tostring(hand:get():GetPropertyValue("hand")))
end

function BPI_Holster_AddItem111(self,ItemType,Item)
    if firearmSide == 1 then
        if ItemType:get() == 0 then         --手枪
            SendMessage("----------------------------------")
            SendMessage("LeftHipSlotInputItem")
            truegear.play_effect_by_uuid("LeftHipSlotInputItem")
        elseif ItemType:get() == 1 then     --霰弹枪
            SendMessage("----------------------------------")
            SendMessage("LeftBackSlotInputItem")
            truegear.play_effect_by_uuid("LeftBackSlotInputItem")
        elseif ItemType:get() == 2 then     --手电筒
            SendMessage("----------------------------------")
            SendMessage("RightChestSlotInputItem")
            truegear.play_effect_by_uuid("RightChestSlotInputItem")
        elseif ItemType:get() == 3 then     --喷雾
            SendMessage("----------------------------------")
            SendMessage("RightHipSlotInputItem")
            truegear.play_effect_by_uuid("RightHipSlotInputItem")
        else
            SendMessage("----------------------------------")
            SendMessage("ChestSlotInputItem")
            truegear.play_effect_by_uuid("ChestSlotInputItem")
        end
    else
        if ItemType:get() == 0 then
            SendMessage("----------------------------------")
            SendMessage("RightHipSlotInputItem")
            truegear.play_effect_by_uuid("RightHipSlotInputItem")
        elseif ItemType:get() == 1 then
            SendMessage("----------------------------------")
            SendMessage("RightBackSlotInputItem")
            truegear.play_effect_by_uuid("RightBackSlotInputItem")
        elseif ItemType:get() == 2 then
            SendMessage("----------------------------------")
            SendMessage("LeftChestSlotInputItem")
            truegear.play_effect_by_uuid("LeftChestSlotInputItem")
        elseif ItemType:get() == 3 then
            SendMessage("----------------------------------")
            SendMessage("LeftHipSlotInputItem")
            truegear.play_effect_by_uuid("LeftHipSlotInputItem")
        else
            SendMessage("----------------------------------")
            SendMessage("ChestSlotInputItem")
            truegear.play_effect_by_uuid("ChestSlotInputItem")
        end
    end
    SendMessage(self:get():GetFullName())
    SendMessage(tostring(ItemType:get()))
    SendMessage(Item:get():GetFullName())
end

function BPI_Holster_RemoveItem111(self,ItemType,Item)
    if string.find(Item:get():GetFullName(),"BP_BoltCutter_C") then
        return
    end
    if firearmSide == 1 then
        if ItemType:get() == 0 then         --手枪
            SendMessage("----------------------------------")
            SendMessage("LeftHipSlotOutputItem")
            truegear.play_effect_by_uuid("LeftHipSlotOutputItem")
        elseif ItemType:get() == 1 then     --霰弹枪
            SendMessage("----------------------------------")
            SendMessage("LeftBackSlotOutputItem")
            truegear.play_effect_by_uuid("LeftBackSlotOutputItem")
        elseif ItemType:get() == 2 then     --手电筒
            SendMessage("----------------------------------")
            SendMessage("RightChestSlotOutputItem")
            truegear.play_effect_by_uuid("RightChestSlotOutputItem")
        elseif ItemType:get() == 3 then     --喷雾
            SendMessage("----------------------------------")
            SendMessage("RightHipSlotOutputItem")
            truegear.play_effect_by_uuid("RightHipSlotOutputItem")
        else
            SendMessage("----------------------------------")
            SendMessage("ChestSlotOutputItem")
            truegear.play_effect_by_uuid("ChestSlotOutputItem")
        end
    else
        if ItemType:get() == 0 then
            SendMessage("----------------------------------")
            SendMessage("RightHipSlotOutputItem")
            truegear.play_effect_by_uuid("RightHipSlotOutputItem")
        elseif ItemType:get() == 1 then
            SendMessage("----------------------------------")
            SendMessage("RightBackSlotOutputItem")
            truegear.play_effect_by_uuid("RightBackSlotOutputItem")
        elseif ItemType:get() == 2 then
            SendMessage("----------------------------------")
            SendMessage("LeftChestSlotOutputItem")
            truegear.play_effect_by_uuid("LeftChestSlotOutputItem")
        elseif ItemType:get() == 3 then
            SendMessage("----------------------------------")
            SendMessage("LeftHipSlotOutputItem")
            truegear.play_effect_by_uuid("LeftHipSlotOutputItem")
        else
            SendMessage("----------------------------------")
            SendMessage("ChestSlotOutputItem")
            truegear.play_effect_by_uuid("ChestSlotOutputItem")
        end
    end
    SendMessage(self:get():GetFullName())
    SendMessage(tostring(ItemType:get()))
    SendMessage(Item:get():GetFullName())
end

function GrabActor(self,isAltGrabAction)
    if self:get():GetPropertyValue("AttachedActor"):GetFullName() == nil then
        return
    end    
    if self:get():GetPropertyValue("hand") == 0 then
        SendMessage("----------------------------------")
        SendMessage("LeftHandPickupItem")
        truegear.play_effect_by_uuid("LeftHandPickupItem")
    else
        SendMessage("----------------------------------")
        SendMessage("RightHandPickupItem")
        truegear.play_effect_by_uuid("RightHandPickupItem")
    end
    SendMessage(self:get():GetFullName())
    SendMessage("hand :" .. tostring(self:get():GetPropertyValue("hand")))    
    SendMessage("AttachedActor :" .. tostring(self:get():GetPropertyValue("AttachedActor"):GetFullName()))  
end

function ShotgunSmallFinishShoot(self)
    if self:get():GetPropertyValue("TwoHand") then
        SendMessage("----------------------------------")
        SendMessage("LeftHandShotgunShoot")
        truegear.play_effect_by_uuid("LeftHandShotgunShoot")
        SendMessage("RightHandShotgunShoot")
        truegear.play_effect_by_uuid("RightHandShotgunShoot")
    elseif self:get():GetPropertyValue("MainHand"):GetPropertyValue("hand") == 0 then
        SendMessage("----------------------------------")
        SendMessage("LeftHandShotgunShoot")
        truegear.play_effect_by_uuid("LeftHandShotgunShoot")
    else
        SendMessage("----------------------------------")
        SendMessage("RightHandShotgunShoot")
        truegear.play_effect_by_uuid("RightHandShotgunShoot")
    end
    -- SendMessage("----------------------------------")
    SendMessage("ShotgunSmallFinishShoot")
    SendMessage(self:get():GetFullName())
end

function FinishShoot(self)
    if self:get():GetPropertyValue("TwoHand") then
        if string.find(self:get():GetFullName(),"BP_Berreta_Child_C") then
            SendMessage("----------------------------------")
            SendMessage("LeftHandPistolShoot")
            truegear.play_effect_by_uuid("LeftHandPistolShoot")
            SendMessage("RightHandPistolShoot")
            truegear.play_effect_by_uuid("RightHandPistolShoot")
        else
            SendMessage("----------------------------------")
            SendMessage("LeftHandShotgunShoot")
            truegear.play_effect_by_uuid("LeftHandShotgunShoot")
            SendMessage("RightHandShotgunShoot")
            truegear.play_effect_by_uuid("RightHandShotgunShoot")
        end
    elseif self:get():GetPropertyValue("MainHand"):GetPropertyValue("hand") == 0 then
        if string.find(self:get():GetFullName(),"BP_Berreta_Child_C") then
            SendMessage("----------------------------------")
            SendMessage("LeftHandPistolShoot")
            truegear.play_effect_by_uuid("LeftHandPistolShoot")
        else
            SendMessage("----------------------------------")
            SendMessage("LeftHandShotgunShoot")
            truegear.play_effect_by_uuid("LeftHandShotgunShoot")
        end
    else
        if string.find(self:get():GetFullName(),"BP_Berreta_Child_C") then
            SendMessage("----------------------------------")
            SendMessage("RightHandPistolShoot")
            truegear.play_effect_by_uuid("RightHandPistolShoot")
        else
            SendMessage("----------------------------------")
            SendMessage("RightHandShotgunShoot")
            truegear.play_effect_by_uuid("RightHandShotgunShoot")
        end
    end
    SendMessage(self:get():GetFullName())
    SendMessage("IsGrabbed :" .. tostring(self:get():GetPropertyValue("IsGrabbed")))
    SendMessage("MainHand :" .. tostring(self:get():GetPropertyValue("MainHand"):GetFullName()))
    SendMessage("hand :" .. tostring(self:get():GetPropertyValue("MainHand"):GetPropertyValue("hand")))
    SendMessage("TwoHand :" .. tostring(self:get():GetPropertyValue("TwoHand")))    
end


truegear.seek_by_uuid("DefaultDamage")
truegear.init("1824960", "Propagation:Paradise Hotel")

function CheckPlayerSpawned()
	RegisterHook("/Script/Engine.PlayerController:ClientRestart", function()
		if resetHook then
			local ran, errorMsg = pcall(RegisterHooks)
			if ran then
				SendMessage("--------------------------------")
				SendMessage("HeartBeat")
				truegear.play_effect_by_uuid("HeartBeat")
				resetHook = false
			else
				print(errorMsg)				
			end
		end		
	end)
end

-- function CheckPlayerSpawned()
--     RegisterHooks()
-- end

function HeartBeat()
    if isPause then
        return
    end
    if playerHealth < 33 then
        SendMessage("--------------------------------")
		SendMessage("HeartBeat")
		truegear.play_effect_by_uuid("HeartBeat")
    end
end

function ElectricScrewdriver()
    if isPause then
        return
    end
    if electricScrewdriverHand ~= nil then
        if electricScrewdriverHand == "Left" then
            SendMessage("--------------------------------")
            SendMessage("LeftHandElectricScrewdriver")
            truegear.play_effect_by_uuid("LeftHandElectricScrewdriver")
        elseif electricScrewdriverHand == "Right" then
            SendMessage("--------------------------------")
            SendMessage("RightHandElectricScrewdriver")
            truegear.play_effect_by_uuid("RightHandElectricScrewdriver")
        end
    end
end

SendMessage("TrueGear Mod is Loaded");
CheckPlayerSpawned()

LoopAsync(1000, HeartBeat)
LoopAsync(120, ElectricScrewdriver)