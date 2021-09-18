CREATE TABLE IF NOT EXISTS `vehicle_status` (
	`stats` LONGTEXT NULL COLLATE 'utf8mb4_general_ci',
	`plate` VARCHAR(64) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
	`owner` VARCHAR(64) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
	PRIMARY KEY (`plate`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
;
CREATE TABLE IF NOT EXISTS `body_status` (
	`status` LONGTEXT NULL COLLATE 'utf8mb4_general_ci',
	`identifier` VARCHAR(64) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
	PRIMARY KEY (`identifier`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
;
