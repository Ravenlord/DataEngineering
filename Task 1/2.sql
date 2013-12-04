-- AUFGABE 2 Schlüsselkandidaten korrigieren und ausfüllen!
-- task 2.a

SELECT
  `fh1`.`name` AS `Von`,
  `fh2`.`name` AS `Nach`,
  DATE_FORMAT(`f`.`abflug`, '%k:%i') AS `Uhrzeit`
FROM
  `flug` AS `f`
  INNER JOIN `flughafen` AS `fh1`
    ON `f`.`von` = `fh1`.`flughafen_id`
  INNER JOIN `flughafen` AS `fh2`
    ON `f`.`nach` = `fh2`.`flughafen_id`
WHERE
  `fh1`.`iata` = 'TEE'
  AND 
  `f`.`abflug` BETWEEN CAST('2011-08-01' AS DATETIME) AND CAST('2011-08-30' AS DATETIME)
;
-- Vom Flughafen 'TEE' gehen KEINE Flüge aus!

-- task 2.b

SELECT
  `p`.`vorname`,
  `p`.`nachname`,
  `pd`.`geburtsdatum`
FROM
  `passagier` AS `p`
  INNER JOIN `passagierdetails` AS `pd`
    ON `p`.`passagier_id` = `pd`.`passagier_id`
  INNER JOIN `buchung` AS `b`
    ON `b`.`passagier_id` = `p`.`passagier_id`
  INNER JOIN `flug` AS `f`
    ON `f`.`flug_id` = `b`.`flug_id`
  INNER JOIN `fluglinie` AS `fl`
    ON `fl`.`fluglinie_id` = `f`.`fluglinie_id`
WHERE
  `fl`.`firmenname` = 'Australia Airlines'
  AND
  `pd`.`geburtsdatum` BETWEEN CAST(CURDATE() - 250000 AS DATE) AND CAST(CURDATE() - 200000 AS DATE)
;

SELECT
  `p`.`vorname`,
  `p`.`nachname`,
  `pd`.`geburtsdatum`
FROM
  `passagier` AS `p`
  INNER JOIN `passagierdetails` AS `pd`
    ON `p`.`passagier_id` = `pd`.`passagier_id`
  INNER JOIN `buchung` AS `b`
    ON `b`.`passagier_id` = `p`.`passagier_id`
  INNER JOIN `flug` AS `f`
    ON `f`.`flug_id` = `b`.`flug_id`
  INNER JOIN `fluglinie` AS `fl`
    ON `fl`.`fluglinie_id` = `f`.`fluglinie_id`
WHERE
  `fl`.`firmenname` = 'Australia Airlines'
  AND
  `pd`.`geburtsdatum` BETWEEN DATE_SUB(CURDATE(), INTERVAL 25 YEAR) AND DATE_SUB(CURDATE(), INTERVAL 20 YEAR)
;

-- task 2.c

SELECT
  `p`.*
FROM
  `passagier` AS `p`
  INNER JOIN `buchung` AS `b`
    ON `b`.`passagier_id` = `p`.`passagier_id`
  INNER JOIN `flug` AS `f`
    ON `f`.`flug_id` = `b`.`flug_id`
  INNER JOIN `flugzeug` AS `fz`
    ON `fz`.`flugzeug_id` = `f`.`flugzeug_id`
  INNER JOIN `flugzeug_typ` `ft`
    ON `ft`.`typ_id` = `fz`.`typ_id`
WHERE
  `ft`.`bezeichnung` = 'Airbus 380'
;
-- Falsche Bezeichnung! Müsste 'Airbus A380' heißen.

-- task 2.d

SELECT
  *
FROM
  `flugzeug` AS `fz`
WHERE
  `fz`.`flugzeug_id` NOT IN (SELECT `flugzeug_id` FROM `flug`)
;
-- Nicht korreliert, keine Ahnung was ich korrellieren soll.

-- Korreliert
SELECT
	*
FROM
	`flugzeug`
WHERE
	(
		SELECT
			`flug`.`flugzeug_id`
		FROM
			`flug`
		WHERE
			`flug`.`flugzeug_id` = `flugzeug`.`flugzeug_id`
	) IS NULL
;
-- Geht out of sync wegen PHP prepare.

-- task 2.e

SELECT
  MAX(`fz`.`kapazitaet`)
FROM
  `flugzeug` AS `fz`
  INNER JOIN `flug` AS `f`
    ON `f`.`flugzeug_id` = `fz`.`flugzeug_id`
  INNER JOIN `fluglinie` `fl`
    ON `fl`.`fluglinie_id` = `f`.`fluglinie_id`
WHERE
  `fl`.`firmenname` = 'Thailand Airlines'
;

-- task 2.f

SELECT DISTINCT
	`fh1`.`name` AS `Startflughafen`,
	`fh2`.`name` AS `Direkt erreichbar`,
	IFNULL(`fh3`.`name`, "") AS `Erreichbar über zwei Hops`,
	IFNULL(`fh4`.`name`, "") AS `Erreichbar über drei Hops`,
	IFNULL(`fh5`.`name`, "") AS `Erreichbar über vier Hops`
FROM
	`flughafen`       AS `fh1`
	INNER JOIN `flug`      AS `f1`  ON `f1`.`von`          = `fh1`.`flughafen_id`
	INNER JOIN `flughafen`  AS `fh2` ON `fh2`.`flughafen_id` = `f1`.`nach`
	LEFT JOIN `flug`       AS `f2`  ON `f2`.`von`          = `fh2`.`flughafen_id`
	LEFT JOIN `flughafen`  AS `fh3` ON `fh3`.`flughafen_id` = `f2`.`nach`
	LEFT JOIN `flug`       AS `f3`  ON `f3`.`von`          = `fh3`.`flughafen_id`
	LEFT JOIN `flughafen`  AS `fh4` ON `fh4`.`flughafen_id` = `f3`.`nach`
	LEFT JOIN `flug`       AS `f4`  ON `f4`.`von`          = `fh4`.`flughafen_id`
	LEFT JOIN `flughafen`  AS `fh5` ON `fh5`.`flughafen_id` = `f4`.`nach`
WHERE
	`fh1`.`flughafen_id` = 2233
;

-- SELECT * FROM `flug` WHERE `von` = 2233;
-- SELECT * FROM `flugplan` WHERE `von` = 2233;

SELECT DISTINCT
	`fh1`.`name` AS `Startflughafen`,
	`fh2`.`name` AS `Direkt erreichbar`,
	IFNULL(`fh3`.`name`, "") AS `Erreichbar über zwei Hops`,
	IFNULL(`fh4`.`name`, "") AS `Erreichbar über drei Hops`,
	IFNULL(`fh5`.`name`, "") AS `Erreichbar über vier Hops`
FROM
	`flughafen` AS `fh1`
	INNER JOIN `flugplan`  AS `f1`  ON `f1`.`von`          = `fh1`.`flughafen_id`
	INNER JOIN `flughafen` AS `fh2` ON `fh2`.`flughafen_id` = `f1`.`nach`
	LEFT JOIN `flugplan`   AS `f2`  ON `f2`.`von`          = `fh2`.`flughafen_id`
	LEFT JOIN `flughafen`  AS `fh3` ON `fh3`.`flughafen_id` = `f2`.`nach`
	LEFT JOIN `flugplan`   AS `f3`  ON `f3`.`von`          = `fh3`.`flughafen_id`
	LEFT JOIN `flughafen`  AS `fh4` ON `fh4`.`flughafen_id` = `f3`.`nach`
	LEFT JOIN `flugplan`   AS `f4`  ON `f4`.`von`          = `fh4`.`flughafen_id`
	LEFT JOIN `flughafen`  AS `fh5` ON `fh5`.`flughafen_id` = `f4`.`nach`
WHERE
	`fh1`.`flughafen_id` = 2233
;
  
