CREATE OR REPLACE VIEW `v_buchung` AS
  SELECT * FROM `buchung` WHERE `buchung_id` BETWEEN 10 AND 1000
  WITH CHECK OPTION;