DROP FUNCTION IF EXISTS `flighttime`;
DELIMITER //

CREATE FUNCTION `flighttime` (p_departure DATETIME, p_arrival DATETIME) RETURNS VARCHAR(255)
BEGIN
  DECLARE v_output VARCHAR(255) DEFAULT '';
  DECLARE v_diff TIME;
  DECLARE v_hours, v_minutes INT;
  SET v_diff = TIMEDIFF(p_arrival, p_departure);
  SET v_hours = HOUR(v_diff);
  SET v_minutes = MINUTE(v_diff);
  
  IF v_hours > 0 THEN SET v_output = CONCAT(v_hours, ' hour ');
  ELSEIF v_hours > 1 THEN SET v_output = CONCAT(v_output, 'hours ');
  END IF;
  SET v_output = CONCAT(v_output, v_minutes, ' minute');
  IF v_minutes <> 1 THEN SET v_output = CONCAT(v_output, 's');
  END IF;
  
  RETURN v_output;
END //

DELIMITER ;

SELECT `flug_id`, `mdeutschl_FlughafenDB`.flighttime(`abflug`, `ankunft`) AS `flight time` FROM `FlughafenDB`.`flug`;
