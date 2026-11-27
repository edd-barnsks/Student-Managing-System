-- Apply AFTER upgrade_v2.sql to the existing selected database. Back up first.
-- MySQL/MariaDB DDL auto commits. Re-running is safe; existing grades are retained.
SET @ddl=IF(EXISTS(SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='students' AND COLUMN_NAME='year_level'),'SELECT 1','ALTER TABLE students ADD year_level TINYINT UNSIGNED NULL CHECK(year_level BETWEEN 1 AND 4)');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;
CREATE TABLE IF NOT EXISTS curriculum_subjects (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 course_id INT UNSIGNED NOT NULL, class_id INT UNSIGNED NOT NULL,
 year_level TINYINT UNSIGNED NOT NULL CHECK(year_level BETWEEN 1 AND 4),
 prerequisite_class_id INT UNSIGNED NULL,
 UNIQUE KEY uq_curriculum(course_id,class_id), INDEX idx_curriculum_year(course_id,year_level),
 FOREIGN KEY(course_id) REFERENCES courses(id) ON DELETE RESTRICT,
 FOREIGN KEY(class_id) REFERENCES classes(id) ON DELETE RESTRICT,
 FOREIGN KEY(prerequisite_class_id) REFERENCES classes(id) ON DELETE RESTRICT
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS grade_periods (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, enrollment_id INT UNSIGNED NOT NULL,
 period ENUM('prelim','midterm','finals') NOT NULL,
 exam_score DECIMAL(5,2) NOT NULL CHECK(exam_score BETWEEN 0 AND 100),
 quiz_score DECIMAL(5,2) NOT NULL CHECK(quiz_score BETWEEN 0 AND 100),
 project_score DECIMAL(5,2) NOT NULL CHECK(project_score BETWEEN 0 AND 100),
 attendance_score DECIMAL(5,2) NOT NULL CHECK(attendance_score BETWEEN 0 AND 100),
 participation_score DECIMAL(5,2) NOT NULL CHECK(participation_score BETWEEN 0 AND 100),
 score DECIMAL(5,2) NOT NULL CHECK(score BETWEEN 0 AND 100), recorded_by INT UNSIGNED NOT NULL,
 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 UNIQUE KEY uq_period(enrollment_id,period), FOREIGN KEY(enrollment_id) REFERENCES enrollments(id) ON DELETE RESTRICT,
 FOREIGN KEY(recorded_by) REFERENCES staff_accounts(id) ON DELETE RESTRICT
) ENGINE=InnoDB;
-- A live, read-only summary; legacy scores remain untouched in grades.
CREATE OR REPLACE VIEW grade_summary AS
SELECT e.id AS enrollment_id, MAX(CASE WHEN p.period='prelim' THEN p.score END) AS prelim,
 MAX(CASE WHEN p.period='midterm' THEN p.score END) AS midterm,
 MAX(CASE WHEN p.period='finals' THEN p.score END) AS finals,
 COUNT(p.id) AS period_count,
 CASE WHEN COUNT(p.id)=3 THEN ROUND(AVG(p.score),2) WHEN COUNT(p.id)=0 THEN g.score ELSE NULL END AS overall,
 g.score AS legacy_score, g.id AS legacy_id
FROM enrollments e LEFT JOIN grade_periods p ON p.enrollment_id=e.id LEFT JOIN grades g ON g.enrollment_id=e.id
GROUP BY e.id,g.id,g.score;
