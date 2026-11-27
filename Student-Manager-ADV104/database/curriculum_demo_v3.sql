-- Optional fictional curriculum mappings, NOT official HCDC curriculum. Run after upgrade_v3 and optional HCDC sample data.
-- Only populate known demonstration students with missing year levels.
START TRANSACTION;
UPDATE students SET year_level=CASE WHEN email IN ('hcdc.demo.student03@example.test','hcdc.demo.student04@example.test','hcdc.demo.student07@example.test','hcdc.demo.student08@example.test') THEN 2 ELSE 1 END WHERE year_level IS NULL AND (email='student.demo@example.test' OR email REGEXP '^hcdc[.]demo[.]student(0[1-9]|1[0-6])@example[.]test$');
-- Move only the known sample HCI assignment from the overloaded demo teacher to the demo teacher with spare capacity.
-- Derived count is materialized to avoid reading the updated table directly in the subquery.
UPDATE classes c JOIN staff_accounts src ON src.id=c.teacher_id AND src.username='demo_hcdc_teacher01' AND src.role='teacher'
JOIN staff_accounts dest ON dest.username='demo_hcdc_teacher04' AND dest.role='teacher' AND dest.active=1
LEFT JOIN (SELECT teacher_id,COUNT(*) n FROM classes GROUP BY teacher_id) counts ON counts.teacher_id=dest.id
SET c.teacher_id=dest.id WHERE c.class_name='HCI 101 - DEMO A' AND COALESCE(counts.n,0)<3;
-- Base demo teacher gets two extra demo subjects if there is room; no existing assignments overwritten.
INSERT INTO classes(class_name,description,teacher_id,schedule)
SELECT 'DEMO102','Demo computing laboratory',t.id,'Tuesday | 09:00 - 10:00' FROM staff_accounts t WHERE t.username='teacher' AND t.role='teacher' AND t.active=1 AND (SELECT COUNT(*) FROM classes WHERE teacher_id=t.id)<3 AND NOT EXISTS(SELECT 1 FROM classes WHERE class_name='DEMO102');
INSERT INTO classes(class_name,description,teacher_id,schedule)
SELECT 'DEMO103','Demo applied computing',t.id,'Thursday | 09:00 - 10:00' FROM staff_accounts t WHERE t.username='teacher' AND t.role='teacher' AND t.active=1 AND (SELECT COUNT(*) FROM classes WHERE teacher_id=t.id)<3 AND NOT EXISTS(SELECT 1 FROM classes WHERE class_name='DEMO103');
-- General education offerings are illustrative for the demo programs; verify before real use.
INSERT INTO curriculum_subjects(course_id,class_id,year_level)
SELECT co.id,c.id,1 FROM courses co CROSS JOIN classes c WHERE co.course_name IN ('BSIT','BSHM','BSHRM','BSBA-FM','BSTM','BSCrim','BSPsych') AND c.class_name IN ('Comm 101 - DEMO A','Ethics 101 - DEMO A','Hist 101 - DEMO A','Math 101 - DEMO A','Hum 101 - DEMO A') AND NOT EXISTS(SELECT 1 FROM curriculum_subjects cs WHERE cs.course_id=co.id AND cs.class_id=c.id);
INSERT INTO curriculum_subjects(course_id,class_id,year_level)
SELECT co.id,c.id,1 FROM courses co CROSS JOIN classes c WHERE ((co.course_name='BSIT' AND c.class_name IN ('CC 101 - DEMO A','CC 102 - DEMO A','HCI 101 - DEMO A','DEMO101','DEMO102')) OR (co.course_name='BSBA-FM' AND c.class_name IN ('Acctg 101 - DEMO A','BACC 1 - DEMO A'))) AND NOT EXISTS(SELECT 1 FROM curriculum_subjects cs WHERE cs.course_id=co.id AND cs.class_id=c.id);
INSERT INTO curriculum_subjects(course_id,class_id,year_level,prerequisite_class_id)
SELECT co.id,c.id,1,p.id FROM courses co CROSS JOIN classes c JOIN classes p ON p.class_name='CC 102 - DEMO A' WHERE co.course_name='BSIT' AND c.class_name='CC 103 - DEMO A' AND NOT EXISTS(SELECT 1 FROM curriculum_subjects cs WHERE cs.course_id=co.id AND cs.class_id=c.id);
INSERT INTO curriculum_subjects(course_id,class_id,year_level)
SELECT co.id,c.id,2 FROM courses co CROSS JOIN classes c WHERE ((co.course_name='BSBA-FM' AND c.class_name='AFM 101 - DEMO A') OR (co.course_name='BSIT' AND c.class_name='DEMO103')) AND NOT EXISTS(SELECT 1 FROM curriculum_subjects cs WHERE cs.course_id=co.id AND cs.class_id=c.id);
COMMIT;
