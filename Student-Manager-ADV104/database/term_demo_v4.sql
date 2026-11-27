-- OPTIONAL: assigns illustrative terms/units ONLY to known V3 demonstration offerings.
-- Not official HCDC units or academic history. Run once after the V4 upgrade.
START TRANSACTION;
INSERT INTO academic_terms(academic_year,semester) SELECT '2026-2027','first' WHERE NOT EXISTS(SELECT 1 FROM academic_terms WHERE academic_year='2026-2027' AND semester='first');
INSERT INTO academic_terms(academic_year,semester) SELECT '2026-2027','second' WHERE NOT EXISTS(SELECT 1 FROM academic_terms WHERE academic_year='2026-2027' AND semester='second');
UPDATE classes c JOIN academic_terms oldterm ON oldterm.id=c.term_id AND oldterm.semester='unspecified'
JOIN academic_terms newterm ON newterm.academic_year='2026-2027' AND newterm.semester='first'
JOIN staff_accounts a ON a.id=c.teacher_id AND (a.username='teacher' OR a.username IN ('demo_hcdc_teacher01','demo_hcdc_teacher02','demo_hcdc_teacher03','demo_hcdc_teacher04'))
LEFT JOIN classes existing ON existing.class_name=c.class_name AND existing.term_id=newterm.id
SET c.term_id=newterm.id,c.units=COALESCE(c.units,3.0)
WHERE existing.id IS NULL AND c.class_name IN ('DEMO101','DEMO102','DEMO103','CC 101 - DEMO A','CC 102 - DEMO A','CC 103 - DEMO A','HCI 101 - DEMO A','Acctg 101 - DEMO A','AFM 101 - DEMO A','BACC 1 - DEMO A','Comm 101 - DEMO A','Ethics 101 - DEMO A','Hist 101 - DEMO A','Math 101 - DEMO A','Hum 101 - DEMO A');
COMMIT;
