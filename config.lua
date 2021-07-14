Config = {}

Config.HandcuffTimer = 10 * 60000 -- 10 minutes.
Config.ZiptieRemovers = {
	scissors = { -- Name of item.
		timer = 5, -- How long it takes to remove zipties.
		OneTimeUse = false -- Remove after use? or allowed to use again.
	},
	ziptieremover = {
		timer = 3,
		OneTimeUse = false
	}
}