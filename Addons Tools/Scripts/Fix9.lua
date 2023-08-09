local event_handlers = {}
local reaction_handlers = {}

common._RegisterEventHandler = common.RegisterEventHandler

common.RegisterEventHandler = function ( eventFunction, sysEventName, params )
	if event_handlers[sysEventName] == nil then
		event_handlers[sysEventName] = {}
	end
	if event_handlers[sysEventName][eventFunction] == nil then
		event_handlers[sysEventName][eventFunction] = true
		common._RegisterEventHandler( eventFunction, sysEventName, params )
	end
end

common._UnRegisterEventHandler = common.UnRegisterEventHandler

common.UnRegisterEventHandler = function ( eventFunction, sysEventName, params )
	if event_handlers[sysEventName] ~= nil and event_handlers[sysEventName][eventFunction] ~= nil then
		event_handlers[sysEventName][eventFunction] = nil
		common._UnRegisterEventHandler( eventFunction, sysEventName, params )
		for _,_ in pairs(event_handlers[sysEventName]) do return end
		event_handlers[sysEventName] = nil
	end
end

common._UnRegisterEvent = common.UnRegisterEvent

common.UnRegisterEvent = function ( sysEventName )
	if event_handlers[sysEventName] ~= nil then
		common._UnRegisterEvent( sysEventName )
		event_handlers[sysEventName] = nil
	end
end

common._RegisterReactionHandler = common.RegisterReactionHandler

common.RegisterReactionHandler = function ( reactionFunction, sysReactionName )
	if reaction_handlers[sysReactionName] == nil then
		reaction_handlers[sysReactionName] = {}
	end
	if reaction_handlers[sysReactionName][reactionFunction] == nil then
		reaction_handlers[sysReactionName][reactionFunction] = true
		common._RegisterReactionHandler( reactionFunction, sysReactionName )
	end
end

common._UnRegisterReactionHandler = common.UnRegisterReactionHandler

common.UnRegisterReactionHandler = function ( reactionFunction, sysReactionName )
	if reaction_handlers[sysReactionName] ~= nil and reaction_handlers[sysReactionName][reactionFunction] == true then
		reaction_handlers[sysReactionName][reactionFunction] = nil
		common._UnRegisterReactionHandler( reactionFunction, sysReactionName )
	end
end
