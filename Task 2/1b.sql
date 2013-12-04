CREATE TABLE `buchung` LIKE `FlughafenDB`.`buchung`;
DROP PROCEDURE IF EXISTS `book_asap`;
DELIMITER //
CREATE PROCEDURE `book_asap`(IN p_start CHAR(3), IN p_destination CHAR(3), IN p_time DATETIME, IN p_pass CHAR(9))
BEGIN
  DECLARE v_flightnr CHAR(8);
  DECLARE v_flight_id INT(11);
  DECLARE no_flight_found CONDITION FOR SQLSTATE '45000';
  DECLARE v_passenger_id CHAR(9);
  DECLARE invalid_pass CONDITION FOR SQLSTATE '45001';
  
  SELECT `passagier_id` INTO v_passenger_id
    FROM `FlughafenDB`.`passagier`
    WHERE `passnummer` = p_pass
    LIMIT 1;
    
  IF v_passenger_id IS NULL THEN
    SIGNAL invalid_pass SET MESSAGE_TEXT = 'Invalid pass number';
  END IF;
  
  SELECT `f`.`flug_id`, `f`.`flugnr` INTO v_flight_id, v_flightnr
    FROM `FlughafenDB`.`flughafen` AS `fhvon`
      INNER JOIN `FlughafenDB`.`flug` AS `f`
        ON `f`.`von` = `fhvon`.`flughafen_id`
      INNER JOIN `FlughafenDB`.`flughafen` AS `fhnach`
        ON `f`.`nach` = `fhnach`.`flughafen_id`
      INNER JOIN `FlughafenDB`.`flugzeug` AS `fz`
        ON `f`.`flugzeug_id` = `fz`.`flugzeug_id`
    WHERE `fhvon`.`iata` = p_start
      AND `fhnach`.`iata` = p_destination
      AND `f`.`abflug` > p_time
      AND `fz`.`kapazitaet` > (SELECT COUNT(*) FROM `FlughafenDB`.`flug` AS `fi` INNER JOIN `FlughafenDB`.`buchung` AS `bi` ON `fi`.`flug_id` = `bi`.`flug_id` WHERE `fi`.`flug_id` = `f`.`flug_id`)
    ORDER BY `f`.`ankunft` ASC
    LIMIT 1;
    
    IF v_flightnr IS NULL THEN
      SIGNAL no_flight_found SET MESSAGE_TEXT = 'Sorry, no flight available';
    END IF;
    
    INSERT INTO `buchung` (`flug_id`, `passagier_id`, `preis`) VALUES (v_flight_id, v_passenger_id, 0.0);
    
    SELECT CONCAT('A seat from ', p_start, ' to ', p_destination, ' was booked on flight ', v_flightnr) AS `booked`;
END //
DELIMITER ;

CALL book_asap('AAC', 'OPL', '2013-08-03 13:00:00', 'P103014');
