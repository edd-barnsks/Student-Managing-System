-- V4: apply to selected V3 database after backup. No existing grades are changed.
-- Unknown legacy terms/units are deliberately not fabricated. DDL commits independently.
CREATE TABLE IF NOT EXISTS academic_terms (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 academic_year VARCHAR(12) NOT NULL,
 semester ENUM('first','second','summer','unspecified') NOT NULL,
 UNIQUE KEY uq_term(academic_year,semester)
) ENGINE=InnoDB;
INSERT INTO academic_terms(academic_year,semester) SELECT 'Unassigned','unspecified' WHERE NOT EXISTS(SELECT 1 FROM academic_terms WHERE semester='unspecified');
SET @legacy_term=(SELECT id FROM academic_terms WHERE semester='unspecified' LIMIT 1);
SET @ddl=IF(NOT EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='classes' AND COLUMN_NAME='term_id'),CONCAT('ALTER TABLE classes ADD term_id INT UNSIGNED NOT NULL DEFAULT ',@legacy_term),'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @ddl=IF(NOT EXISTS(SELECT 1 FROM information_schema.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA=DATABASE() AND TABLE_NAME='classes' AND CONSTRAINT_NAME='fk_class_term'),'ALTER TABLE classes ADD CONSTRAINT fk_class_term FOREIGN KEY(term_id) REFERENCES academic_terms(id) ON DELETE RESTRICT','SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @ddl=IF(NOT EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='classes' AND COLUMN_NAME='units'),'ALTER TABLE classes ADD units DECIMAL(4,1) NULL CHECK(units > 0 AND units <= 12)','SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @ddl=IF(NOT EXISTS(SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='classes' AND INDEX_NAME='uq_class_term'),'ALTER TABLE classes ADD UNIQUE KEY uq_class_term(class_name,term_id)','SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @ddl=IF(EXISTS(SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='classes' AND INDEX_NAME='class_name'),'ALTER TABLE classes DROP INDEX class_name','SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @ddl=IF(NOT EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='grade_periods' AND COLUMN_NAME='locked_at'),'ALTER TABLE grade_periods ADD locked_at DATETIME NULL, ADD locked_by INT UNSIGNED NULL, ADD CONSTRAINT fk_grade_lock_user FOREIGN KEY(locked_by) REFERENCES staff_accounts(id) ON DELETE RESTRICT','SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;
CREATE TABLE IF NOT EXISTS grade_assessments (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 grade_period_id INT UNSIGNED NOT NULL,
 category ENUM('exam','quiz') NOT NULL,
 title VARCHAR(100) NOT NULL,
 earned DECIMAL(7,2) NOT NULL,
 maximum DECIMAL(7,2) NOT NULL,
 CHECK(maximum > 0 AND earned >= 0 AND earned <= maximum),
 FOREIGN KEY(grade_period_id) REFERENCES grade_periods(id) ON DELETE CASCADE,
 INDEX idx_assessment_period(grade_period_id,category)
) ENGINE=InnoDB;
CREATE OR REPLACE VIEW grade_summary AS
SELECT e.id AS enrollment_id, MAX(CASE WHEN p.period='prelim' THEN p.score END) AS prelim,
 MAX(CASE WHEN p.period='midterm' THEN p.score END) AS midterm,
 MAX(CASE WHEN p.period='finals' THEN p.score END) AS finals,
 COUNT(p.id) AS period_count, COUNT(p.locked_at) AS locked_count,
 CASE WHEN COUNT(p.id)=3 THEN ROUND(AVG(p.score),2) WHEN COUNT(p.id)=0 THEN g.score ELSE NULL END AS overall,
 g.score AS legacy_score, g.id AS legacy_id
FROM enrollments e LEFT JOIN grade_periods p ON p.enrollment_id=e.id LEFT JOIN grades g ON g.enrollment_id=e.id
GROUP BY e.id,g.id,g.score;
