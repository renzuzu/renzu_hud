
config.enable_carui = true -- enable/disable the car UI (THIS WILL DISABLE ALL VEHICLE FUNCTION AS WELL)
config.carui = 'simple' -- Choose a Carui Version ( simple, minimal, modern )
config.carui_metric = 'kmh' -- Speed Metrics to Use 'kmh' or 'mph'
config.WaypointMarkerLarge = false -- disable / enable large marker while on vehicle waypoint
config.available_carui = {
	['simple'] = true,
	['minimal'] = true,
	['modern'] = true,
}
config.seatbelt_2 = false
config.enable_carui_perclass = true -- enable/disable the Vehicle Class UI config (if this is enable , the config.carui will be ignored)
config.carui_perclass = {
	--change and define each class to show the vehicle UI class
	[0] = 'simple', -- Compacts
	[1] = 'simple', -- Sedans
	[2] = 'modern', -- SUVs
	[3] = 'minimal', -- Coupes
	[4] = 'simple', -- Muscle
	[5] = 'minimal', -- Sports Classics
	[6] = 'minimal', -- Sports
	[7] = 'minimal', -- Super
	[8] = 'simple', -- Motorcycles
	[9] = 'modern', -- Off-road
	[10] = 'modern', -- Industrial
	[11] = 'modern', -- Utility
	[12] = 'modern', -- Vans
	[13] = 'simple', -- Cycles
	[14] = 'simple', -- Boats
	[15] = 'simple', -- Helicopters
	[16] = 'simple', -- Planes
	[17] = 'modern', -- Service
	[18] = 'modern', -- Emergency
	[19] = 'modern', -- Military
	[20] = 'modern', -- Commercial
	[21] = 'simple', -- Trains
}

--start car map
config.centercarhud = 'map' -- Feature of Car hud - MAP , MP3 (IF YOU CHOOSE MP3 you need renzu_mp3 as dependency, and renzu_mp3 need xsound) (MP3 not implemented yet..lazy..)
config.mapversion = 'satellite' -- available ( satellite, atlas, oldschool )
config.usecustomlink = true -- use custom url of image map // use this for now , self hosted is remove due to file size issue
config.push_start = false -- enable/disable push to start for modern UI
config.mapurl = 'https://github.com/renzuzu/carmap/blob/main/carmap/atlas.webp?raw=true' -- if use custom url define it
--atlas link https://github.com/renzuzu/carmap/blob/main/carmap/oldschool.webp?raw=true
--satellite link https://github.com/renzuzu/carmap/blob/main/carmap/satellite.webp
--credits https://github.com/jgardner117/gtav-interactive-map