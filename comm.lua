local openFormation = true

function specialEvent(params) 
	return staticParamsEvent(Message.wMsgLeaderSpecialCommand, params)
end

local menus = data.menus

data.rootItem = {
	name = _('Main'),
	getSubmenu = function(self)	
		local tbl = {
			name = _('Main'),
			items = {}
		}
		
		if data.pUnit == nil or data.pUnit:isExist() == false then
			return tbl
		end
		
		if self.builders ~= nil then
			for index, builder in pairs(self.builders) do
				builder(self, tbl)
			end
		end
		
		if #data.menuOther.submenu.items > 0 then
			tbl.items[10] = {
				name = _('Other'),
				submenu = data.menuOther.submenu
			}
		end
		
		return tbl
	end,
	builders = {}
}

local parameters = {
	fighter = true,
	radar = true,
	ECM = true,
	refueling = true
}

local menus = data.menus

utils.verifyChunk(utils.loadfileIn('Scripts/UI/RadioCommandDialogPanel/Config/LockOnAirplane.lua', getfenv()))(parameters)

-- utils.verifyChunk(utils.loadfileIn('Scripts/UI/RadioCommandDialogPanel/Config/Common/JTAC.lua', getfenv()))(4)
--utils.verifyChunk(utils.loadfileIn('Scripts/UI/RadioCommandDialogPanel/Config/Common/ATC.lua', getfenv()))(5, {[Airbase.Category.AIRDROME] = true})
--utils.verifyChunk(utils.loadfileIn('Scripts/UI/RadioCommandDialogPanel/Config/Common/Tanker.lua', getfenv()))(6)
-- utils.verifyChunk(utils.loadfileIn('Scripts/UI/RadioCommandDialogPanel/Config/Common/AWACS.lua', getfenv()))(7, {tanker = true, radar = false})
--utils.verifyChunk(utils.loadfileIn('Scripts/UI/RadioCommandDialogPanel/Config/Common/Ground Crew.lua', getfenv()))(8)

-- Wheel Chocks
menus['Wheel chocks'] = {
	name = _('Wheel chocks'),
	items = {
		[1] = {
			name = _('Place_'), 		
			command = sendMessage.new(Message.wMsgLeaderGroundToggleWheelChocks, true)
		},
		[2] = {
			name = _('Remove_'),
			command = sendMessage.new(Message.wMsgLeaderGroundToggleWheelChocks, false)
		}
	}
}
menus['Ground Crew'].items[4] = { name = _('Wheel chocks'), submenu = menus['Wheel chocks']}
menus['Ground Crew'].items[5] = { name = _('Salute!'), command = sendMessage.new(Message.wMsgLeaderGroundGestureSalut, true)}
menus['Ground Crew'].items[6] = { name = _('Request Launch'), command = sendMessage.new(Message.wMsgLeaderGroundRequestLaunch, true)}