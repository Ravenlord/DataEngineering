DROP PROCEDURE IF EXISTS `erreichbare_flughaefen`;

DELIMITER //
CREATE PROCEDURE `erreichbare_flughaefen`(IN p_id SMALLINT(6), IN p_hops TINYINT, IN p_recursion TINYINT)
BEGIN
  DECLARE v_airport_id SMALLINT(6);
  DECLARE v_from SMALLINT(6);
  DECLARE v_done TINYINT DEFAULT 0;
  DECLARE c_airport CURSOR FOR
    SELECT DISTINCT `von`, `nach`
      FROM `FlughafenDB`.`flugplan` AS `fp`
      WHERE `fp`.`von` = p_id AND `fp`.`von` IS NOT NULL AND `fp`.`nach` IS NOT NULL;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
  
  IF p_recursion = 0 THEN
    SET max_sp_recursion_depth = p_hops + 1;
    DROP TABLE IF EXISTS `hops`;
    CREATE TABLE `hops` (
      `flughafen_id` SMALLINT(6) NOT NULL,
      `hops` TINYINT NOT NULL
    )ENGINE=MEMORY;
  END IF;
  
  IF p_recursion <= p_hops THEN
    OPEN c_airport;
    l_fetch_data: LOOP
      FETCH c_airport INTO v_from, v_airport_id;
      IF v_done THEN
        CLOSE c_airport;
        LEAVE l_fetch_data;
      END IF;
      INSERT INTO `hops` VALUES (v_airport_id, p_recursion);
      CALL erreichbare_flughaefen(v_airport_id, p_hops, (p_recursion + 1));
    END LOOP l_fetch_data;
  END IF;
  
END //
DELIMITER ;

CALL erreichbare_flughaefen(4018, 2, 0);
