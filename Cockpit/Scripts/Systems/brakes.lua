dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."functions.lua")

startup_print("brakes: load")

local dev = GetSelf()

local update_time_step = 0.02 --update will be called 50 times per second
make_default_activity(update_time_step)

local sensor_data = get_base_data()


local iCommandPlaneWheelBrakeOn = 74
local iCommandPlaneWheelBrakeOff = 75
local iCommandWheelBrake = 2101
local iCommandLeftWheelBrake = 2112
local iCommandRightWheelBrake = 2113

-- "below velocity v, use brake ratio x"

local brake_table = {
    {5,10, 14, 20, 30,  45, 999},     -- velocity in m/s
    {1, 4,  3,  3,  2,   1,   1},     -- numerator of brake power ratio
    {1, 5,  5,  5,  5,   3,   4},     -- denominator of brake power ratio
}

local function get_brake_ratio(v)
    for i = 1,#brake_table[1] do
        if v <= brake_table[1][i] then
            return brake_table[2][i],brake_table[3][i]
        end
    end
    return 1,7
end

local left_brake_pedal_param = get_param_handle("LEFT_BRAKE_PEDAL")
local right_brake_pedal_param = get_param_handle("RIGHT_BRAKE_PEDAL")
local brake_now = 0
local brakes_on = false
local brakes_on_last = brakes_on
local brake_eff = get_param_handle("BRAKE_EFF")
local single_wheelbrake_axis_value = -1
local left_wheelbrake_AXIS_value = -1
local right_wheelbrake_AXIS_value = -1
local wheelbrake_axis_value = -1
local wheelbrake_toggle_state = false


function update()
        -- calculate combined brake axis
        wheelbrake_axis_value = -1

        wheelbrake_axis_value = single_wheelbrake_axis_value
        if left_wheelbrake_AXIS_value > wheelbrake_axis_value then
            wheelbrake_axis_value = left_wheelbrake_AXIS_value
        end

        if right_wheelbrake_AXIS_value > wheelbrake_axis_value then
            wheelbrake_axis_value = right_wheelbrake_AXIS_value
        end

        if wheelbrake_axis_value > -0.95 or wheelbrake_toggle_state == true then
            brakes_on = true
        else
            brakes_on = false
        end
        if wheelbrake_toggle_state == true then
            wheelbrake_axis_value = 1
        end

        if brakes_on then
            --local x,y = get_brake_ratio(vel_xz_brakes())
            local x,y = get_brake_ratio(wheelbrake_axis_value)
            -- brake_now cycles from 1 to y
            -- brakes are enabled if brake_now <= x
            -- adjust ratios in brake_table above
    
            if brake_now <= x then
                dispatch_action(nil,iCommandPlaneWheelBrakeOn)
            else
                dispatch_action(nil,iCommandPlaneWheelBrakeOff)
            end
    
            brake_eff:set(100*x/y)
    
            brake_now = brake_now + 1
            if brake_now > y then
                brake_now = 1
            end
        else
            -- turn off the brakes if the brakes were still on
            -- brakes are not set again if the brakes are already off
            if brakes_on_last ~= brakes_on then  -- edge triggered
                dispatch_action(nil,iCommandPlaneWheelBrakeOff)
                brake_eff:set(0)
            end
        end
        brakes_on_last = brakes_on
    
        -- update brake pedal positions
        left_brake_pedal_param:set(wheelbrake_axis_value)
        right_brake_pedal_param:set(wheelbrake_axis_value)
        -- print_message_to_user(wheelbrake_axis_value)
end

function post_initialize()
    startup_print("brakes: postinit start")
    local birth = LockOn_Options.init_conditions.birth_place

    if birth=="GROUND_HOT" or birth=="AIR_HOT" then
        dev:performClickableAction(device_commands.EmerParkBrake, -1, true)
    elseif birth=="GROUND_COLD" then
        dev:performClickableAction(device_commands.EmerParkBrake, 1, true)
    end
    dev:performClickableAction(iCommandWheelBrake, -1, true)
    dev:performClickableAction(iCommandLeftWheelBrake, -1, true)
    dev:performClickableAction(iCommandRightWheelBrake, -1, true)
    startup_print("brakes: postinit end")
end

dev:listen_command(device_commands.EmerParkBrake)
dev:listen_command(iCommandPlaneWheelBrakeOn)
dev:listen_command(iCommandPlaneWheelBrakeOff)
dev:listen_command(iCommandWheelBrake)
dev:listen_command(iCommandLeftWheelBrake)
dev:listen_command(iCommandRightWheelBrake)

local pbrake_light = get_param_handle("PBRAKE_LIGHT")

function SetCommand(command,value)
    debug_message_to_user("brakes: command "..tostring(command).." = "..tostring(value))
    if command==device_commands.EmerParkBrake then
        if value ==-1 then
            dispatch_action(nil,iCommandPlaneWheelBrakeOff)
            pbrake_light:set(0)
        else 
            dispatch_action(nil,iCommandPlaneWheelBrakeOn)
            pbrake_light:set(1)
        end
    elseif command == iCommandPlaneWheelBrakeOff then
        dev:performClickableAction(device_commands.EmerParkBrake, -1, true)
    elseif command == iCommandPlaneWheelBrakeOn then

    elseif command == iCommandWheelBrake then
		single_wheelbrake_axis_value = value
    elseif command == iCommandLeftWheelBrake then
        left_wheelbrake_AXIS_value = value
    elseif command == iCommandRightWheelBrake then
        right_wheelbrake_AXIS_value = value


        -- dev:performClickableAction(device_commands.EngineStart, 0, true)
        -- print_message_to_user("LG=" ..tostring(sensor_data:getWOW_LeftMainLandingGear()))

        -- local lat, lon, alt, nalt = sensor_data.getSelfCoordinates()
        -- print_message_to_user("SelfCoord: " ..tostring(lat).. " ".. tostring(lon).." "..tostring(alt).." "..tostring(nalt))

        -- speed, speeda, speedb = sensor_data.getSelfAirspeed()
        -- print_message_to_user("SelfAirspd: " ..tostring(speed) .. "  "..tostring(speeda) .." "..tostring(speedb))

        -- speedd = math.sqrt(speed*speed + speeda*speeda + speedb*speedb)

        -- local speed, speeda, speedb, speedc = sensor_data:getSelfVelocity()
        -- print_message_to_user("SelfVel: " ..tostring(speed) .. ","..tostring(speeda) .." "..tostring(speedb).." ".. tostring(speedc))
        
        -- speeda = math.sqrt(speed*speed + speeda*speeda + speedb*speedb)
        -- speed = sensor_data.getTrueAirSpeed()
        -- speedb = sensor_data.getIndicatedAirSpeed()
        -- print_message_to_user("TruefAirspd: " ..tostring(speed*1.94384) .. "  "..tostring(speedd*1.94384).. "  "..tostring(speeda*1.94384) .. "  ".. speedb*1.94384)

        -- speed = sensor_data.getVerticalVelocity()
        -- print_message_to_user("VertVel: " ..tostring(speed)  )

    end

end


startup_print("brakes: load end")
need_to_be_closed = false -- close lua state after initialization


