-- =============================================================================
-- MOVENTRA Digital Freight OS  ·  MySQL / MariaDB for XAMPP
-- Import: phpMyAdmin → Import this file   OR   mysql -u root < moventra.sql
-- Default XAMPP user: root   password: (empty)
-- =============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';
SET time_zone = '+03:00';

DROP DATABASE IF EXISTS `moventra`;
CREATE DATABASE `moventra`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE `moventra`;

-- -----------------------------------------------------------------------------
-- 1) Users & role portal (matches ROLE_CREDS on the website)
--    Demo passwords (plain): cargo123 / trans456 / agent789 / admin2026
--    Stored as SHA2-256 hashes for hosting.
-- -----------------------------------------------------------------------------
CREATE TABLE `users` (
  `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `full_name`     VARCHAR(120) NOT NULL,
  `email`         VARCHAR(160) NOT NULL,
  `phone`         VARCHAR(40)  NOT NULL,
  `company`       VARCHAR(160) DEFAULT NULL,
  `id_licence_pin` VARCHAR(80) DEFAULT NULL,
  `role`          ENUM('Cargo Owner','Transporter','Clearing Agent','Admin') NOT NULL,
  `password_hash` CHAR(64) NOT NULL,
  `is_active`     TINYINT(1) NOT NULL DEFAULT 1,
  `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_users_email` (`email`),
  KEY `idx_users_role` (`role`)
) ENGINE=InnoDB;

INSERT INTO `users`
  (`full_name`,`email`,`phone`,`company`,`id_licence_pin`,`role`,`password_hash`)
VALUES
  ('John Otieno','john.otieno@moventra.co.ke','+254 712 345 678','MOVENTRA Freight Ltd','ID-8839201','Cargo Owner', SHA2('cargo123',256)),
  ('Daniel Mutua','daniel.mutua@moventra.ke','+254 722 100 001','Northern Corridor Hauliers','DL-KE-00123','Transporter', SHA2('trans456',256)),
  ('Amina Juma','amina.juma@clearing.tz','+255 753 639 103','Dar Clearing & Forwarding','CF-TZ-22041','Clearing Agent', SHA2('agent789',256)),
  ('MOVENTRA Admin','admin@moventra.co.ke','+254 707231160','MOVENTRA Logistics OS','ADM-2026','Admin', SHA2('admin2026',256));

-- -----------------------------------------------------------------------------
-- 2) Cities / GPS waypoints (CITY_COORDS)
-- -----------------------------------------------------------------------------
CREATE TABLE `cities` (
  `id`        INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`      VARCHAR(80) NOT NULL,
  `country`   VARCHAR(60) DEFAULT NULL,
  `latitude`  DECIMAL(10,6) NOT NULL,
  `longitude` DECIMAL(10,6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_cities_name` (`name`)
) ENGINE=InnoDB;

INSERT INTO `cities` (`name`,`country`,`latitude`,`longitude`) VALUES
  ('Mombasa Port','Kenya',-4.043500,39.668200),
  ('Nairobi','Kenya',-1.286400,36.817200),
  ('Nairobi ICD','Kenya',-1.312000,36.870000),
  ('Nakuru','Kenya',-0.301500,36.080000),
  ('Eldoret','Kenya',0.520400,35.269800),
  ('Naivasha','Kenya',-0.716700,36.430500),
  ('Kakamega','Kenya',0.282500,34.751900),
  ('Embu','Kenya',-0.539100,37.453400),
  ('Malaba','Kenya',0.634000,34.261000),
  ('Kisumu','Kenya',-0.091700,34.768000),
  ('Kericho','Kenya',-0.367700,35.283100),
  ('Kitale','Kenya',1.019100,35.006200),
  ('Busia','Kenya',0.460800,34.111500),
  ('Kampala','Uganda',0.347600,32.582500),
  ('Jinja','Uganda',0.447800,33.202600),
  ('Dar es Salaam','Tanzania',-6.792400,39.208300),
  ('Arusha','Tanzania',-3.386900,36.682000),
  ('Moshi','Tanzania',-3.355000,37.341000),
  ('Dodoma','Tanzania',-6.163000,35.751600),
  ('Mwanza','Tanzania',-2.516700,32.900000),
  ('Nakonde','Tanzania / Zambia',-9.324300,32.766100),
  ('Kigali','Rwanda',-1.944100,30.061900),
  ('Musanze','Rwanda',-1.499400,29.632000),
  ('Bujumbura','Burundi',-3.361400,29.359900),
  ('Gitega','Burundi',-3.428200,29.925000),
  ('Lubumbashi','DRC',-11.687300,27.502600),
  ('Goma','DRC',-1.658500,29.223000),
  ('Bukavu','DRC',-2.508300,28.860800),
  ('Kasumbalesa','DRC',-12.256800,27.800000),
  ('Lusaka','Zambia',-15.387500,28.322800),
  ('Ndola','Zambia',-12.958700,28.636600),
  ('Kitwe','Zambia',-12.802400,28.213200),
  ('Juba','South Sudan',4.859400,31.571300),
  ('Khartoum','Sudan',15.500700,32.559900),
  ('Port Sudan','Sudan',19.614900,37.216600);

-- -----------------------------------------------------------------------------
-- 3) Ports telemetry (TZ TPA + KE KPA)
-- -----------------------------------------------------------------------------
CREATE TABLE `ports` (
  `id`                     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`                   VARCHAR(120) NOT NULL,
  `country`                ENUM('Tanzania','Kenya') NOT NULL,
  `authority`              VARCHAR(20) NOT NULL,
  `status`                 VARCHAR(40) NOT NULL,
  `berth_wait_hrs`         DECIMAL(5,1) DEFAULT NULL,
  `gate_turnaround_mins`   INT DEFAULT NULL,
  `yard_density_pct`       INT DEFAULT NULL,
  `gate_pass_system`       VARCHAR(80) DEFAULT NULL,
  `notes`                  VARCHAR(160) DEFAULT NULL,
  `is_live`                TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

INSERT INTO `ports`
  (`name`,`country`,`authority`,`status`,`berth_wait_hrs`,`gate_turnaround_mins`,`yard_density_pct`,`gate_pass_system`,`notes`)
VALUES
  ('Dar es Salaam Port','Tanzania','TPA','MODERATE QUEUE',5.8,28,78,'TPA Online',NULL),
  ('ICD Kurasini','Tanzania','TPA','ACTIVE',NULL,12,NULL,'TRA Customs Pass','Blocked stack alerts: 4'),
  ('Port of Tanga','Tanzania','TPA','NORMAL',2.1,18,52,'TPA Online','Corridor: Arusha · Moshi'),
  ('Port of Mtwara','Tanzania','TPA','FAST CLEARANCE',1.4,15,41,'TPA Online','Southern Corridor Open'),
  ('Port of Mombasa (KPA)','Kenya','KPA','NORMAL',3.2,14,64,'KPA / KWATOS',NULL),
  ('Nairobi ICD Terminal','Kenya','KPA','FAST GATE',NULL,8,NULL,'KRA Customs Pass','SGR on schedule · 420 haulers'),
  ('Malaba One-Stop Border','Kenya','KPA','FAST CLEARANCE',NULL,45,NULL,'RECTS GPS','1,240 trucks/day · Northern Corridor'),
  ('Lamu Port (LAPSSET)','Kenya','KPA','ACTIVE',1.8,16,38,'KPA','Ethiopia · South Sudan link');

-- Discharge → Gate-Out baseline (same 9 steps for TZ and KE)
CREATE TABLE `port_process_steps` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `country`     ENUM('Tanzania','Kenya') NOT NULL,
  `step_no`     TINYINT UNSIGNED NOT NULL,
  `title`       VARCHAR(120) NOT NULL,
  `description` VARCHAR(400) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_process` (`country`,`step_no`)
) ENGINE=InnoDB;

INSERT INTO `port_process_steps` (`country`,`step_no`,`title`,`description`) VALUES
  ('Tanzania',1,'Discharge','Container unloaded from vessel into port yard or ICD.'),
  ('Tanzania',2,'Customs Declaration','Clearing agent lodges documents and files the customs declaration (TRA).'),
  ('Tanzania',3,'Customs / Agency Inspection','Scanner and multi-agency checks (TBS, TMDA, Government Chemist).'),
  ('Tanzania',4,'Customs Release','Duties paid · TRA issues Customs Release / release order.'),
  ('Tanzania',5,'Shipping Line / Delivery Order (DO)','Ocean freight settled · DO issued by the shipping line.'),
  ('Tanzania',6,'TPA Charges & Release','Port storage & handling paid · TPA release + EIR.'),
  ('Tanzania',7,'Gate Booking','Truck plate & driver linked in the TPA gate-pass system.'),
  ('Tanzania',8,'Yard Loading','Container physically loaded onto the assigned truck in the yard.'),
  ('Tanzania',9,'Gate-Out','Final seal/document check · truck exits the port gate.'),
  ('Kenya',1,'Discharge','Container unloaded from vessel into KPA yard, CFS, or ICD (incl. SGR inland transfer).'),
  ('Kenya',2,'Customs Declaration','Clearing agent lodges B/L, Manifest & Invoice in KRA (iCMS / Single Window).'),
  ('Kenya',3,'Customs / Agency Inspection','Scanner and multi-agency checks (KEBS, KEPHIS, PPB, Port Health).'),
  ('Kenya',4,'Customs Release','Duties paid · KRA issues Customs Release / release order.'),
  ('Kenya',5,'Shipping Line / Delivery Order (DO)','Ocean freight settled · DO issued by the shipping line.'),
  ('Kenya',6,'KPA Charges & Release','Port storage & handling paid · KPA release + EIR.'),
  ('Kenya',7,'Gate Booking','Truck plate & driver linked in the KPA gate-pass / KWATOS system.'),
  ('Kenya',8,'Yard Loading','Container physically loaded onto the assigned truck in the yard / CFS.'),
  ('Kenya',9,'Gate-Out','Final seal/document check · truck exits onto the Northern Corridor.');

CREATE TABLE `port_friction_gaps` (
  `id`           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `area`         VARCHAR(80) NOT NULL,
  `problem`      VARCHAR(255) NOT NULL,
  `opportunity`  VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

INSERT INTO `port_friction_gaps` (`area`,`problem`,`opportunity`) VALUES
  ('DO & Demurrage','Email / office / manual verification','Digital status & payment visibility'),
  ('Multi-agency holds','Decisions can stay manual','Unified status / hold visibility'),
  ('Transporter coordination','WhatsApp, phone, separate systems','Truck–container matching & coordination'),
  ('Yard','System may say ready while container is blocked','Real-time physical yard status');

-- -----------------------------------------------------------------------------
-- 4) Fleet / consignments (FLEET array on the website)
-- -----------------------------------------------------------------------------
CREATE TABLE `shipments` (
  `id`              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `waybill`         VARCHAR(40) NOT NULL,
  `plate`           VARCHAR(20) NOT NULL,
  `colour`          VARCHAR(40) NOT NULL,
  `driver_name`     VARCHAR(120) NOT NULL,
  `driver_phone`    VARCHAR(40) NOT NULL,
  `licence`         VARCHAR(40) NOT NULL,
  `truck_type`      VARCHAR(80) NOT NULL,
  `cargo`           VARCHAR(160) NOT NULL,
  `seal`            VARCHAR(80) NOT NULL,
  `origin`          VARCHAR(120) NOT NULL,
  `destination`     VARCHAR(120) NOT NULL,
  `current_city`    VARCHAR(80) NOT NULL,
  `eta`             VARCHAR(40) NOT NULL,
  `status`          ENUM('moving','delayed','cleared') NOT NULL DEFAULT 'moving',
  `trust_score`     TINYINT UNSIGNED NOT NULL DEFAULT 70,
  `created_at`      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_waybill` (`waybill`),
  UNIQUE KEY `uq_plate` (`plate`),
  KEY `idx_status` (`status`),
  KEY `idx_origin_dest` (`origin`,`destination`)
) ENGINE=InnoDB;

INSERT INTO `shipments`
  (`waybill`,`plate`,`colour`,`driver_name`,`driver_phone`,`licence`,`truck_type`,`cargo`,`seal`,`origin`,`destination`,`current_city`,`eta`,`status`,`trust_score`)
VALUES
  ('MVT-WAY-88492','KBS 023A','White','Daniel Mutua','+254 722 100 001','DL-KE-00123','Tractor-Trailer','Electronics – 24 TEU','KE-KRA-994821','Mombasa Port','Kampala','Nakuru','14:20 hrs','moving',91),
  ('MVT-WAY-90112','DRC 104C','Yellow','Jean-Luc Kabamba','+243 81 234 5678','DL-CD-00104','Heavy Duty Hauler','Mining Equipment – 35 MT','CD-DGDA-00192','Mombasa Port','Lubumbashi (DRC)','Kampala','3 Days','moving',84),
  ('MVT-WAY-44310','DRC 882G','Blue','Antoine Mukendi','+243 99 876 5432','DL-CD-00882','Container Truck','Relief Supplies – 18 MT','UN-HRC-88120','Mombasa Port','Goma (DRC)','Kigali','18:30 hrs','moving',88),
  ('MVT-WAY-61109','ZAM 409Z','Red','Chileshe Banda','+260 97 112 2334','DL-ZM-00409','Flatbed Trailer','Copper Cathodes – 32 MT','ZM-ZRA-33921','Lusaka (Zambia)','Dar es Salaam','Nakonde','2 Days','moving',79),
  ('MVT-WAY-77291','ZAM 711K','Green','Kondwani Phiri','+260 95 445 5667','DL-ZM-00711','Tractor-Trailer','Fertilizer – 28 MT','KE-KRA-10293','Mombasa Port','Kitwe (Zambia)','Nakuru','4 Days','moving',76),
  ('MVT-WAY-33921','KCA 456T','Blue','James Otieno','+254 733 200 002','DL-KE-00456','Flatbed Truck','Steel Rods – 30 MT','TZ-TRA-44910','Dar es Salaam','Kigali','Arusha','18:45 hrs','moving',86),
  ('MVT-WAY-11029','UAX 789K','Red','Peter Ssemakula','+256 701 300 003','DL-UG-00789','Rigid Truck','Food Commodities – 15 MT','UG-URA-11928','Kampala','Jinja','Kampala','09:30 hrs','cleared',93),
  ('MVT-WAY-55102','BDI 654X','Yellow','Eric Ndayishimiye','+257 79 500 005','DL-BI-00654','Tanker','Fuel – 30,000 L','BI-OBR-77291','Bujumbura','Gitega','Bujumbura','13:15 hrs','delayed',64);

CREATE TABLE `shipment_route_waypoints` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `shipment_id` INT UNSIGNED NOT NULL,
  `seq`         TINYINT UNSIGNED NOT NULL,
  `city_name`   VARCHAR(80) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_ship_seq` (`shipment_id`,`seq`),
  CONSTRAINT `fk_wp_shipment` FOREIGN KEY (`shipment_id`) REFERENCES `shipments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT INTO `shipment_route_waypoints` (`shipment_id`,`seq`,`city_name`)
SELECT s.id, n.seq, n.city FROM `shipments` s
JOIN (
  SELECT 'KBS 023A' AS plate, 1 AS seq, 'Mombasa Port' AS city UNION ALL
  SELECT 'KBS 023A',2,'Nairobi' UNION ALL SELECT 'KBS 023A',3,'Naivasha' UNION ALL
  SELECT 'KBS 023A',4,'Nakuru' UNION ALL SELECT 'KBS 023A',5,'Eldoret' UNION ALL
  SELECT 'KBS 023A',6,'Malaba' UNION ALL SELECT 'KBS 023A',7,'Kampala' UNION ALL
  SELECT 'DRC 104C',1,'Mombasa Port' UNION ALL SELECT 'DRC 104C',2,'Nairobi' UNION ALL
  SELECT 'DRC 104C',3,'Eldoret' UNION ALL SELECT 'DRC 104C',4,'Kampala' UNION ALL
  SELECT 'DRC 104C',5,'Kigali' UNION ALL SELECT 'DRC 104C',6,'Bukavu' UNION ALL
  SELECT 'DRC 104C',7,'Kasumbalesa' UNION ALL SELECT 'DRC 104C',8,'Lubumbashi' UNION ALL
  SELECT 'DRC 882G',1,'Mombasa Port' UNION ALL SELECT 'DRC 882G',2,'Nairobi' UNION ALL
  SELECT 'DRC 882G',3,'Kampala' UNION ALL SELECT 'DRC 882G',4,'Kigali' UNION ALL
  SELECT 'DRC 882G',5,'Goma' UNION ALL
  SELECT 'ZAM 409Z',1,'Lusaka' UNION ALL SELECT 'ZAM 409Z',2,'Ndola' UNION ALL
  SELECT 'ZAM 409Z',3,'Nakonde' UNION ALL SELECT 'ZAM 409Z',4,'Dodoma' UNION ALL
  SELECT 'ZAM 409Z',5,'Dar es Salaam' UNION ALL
  SELECT 'ZAM 711K',1,'Mombasa Port' UNION ALL SELECT 'ZAM 711K',2,'Nairobi' UNION ALL
  SELECT 'ZAM 711K',3,'Nakuru' UNION ALL SELECT 'ZAM 711K',4,'Eldoret' UNION ALL
  SELECT 'ZAM 711K',5,'Nakonde' UNION ALL SELECT 'ZAM 711K',6,'Ndola' UNION ALL
  SELECT 'ZAM 711K',7,'Kitwe' UNION ALL
  SELECT 'KCA 456T',1,'Dar es Salaam' UNION ALL SELECT 'KCA 456T',2,'Moshi' UNION ALL
  SELECT 'KCA 456T',3,'Arusha' UNION ALL SELECT 'KCA 456T',4,'Kigali' UNION ALL
  SELECT 'UAX 789K',1,'Kampala' UNION ALL SELECT 'UAX 789K',2,'Jinja' UNION ALL
  SELECT 'BDI 654X',1,'Bujumbura' UNION ALL SELECT 'BDI 654X',2,'Gitega'
) n ON n.plate = s.plate;

-- -----------------------------------------------------------------------------
-- 5) Alternative corridor diversions (ALT_ROUTES)
-- -----------------------------------------------------------------------------
CREATE TABLE `alt_routes` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `plate`       VARCHAR(20) NOT NULL,
  `reason`      VARCHAR(255) NOT NULL,
  `save_time`   VARCHAR(20) NOT NULL,
  `alert`       TINYINT(1) NOT NULL DEFAULT 1,
  `use_offset`  TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_alt_plate` (`plate`),
  CONSTRAINT `fk_alt_plate` FOREIGN KEY (`plate`) REFERENCES `shipments` (`plate`) ON UPDATE CASCADE
) ENGINE=InnoDB;

INSERT INTO `alt_routes` (`plate`,`reason`,`save_time`,`alert`,`use_offset`) VALUES
  ('KBS 023A','A104 Nakuru–Eldoret congestion (42 min dwell). Divert via Kericho–Kisumu–Busia.','35 min',1,0),
  ('DRC 104C','Eldoret weighbridge queue. Skip Eldoret and run Kisumu corridor.','1.5 hrs',1,0),
  ('DRC 882G','Goma checkpoint queue on RN2. Use Musanze–Goma northern loop.','40 min',1,0),
  ('ZAM 409Z','Ndola road works. Bypass Ndola and hold Tunduma/Nakonde transit.','2 hrs',1,0),
  ('ZAM 711K','Nakuru–Eldoret slow truck lane. Alternate via Kericho then south to Nakonde.','3 hrs',1,0),
  ('KCA 456T','Moshi weighbridge delay. Divert inland via Dodoma then Arusha.','55 min',1,0),
  ('UAX 789K','Jinja town traffic. Use the northern bypass to the bonded warehouse.','18 min',0,1),
  ('BDI 654X','RN1 landslide. DELAYED — take RN3 southern loop into Gitega.','50 min',1,1);

CREATE TABLE `alt_route_waypoints` (
  `id`           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `alt_route_id` INT UNSIGNED NOT NULL,
  `seq`          TINYINT UNSIGNED NOT NULL,
  `city_name`    VARCHAR(80) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_altwp` FOREIGN KEY (`alt_route_id`) REFERENCES `alt_routes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT INTO `alt_route_waypoints` (`alt_route_id`,`seq`,`city_name`)
SELECT a.id, n.seq, n.city FROM `alt_routes` a
JOIN (
  SELECT 'KBS 023A' AS plate, 1 AS seq, 'Mombasa Port' AS city UNION ALL
  SELECT 'KBS 023A',2,'Nairobi' UNION ALL SELECT 'KBS 023A',3,'Naivasha' UNION ALL
  SELECT 'KBS 023A',4,'Kericho' UNION ALL SELECT 'KBS 023A',5,'Kisumu' UNION ALL
  SELECT 'KBS 023A',6,'Busia' UNION ALL SELECT 'KBS 023A',7,'Kampala' UNION ALL
  SELECT 'DRC 104C',1,'Mombasa Port' UNION ALL SELECT 'DRC 104C',2,'Nairobi' UNION ALL
  SELECT 'DRC 104C',3,'Kisumu' UNION ALL SELECT 'DRC 104C',4,'Kampala' UNION ALL
  SELECT 'DRC 104C',5,'Kigali' UNION ALL SELECT 'DRC 104C',6,'Bukavu' UNION ALL
  SELECT 'DRC 104C',7,'Kasumbalesa' UNION ALL SELECT 'DRC 104C',8,'Lubumbashi' UNION ALL
  SELECT 'DRC 882G',1,'Mombasa Port' UNION ALL SELECT 'DRC 882G',2,'Nairobi' UNION ALL
  SELECT 'DRC 882G',3,'Kampala' UNION ALL SELECT 'DRC 882G',4,'Kigali' UNION ALL
  SELECT 'DRC 882G',5,'Musanze' UNION ALL SELECT 'DRC 882G',6,'Goma' UNION ALL
  SELECT 'ZAM 409Z',1,'Lusaka' UNION ALL SELECT 'ZAM 409Z',2,'Nakonde' UNION ALL
  SELECT 'ZAM 409Z',3,'Dodoma' UNION ALL SELECT 'ZAM 409Z',4,'Dar es Salaam' UNION ALL
  SELECT 'ZAM 711K',1,'Mombasa Port' UNION ALL SELECT 'ZAM 711K',2,'Nairobi' UNION ALL
  SELECT 'ZAM 711K',3,'Naivasha' UNION ALL SELECT 'ZAM 711K',4,'Kericho' UNION ALL
  SELECT 'ZAM 711K',5,'Kisumu' UNION ALL SELECT 'ZAM 711K',6,'Nakonde' UNION ALL
  SELECT 'ZAM 711K',7,'Kitwe' UNION ALL
  SELECT 'KCA 456T',1,'Dar es Salaam' UNION ALL SELECT 'KCA 456T',2,'Dodoma' UNION ALL
  SELECT 'KCA 456T',3,'Arusha' UNION ALL SELECT 'KCA 456T',4,'Kigali' UNION ALL
  SELECT 'UAX 789K',1,'Kampala' UNION ALL SELECT 'UAX 789K',2,'Jinja' UNION ALL
  SELECT 'BDI 654X',1,'Bujumbura' UNION ALL SELECT 'BDI 654X',2,'Gitega'
) n ON n.plate = a.plate;

-- -----------------------------------------------------------------------------
-- 6) Spot loadboard
-- -----------------------------------------------------------------------------
CREATE TABLE `loadboard` (
  `id`             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `origin`         VARCHAR(80) NOT NULL,
  `destination`    VARCHAR(80) NOT NULL,
  `pay_usd`        DECIMAL(10,2) NOT NULL,
  `cargo`          VARCHAR(160) NOT NULL,
  `pickup_point`   VARCHAR(160) NOT NULL,
  `escrow_status`  VARCHAR(80) NOT NULL DEFAULT 'MOVENTRA Guaranteed',
  `status`         ENUM('open','bid','accepted') NOT NULL DEFAULT 'open',
  `created_at`     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

INSERT INTO `loadboard` (`origin`,`destination`,`pay_usd`,`cargo`,`pickup_point`) VALUES
  ('Mombasa','Kampala',2250.00,'40ft Container · Machinery (26 MT)','Port of Mombasa Berth 18'),
  ('Dar es Salaam','Kigali',3100.00,'Flatbed Steel Coils (30 MT)','ICD Kurasini Gate 2'),
  ('Mombasa','Lubumbashi',5400.00,'Heavy Mining Parts (34 MT)','Kilindini Terminal');

-- -----------------------------------------------------------------------------
-- 7) Finance layer
-- -----------------------------------------------------------------------------
CREATE TABLE `finance_products` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`        VARCHAR(80) NOT NULL,
  `metric`      VARCHAR(40) NOT NULL,
  `details`     VARCHAR(255) NOT NULL,
  `action_label` VARCHAR(80) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

INSERT INTO `finance_products` (`name`,`metric`,`details`,`action_label`) VALUES
  ('Freight Escrow','$42.1M','186 consignments · Release on POD + RECTS seal verified · MOVENTRA Guaranteed','Hold Escrow'),
  ('Invoice Discounting','82%','Advance up to 82% · Tenor 7–21 days · Fee 1.4% platform + partner bank','Request Advance'),
  ('Fuel Credit','KES 2.8M','Trust score ≥ 72 · Stations: Mombasa · Nairobi · Malaba · Dar · Auto-deduct on escrow release','Activate Fuel Credit'),
  ('Cargo Insurance','0.35%','Theft, accident, customs delay · Premium from 0.35% of cargo value · Digital policy on waybill seal','Bind Cover');

CREATE TABLE `escrow_holds` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `shipment_id` INT UNSIGNED NOT NULL,
  `amount_usd`  DECIMAL(12,2) NOT NULL,
  `status`      ENUM('held','released','disputed') NOT NULL DEFAULT 'held',
  `release_rule` VARCHAR(120) NOT NULL DEFAULT 'POD + RECTS seal verified',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_escrow_ship` FOREIGN KEY (`shipment_id`) REFERENCES `shipments` (`id`)
) ENGINE=InnoDB;

INSERT INTO `escrow_holds` (`shipment_id`,`amount_usd`,`status`)
SELECT id, 2250.00, 'held' FROM `shipments` WHERE plate = 'KBS 023A'
UNION ALL
SELECT id, 5400.00, 'held' FROM `shipments` WHERE plate = 'DRC 104C'
UNION ALL
SELECT id, 1850.00, 'released' FROM `shipments` WHERE plate = 'UAX 789K';

-- -----------------------------------------------------------------------------
-- 8) Rate quotes (calculator bookings)
-- -----------------------------------------------------------------------------
CREATE TABLE `rate_quotes` (
  `id`           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `origin`       VARCHAR(80) NOT NULL,
  `destination`  VARCHAR(80) NOT NULL,
  `cargo_type`   VARCHAR(80) NOT NULL,
  `weight_mt`    DECIMAL(6,2) NOT NULL,
  `rate_usd`     DECIMAL(10,2) NOT NULL,
  `transit_days` DECIMAL(4,1) NOT NULL,
  `booked`       TINYINT(1) NOT NULL DEFAULT 0,
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 9) Platform settings / hotlines
-- -----------------------------------------------------------------------------
CREATE TABLE `settings` (
  `k` VARCHAR(80) NOT NULL,
  `v` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`k`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `event_log` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `event_type` VARCHAR(40) NOT NULL,
  `plate`      VARCHAR(20) DEFAULT NULL,
  `payload`    TEXT,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_event_type` (`event_type`)
) ENGINE=InnoDB;

INSERT INTO `settings` (`k`,`v`) VALUES
  ('brand','MOVENTRA'),
  ('hotline_kenya','+254 707231160'),
  ('hotline_tanzania','+255 753 639 103'),
  ('currency_kes_per_usd','130'),
  ('research_finding_1','Unified API Data Interchange / Middleware Layer — recommended, API access not yet proven');

SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- Useful queries after import
-- -----------------------------------------------------------------------------
-- SELECT waybill, plate, driver_name, origin, destination, current_city, status FROM shipments;
-- SELECT * FROM ports WHERE country = 'Tanzania';
-- SELECT s.plate, GROUP_CONCAT(w.city_name ORDER BY w.seq SEPARATOR ' → ') AS route
--   FROM shipments s JOIN shipment_route_waypoints w ON w.shipment_id = s.id
--   GROUP BY s.id;
-- Login check:
-- SELECT role, email FROM users WHERE email = 'john.otieno@moventra.co.ke' AND password_hash = SHA2('cargo123',256);
