DROP TRIGGER IF EXISTS `t_price_invalid`;

DELIMITER //
CREATE TRIGGER `t_price_invalid` BEFORE INSERT ON `buchung`
FOR EACH ROW
BEGIN
  IF NEW.`preis` IS NULL OR NEW.`preis` < 0 THEN
    SET NEW.`preis` = 10000.0;
  END IF;
END //
DELIMITER ;
