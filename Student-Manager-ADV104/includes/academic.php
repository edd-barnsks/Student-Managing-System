<?php
const GRADE_PERIODS=['prelim'=>'Prelim','midterm'=>'Midterm','finals'=>'Finals'];
const DEMO_PASS_MARK=75;
function period_field(): string { $p=post('period'); if(!isset(GRADE_PERIODS[$p]))throw new DomainException('Select a valid grading period.'); return $p; }
function positive_query(string $key): ?int { $v=filter_var(query($key),FILTER_VALIDATE_INT,['options'=>['min_range'=>1]]); return $v===false?null:$v; }
function grade_display($value): string { return $value===null?'—':number_format((float)$value,2); }
function summary_label(array $r): string { if((int)$r['period_count']===3)return grade_display($r['overall']); if((int)$r['period_count']===0 && $r['legacy_score']!==null)return grade_display($r['legacy_score']).' (legacy)'; return (int)$r['period_count']===0?'Not graded':'Pending ('.$r['period_count'].'/3)'; }
function enrollment_choices(array $student,int $year,int $term): array {
 // A curriculum mapping identifies a subject by its stable code; each term has its own offering ID.
 // Historical enrollments remain visible. For prerequisites, only an earlier term (or migrated historical record) counts.
 return rows("SELECT c.id,c.class_name,c.description,c.schedule,c.units,COALESCE(t.name,'Unassigned') teacher,cs.year_level,cs.prerequisite_class_id,pr.class_name prerequisite,
 (SELECT MIN(e.id) FROM enrollments e JOIN classes ec ON ec.id=e.class_id WHERE e.student_id=? AND ec.class_name=c.class_name) existing_id,
 (SELECT MAX(g.overall) FROM enrollments e JOIN classes ec ON ec.id=e.class_id JOIN grade_summary g ON g.enrollment_id=e.id WHERE e.student_id=? AND ec.class_name=c.class_name) overall,
 (SELECT MAX(pg.overall) FROM enrollments pe JOIN classes pc ON pc.id=pe.class_id JOIN academic_terms pt ON pt.id=pc.term_id JOIN grade_summary pg ON pg.enrollment_id=pe.id WHERE pe.student_id=? AND pc.class_name=pr.class_name AND (pt.semester='unspecified' OR pt.academic_year<ct.academic_year OR (pt.academic_year=ct.academic_year AND FIELD(pt.semester,'first','second','summer')<FIELD(ct.semester,'first','second','summer')))) prerequisite_grade
 FROM curriculum_subjects cs JOIN classes mapped ON mapped.id=cs.class_id JOIN classes c ON c.class_name=mapped.class_name JOIN academic_terms ct ON ct.id=c.term_id LEFT JOIN staff_accounts t ON t.id=c.teacher_id LEFT JOIN classes pr ON pr.id=cs.prerequisite_class_id
 WHERE cs.course_id=? AND cs.year_level=? AND c.term_id=? ORDER BY c.class_name",[$student['id'],$student['id'],$student['id'],$student['course_id'],$year,$term]);
}
function enrollment_block(array $r): ?string {
 if($r['existing_id']!==null){if($r['overall']!==null)return (float)$r['overall']>=DEMO_PASS_MARK?'Already taken · passed':'Already taken · review required';return 'Already enrolled';}
 if($r['prerequisite_class_id']!==null && ($r['prerequisite_grade']===null||(float)$r['prerequisite_grade']<DEMO_PASS_MARK))return 'Prerequisite not passed: '.$r['prerequisite'];
 return null;
}
