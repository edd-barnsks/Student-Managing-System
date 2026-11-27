-- Student Manager WS101. Import once into a NEW database; original database is untouched.
CREATE DATABASE IF NOT EXISTS student_management_ws101 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE student_management_ws101;
CREATE TABLE courses (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, course_name VARCHAR(100) NOT NULL UNIQUE,
 description VARCHAR(255) NOT NULL DEFAULT ''
) ENGINE=InnoDB;
CREATE TABLE students (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100) NOT NULL,
 email VARCHAR(100) NOT NULL UNIQUE, age TINYINT UNSIGNED NOT NULL,
 course_id INT UNSIGNED NOT NULL, address VARCHAR(255) NOT NULL, contact_number VARCHAR(20) NOT NULL,
 gender ENUM('Male','Female','Other') NOT NULL, invite_hash CHAR(64) NULL UNIQUE, invite_expires DATETIME NULL,
 INDEX idx_student_name(name), FOREIGN KEY(course_id) REFERENCES courses(id) ON DELETE RESTRICT,
 CHECK(age BETWEEN 1 AND 120)
) ENGINE=InnoDB;
CREATE TABLE staff_accounts (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100) NOT NULL,
 username VARCHAR(50) NOT NULL UNIQUE, password_hash VARCHAR(255) NOT NULL,
 role ENUM('admin','teacher','staff') NOT NULL, active TINYINT(1) NOT NULL DEFAULT 1,
 session_version INT UNSIGNED NOT NULL DEFAULT 0, INDEX idx_staff_role(role,active)
) ENGINE=InnoDB;
CREATE TABLE student_accounts (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, student_id INT UNSIGNED NOT NULL UNIQUE,
 username VARCHAR(50) NOT NULL UNIQUE, password_hash VARCHAR(255) NOT NULL,
 active TINYINT(1) NOT NULL DEFAULT 1, session_version INT UNSIGNED NOT NULL DEFAULT 0,
 FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE
) ENGINE=InnoDB;
CREATE TABLE classes (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, class_name VARCHAR(100) NOT NULL UNIQUE,
 description VARCHAR(255) NOT NULL, teacher_id INT UNSIGNED NULL, schedule VARCHAR(100) NOT NULL,
 legacy_teacher VARCHAR(100) NULL,
 INDEX idx_classes_teacher(teacher_id), FOREIGN KEY(teacher_id) REFERENCES staff_accounts(id) ON DELETE RESTRICT
) ENGINE=InnoDB;
CREATE TABLE enrollments (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, student_id INT UNSIGNED NOT NULL, class_id INT UNSIGNED NOT NULL,
 UNIQUE KEY uq_enrollment(student_id,class_id), INDEX idx_enroll_class(class_id),
 FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE RESTRICT,
 FOREIGN KEY(class_id) REFERENCES classes(id) ON DELETE RESTRICT
) ENGINE=InnoDB;
CREATE TABLE grades (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, enrollment_id INT UNSIGNED NOT NULL UNIQUE,
 score DECIMAL(5,2) NOT NULL,
 exam_score DECIMAL(5,2) NULL CHECK(exam_score BETWEEN 0 AND 100),
 quiz_score DECIMAL(5,2) NULL CHECK(quiz_score BETWEEN 0 AND 100),
 project_score DECIMAL(5,2) NULL CHECK(project_score BETWEEN 0 AND 100),
 attendance_score DECIMAL(5,2) NULL CHECK(attendance_score BETWEEN 0 AND 100),
 participation_score DECIMAL(5,2) NULL CHECK(participation_score BETWEEN 0 AND 100),
 recorded_by INT UNSIGNED NULL,
 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 CHECK(score BETWEEN 0 AND 100), FOREIGN KEY(enrollment_id) REFERENCES enrollments(id) ON DELETE RESTRICT,
 FOREIGN KEY(recorded_by) REFERENCES staff_accounts(id) ON DELETE RESTRICT
) ENGINE=InnoDB;
CREATE TABLE audit_logs (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, actor_role VARCHAR(20) NOT NULL, actor_id INT UNSIGNED NULL,
 action VARCHAR(60) NOT NULL, target VARCHAR(150) NOT NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, INDEX idx_audit_time(created_at)
) ENGINE=InnoDB;
START TRANSACTION;
-- Courses derived from the existing student records; no course rows existed in the source.
INSERT INTO courses(id,course_name,description) VALUES (1,'BSIT',''),(2,'BSHRM',''),(3,'BSHM','');
-- Original student records, including the record named Admin, kept without guessing identities.
INSERT INTO students(id,name,email,age,course_id,address,contact_number,gender) VALUES
(1,'John Lester D. Defensor','john.defensor@hcdc.edu.ph',23,1,'Davao City','09123456789','Female'),
(2,'Tabigue1','Tabigue@gmail.com',19,2,'Davao City','09123445678','Male'),
(3,'Admin','Admin@gmail.com',23,3,'Davao City','0912345566','Male'),
(4,'Demo Student','student.demo@example.test',20,1,'Demo address','09000000000','Other');
-- Local-only demo accounts. The original users had no verified role/student mapping; not imported.
INSERT INTO staff_accounts(id,name,username,password_hash,role) VALUES
(1,'System Administrator','admin','$2y$12$hXs./BcDhpjZ8hHLrCCd6eQ5U9HwU/BtXdn9/f5ZWGGHuxzlqNG.i','admin'),
(2,'Demo Teacher','teacher','$2y$12$3DHgHUqv9D4aGlwDgR0Yje8s2P5YAOD6SJpWGJniiS34JlWFWV2dG','teacher');
INSERT INTO student_accounts(id,student_id,username,password_hash) VALUES (1,4,'student','$2y$12$tR7wqX2p4b.MExDGsW4A6eswiSPVQ4dZaRfNGSeepfTnHMi6uG4ee');
-- Original ADV1021 and teacher display text are retained, but teacher identity is unverified.
-- Original grades use ADV102 instead; a separate placeholder class preserves the distinction.
INSERT INTO classes(id,class_name,description,teacher_id,schedule,legacy_teacher) VALUES
(1,'ADV1021','Structure102',NULL,'Wednesday | 00:40 - 01:12','Faith'),
(2,'ADV102','Legacy grade subject — verify with registrar',NULL,'Not recorded',NULL),
(3,'DEMO101','Demo academic class',2,'Monday | 09:00 - 10:00',NULL);
INSERT INTO enrollments(id,student_id,class_id) VALUES (1,1,2),(2,3,2),(3,4,3);
INSERT INTO grades(id,enrollment_id,score,recorded_by) VALUES (1,1,98,NULL),(2,2,1,NULL),(3,3,90,2);
COMMIT;
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
