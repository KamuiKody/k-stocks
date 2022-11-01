CREATE TABLE IF NOT EXISTS `stocks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `type` VARCHAR(50) NULL DEFAULT '0',
  `amount` int(100) NULL DEFAULT '0',
  PRIMARY KEY `id` (`id`)) ENGINE=InnoDB AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `stock_funds` (
`id` INT(11) NOT NULL AUTO_INCREMENT,
`job_name` VARCHAR(50) NOT NULL,
`amount`  INT(100) NOT NULL,
PRIMARY KEY (`id`),
UNIQUE KEY `job_name` (`job_name`)
);
