dofile(LockOn_Options.script_path.."command_defs.lua")
dofile(LockOn_Options.script_path.."functions.lua")
dofile(LockOn_Options.script_path.."Systems/electric_system_api.lua")

startup_print("intlights: load")

local dev = GetSelf()

local update_time_step = 1/30 --update will be called 50 times per second
make_default_activity(update_time_step)

local sensor_data = get_base_data()


function post_initialize()
    startup_print("intlights: postinit start")
    local birth = LockOn_Options.init_conditions.birth_place

    if birth=="GROUND_HOT" then
        dev:performClickableAction(device_commands.IntLightPnl, 0.5, true)
        dev:performClickableAction(device_commands.IntLightStorm, 0, true)
        dev:performClickableAction(device_commands.IntLightCsl, 0.5, true)
        dev:performClickableAction(device_commands.IntLightAlm, 0, true)
        dev:performClickableAction(device_commands.IntLightChart, 0.5, true)
        dev:performClickableAction(device_commands.IntLightNvg, 0, true)
    elseif birth=="AIR_HOT" then
        dev:performClickableAction(device_commands.IntLightPnl, 0.5, true)
        dev:performClickableAction(device_commands.IntLightStorm, 0, true)
        dev:performClickableAction(device_commands.IntLightCsl, 0.5, true)
        dev:performClickableAction(device_commands.IntLightAlm, 0, true)
        dev:performClickableAction(device_commands.IntLightChart, 0.5, true)
        dev:performClickableAction(device_commands.IntLightNvg, 0, true)
    elseif birth=="GROUND_COLD" then
        dev:performClickableAction(device_commands.IntLightPnl, 0, true)
        dev:performClickableAction(device_commands.IntLightStorm, 0, true)
        dev:performClickableAction(device_commands.IntLightCsl, 0, true)
        dev:performClickableAction(device_commands.IntLightAlm, 0, true)
        dev:performClickableAction(device_commands.IntLightChart, 0, true)
        dev:performClickableAction(device_commands.IntLightNvg, 0, true)
    end
    startup_print("intlights: postinit end")
end

dev:listen_command(device_commands.IntLightPnl)
dev:listen_command(device_commands.IntLightStorm)
dev:listen_command(device_commands.IntLightCsl)
dev:listen_command(device_commands.IntLightAlm)
dev:listen_command(device_commands.IntLightChart)
dev:listen_command(device_commands.IntLightNvg)


local pnlbacklightvalue = 0
local cslbacklightvalue = 0
local chartlightvalue = 0
local stormlightvalue = 0
local nvg = 1

local stormlight = get_param_handle("STORM_LIGHT")

function SetCommand(command,value)
    debug_message_to_user("intlights: command "..tostring(command).." = "..tostring(value))
    -- if get_cockpit_draw_argument_value(946) > 0 then nvg=0.3 else nvg=1 end
    if command==device_commands.IntLightPnl then
        pnlbacklightvalue = value
    elseif command == device_commands.IntLightCsl then
        cslbacklightvalue = value
    elseif command == device_commands.IntLightChart then
        chartlightvalue = value
    elseif command == device_commands.IntLightStorm then
        stormlightvalue = value
    elseif command == device_commands.IntLightNvg then
        if value == 0 then
            nvg=1
        elseif value == 1 then 
            nvg=0.3
        end
    end
end

local pnlbacklight = get_param_handle("PNL_BACKLIGHT")
local cslbacklight = get_param_handle("CSL_BACKLIGHT")
local chartlight = get_param_handle("CHART_LIGHT")

function update()
    if get_elec_main_bar_ok() then 
    pnlbacklight:set(pnlbacklightvalue*nvg)
    cslbacklight:set(cslbacklightvalue*nvg)
    chartlight:set(chartlightvalue*nvg)
        if nvg==0.3 then
            stormlight:set(0)
        else 
            stormlight:set(stormlightvalue*nvg)
        end
    else 
        pnlbacklight:set(0)
        cslbacklight:set(0)
        chartlight:set(0)
        stormlight:set(0)
    end
end



startup_print("intlights: load end")
need_to_be_closed = false -- close lua state after initialization

