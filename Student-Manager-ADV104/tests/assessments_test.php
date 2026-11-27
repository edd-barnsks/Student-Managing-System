<?php
if(PHP_SAPI!=='cli')exit;
require __DIR__.'/../includes/grading.php';require __DIR__.'/../includes/assessments.php';require __DIR__.'/../includes/terms.php';
function check($a,$b){if($a!==$b)throw new RuntimeException(var_export($a,true).' != '.var_export($b,true));}
function rejected($f){try{$f();}catch(DomainException $e){return;}throw new RuntimeException('Invalid data accepted');}
$exam=['exam_title'=>['Exam 1','Exam 2'],'exam_earned'=>['45','80'],'exam_max'=>['50','100']];
$quiz=['quiz_title'=>['Quiz 1','Quiz 2'],'quiz_earned'=>['8','18'],'quiz_max'=>['10','20']];
check(assessment_input($exam,'exam')['score'],'83.33');check(assessment_input($quiz,'quiz')['score'],'86.67');
check(compute_grade(['exam_score'=>'83.33','quiz_score'=>'86.67','project_score'=>'90','attendance_score'=>'100','participation_score'=>'90'])['score'],'87.67');
check(assessment_input(['exam_title'=>['A'],'exam_earned'=>['0'],'exam_max'=>['50']],'exam')['score'],'0.00');
check(assessment_input(['exam_title'=>['A'],'exam_earned'=>['99999.99'],'exam_max'=>['99999.99']],'exam')['score'],'100.00');
rejected(fn()=>assessment_input(array_replace($exam,['exam_max'=>['0','100']]),'exam'));
rejected(fn()=>assessment_input(array_replace($exam,['exam_earned'=>['51','80']]),'exam'));
rejected(fn()=>assessment_input(array_replace($exam,['exam_earned'=>['1.001','80']]),'exam'));
rejected(fn()=>assessment_input(array_replace($exam,['exam_title'=>['Exam','exam']]),'exam'));
rejected(fn()=>assessment_input(array_replace($exam,['exam_title'=>['Exam']]),'exam'));
rejected(fn()=>assessment_input([],'exam'));
check(period_status(null),'Not recorded');check(period_status(['locked_at'=>null]),'Draft');check(period_status(['locked_at'=>'2026-11-27 10:00:00']),'Submitted · locked');
check(unit_label('10.0'),'10 units');check(unit_label(null),'Units not set');check(term_label(['academic_year'=>'2026-2027','semester'=>'second']),'2026-2027 · Second semester');
echo "17 assessment, locking-label and term checks passed.\n";
