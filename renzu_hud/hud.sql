
ALTER TABLE `users`
	ADD `bodystatus` LONGTEXT NOT NULL DEFAULT '{}';

ALTER TABLE `owned_vehicles` -- change this if you use custom vehicles table
	ADD `adv_stats` LONGTEXT NOT NULL DEFAULT '{"plate":"nil","mileage":0.0}';
