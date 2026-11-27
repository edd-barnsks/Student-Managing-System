-- WS101 v2: select your EXISTING database in phpMyAdmin before importing.
-- Back up first. Do not run the full installation SQL on an existing database.
-- DDL auto-commits. Existing rows and final scores are unchanged.
ALTER TABLE staff_accounts MODIFY role ENUM('admin','teacher','staff') NOT NULL;
SET @ddl = IF(EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='grades' AND COLUMN_NAME='exam_score'), 'SELECT 1', 'ALTER TABLE grades ADD COLUMN exam_score DECIMAL(5,2) NULL CHECK (exam_score BETWEEN 0 AND 100)');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @ddl = IF(EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='grades' AND COLUMN_NAME='quiz_score'), 'SELECT 1', 'ALTER TABLE grades ADD COLUMN quiz_score DECIMAL(5,2) NULL CHECK (quiz_score BETWEEN 0 AND 100)');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @ddl = IF(EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='grades' AND COLUMN_NAME='project_score'), 'SELECT 1', 'ALTER TABLE grades ADD COLUMN project_score DECIMAL(5,2) NULL CHECK (project_score BETWEEN 0 AND 100)');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @ddl = IF(EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='grades' AND COLUMN_NAME='attendance_score'), 'SELECT 1', 'ALTER TABLE grades ADD COLUMN attendance_score DECIMAL(5,2) NULL CHECK (attendance_score BETWEEN 0 AND 100)');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @ddl = IF(EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='grades' AND COLUMN_NAME='participation_score'), 'SELECT 1', 'ALTER TABLE grades ADD COLUMN participation_score DECIMAL(5,2) NULL CHECK (participation_score BETWEEN 0 AND 100)');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;
