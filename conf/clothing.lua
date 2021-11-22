--clothes
config.use_esx_accesories = false -- use esx accesories for mask,helmet. (ESX FRAMEWORK)
-- PERMANENT HELMET AND MASK
-- this is optional only if you want the mask and helmet to be permanent instead of using your clothes settings, ex. wearing a cap, but you want/need a helmet soon.
-- using this https://github.com/esx-framework/esx_accessories ( saving to datastore instead from skinchanger table) -- rights belong to esx framework
-- we are using this function https://github.com/esx-framework/esx_accessories/blob/e812dde63bcb746e9b49bad704a9c9174d6329fa/client/main.lua#L30

-- configuration of animations ,variations, defaults when using Clothing UI
config.clothing = {
	--left
	['helmet_1'] = { -- parts
		['skin'] = {
			['helmet_1'] = -1, ['helmet_2'] = 0 -- variation type
		},
		['default'] = -1, -- the default variation
		['taskplay'] = {dictionary = "mp_masks@standard_car@ds@", name = "put_on_mask", speed = 51, duration = 800} -- animation settings
	},
	['helmet_2'] = {},
	['glasses_1'] = {
		['skin'] = {
			['glasses_1'] = 0, ['glasses_2'] = 0
		},
		['default'] = 0,
		['taskplay'] = {dictionary = "mp_masks@standard_car@ds@", name = "put_on_mask", speed = 51, duration = 800}
	},
	['glasses_2'] = {},
	['chain_1'] = {
		['skin'] = {
			['chain_1'] = 0, ['chain_2'] = 0
		},
		['default'] = 0,
		['taskplay'] = {dictionary = "clothingtie", name = "try_tie_positive_a", speed = 51, duration = 2100}
	},
	['chain_1'] = {},
	['watches_1'] = {
		['skin'] = {
			['watches_1'] = -1, ['watches_2'] = 0
		},
		['default'] = -1,
		['taskplay'] = {dictionary = "nmt_3_rcm-10", name = "cs_nigel_dual-10", speed = 51, duration = 1200}
	},
	['watches_2'] = {},
	--right
	['torso_1'] = {
		['skin'] = {
			['torso_1'] = 15, ['torso_2'] = 0,
			['arms'] = 15, ['arms_2'] = 0
		},
		['default'] = 15,
		['taskplay'] = {dictionary = "missmic4", name = "michael_tux_fidget", speed = 51, duration = 1500}
	},
	['torso_2'] = {},
	['tshirt_1'] = {
		['skin'] = {
			['tshirt_1'] = 15, ['tshirt_2'] = 0,
			['arms'] = 15, ['arms_2'] = 0
		},
		['default'] = 15,
		['taskplay'] = {dictionary = "missmic4", name = "michael_tux_fidget", speed = 51, duration = 1500}
	},
	['tshirt_2'] = {},
	['bproof_1'] = {
		['skin'] = {
			['bproof_1'] = 0, ['bproof_2'] = 0
		},
		['default'] = 0,
		['taskplay'] = {dictionary = "clothingtie", name = "try_tie_positive_a", speed = 51, duration = 2100}
	},
	['bproof_2'] = {},
	['pants_1'] = {
		['skin'] = {
			['pants_1'] = 14, ['pants_2'] = 0
		},
		['default'] = 14,
		['taskplay'] = {dictionary = "re@construction", name = "out_of_breath", speed = 51, duration = 800}
	},
	['shoes_1'] = {
		['skin'] = {
			['shoes_1'] = 49, ['shoes_2'] = 0
		},
		['default'] = 49,
		['taskplay'] = {dictionary = "random@domestic", name = "pickup_low", speed = 51, duration = 1200}
	},
	['shoes_2'] = {},
	--top
	['mask_1'] = {
		['skin'] = {
			['mask_1'] = 0, ['mask_2'] = 0
		},
		['default'] = 0,
		['taskplay'] = {dictionary = "mp_masks@standard_car@ds@", name = "put_on_mask", speed = 51, duration = 800}
	},
	['mask_2'] = {},
	--reset 
	['reset'] = {
		['taskplay'] = {dictionary = "missmic4", name = "michael_tux_fidget", speed = 51, duration = 1500}
	}
}