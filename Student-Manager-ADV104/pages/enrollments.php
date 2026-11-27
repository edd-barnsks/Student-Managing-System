<?php
if(!defined('APP_ENTRY'))exit;
if(!in_array($user['role'],['admin','staff'],true))deny();
$sid=positive_query('student'); $q=search_term();$term=term_query()??(int)(one("SELECT t.id FROM academic_terms t WHERE EXISTS(SELECT 1 FROM classes c WHERE c.term_id=t.id) ORDER BY t.semester='unspecified',t.academic_year DESC,FIELD(t.semester,'summer','second','first','unspecified') LIMIT 1")['id']??(terms()[0]['id']??0));
if($_SERVER['REQUEST_METHOD']==='POST'){
 try{
  $sid=id_field('student_id'); $action=post('action');
  $message=transaction(function()use($sid,$action){
   $student=one('SELECT id,course_id,year_level FROM students WHERE id=? FOR UPDATE',[$sid]);if(!$student)throw new DomainException('Student not found.');
   if($action==='create'){
    $term=id_field('term_id');if(!one('SELECT id FROM academic_terms WHERE id=? FOR UPDATE',[$term]))throw new DomainException('Select an academic term.');$year=id_field('year_level');if(!$student['year_level']||$year>(int)$student['year_level'])throw new DomainException('Choose an eligible year level.');
    $raw=$_POST['class_ids']??[];if(!is_array($raw)||!count($raw)||count($raw)>100)throw new DomainException('Select at least one available subject.');
    $ids=[];foreach($raw as $v){$id=is_string($v)?filter_var($v,FILTER_VALIDATE_INT,['options'=>['min_range'=>1]]):false;if(!$id)throw new DomainException('Invalid subject.');$ids[$id]=$id;}
    foreach($ids as $id)if(!one('SELECT id FROM classes WHERE id=? AND term_id=? FOR UPDATE',[$id,$term]))throw new DomainException('Subject is not offered in that term.');
    $eligible=array_column(enrollment_choices($student,$year,$term),null,'id');
    foreach($ids as $id){if(!isset($eligible[$id]))throw new DomainException('Subject is not part of the selected program and year.');if($why=enrollment_block($eligible[$id]))throw new DomainException($why.' No changes saved.');}
    foreach($ids as $id){execute('INSERT INTO enrollments(student_id,class_id) VALUES(?,?)',[$sid,$id]);audit('enroll',"student #$sid / class #$id");}return count($ids).' subject(s) enrolled.';
   }
   if($action==='delete'){
    confirmed();$id=id_field('id');if(!one('SELECT id FROM enrollments WHERE id=? AND student_id=? FOR UPDATE',[$id,$sid]))throw new DomainException('Enrollment not found.');
    if(one('SELECT id FROM grades WHERE enrollment_id=?',[$id])||one('SELECT id FROM grade_periods WHERE enrollment_id=? LIMIT 1',[$id]))throw new DomainException('A recorded grade prevents removing this enrollment.');
    execute('DELETE FROM enrollments WHERE id=?',[$id]);audit('unenroll',"enrollment #$id");return 'Enrollment removed.';
   }deny();
  });flash($message);redirect('enrollments',['student'=>$sid,'term'=>$term]);
 }catch(DomainException $ex){$error=$ex->getMessage();}catch(PDOException $ex){error_log_file($ex);$error='Unable to update enrollment. Try again.';}
}
$matches=$q!==''?rows('SELECT s.id,s.name,s.year_level,co.course_name FROM students s JOIN courses co ON co.id=s.course_id WHERE s.name LIKE ? ORDER BY s.name,s.id LIMIT 100',['%'.$q.'%']):[];
$student=$sid?one('SELECT s.id,s.name,s.course_id,s.year_level,co.course_name FROM students s JOIN courses co ON co.id=s.course_id WHERE s.id=?',[$sid]):null;
$year=$student&&$student['year_level']?(int)($error&&post('year_level')!==''?post('year_level'):(positive_query('year')??$student['year_level'])):0;
if($student&&($year<1||$year>(int)$student['year_level']))$year=(int)$student['year_level'];
$choices=$student&&$year?enrollment_choices($student,$year,$term):[];
$history=$student?rows('SELECT en.id,c.class_name,c.description,c.units,t.academic_year,t.semester,gs.* FROM enrollments en JOIN classes c ON c.id=en.class_id JOIN academic_terms t ON t.id=c.term_id JOIN grade_summary gs ON gs.enrollment_id=en.id WHERE en.student_id=? ORDER BY c.class_name',[$sid]):[];
?>
<?php if($error):?><div class="error"><?=e($error)?></div><?php endif;?>
<section class="panel"><h2>Find a student</h2><form method="get" class="search"><input type="hidden" name="page" value="enrollments"><input name="q" aria-label="Student name" placeholder="Type student name…" value="<?=e($q)?>" maxlength="100" required><button>Find student</button></form>
<?php if($q!==''):?><div class="table-wrap"><table><thead><tr><th>Name</th><th>ID</th><th>Program</th><th>Year</th><th></th></tr></thead><tbody><?php foreach($matches as $s):?><tr><td><?=e($s['name'])?></td><td><?=e($s['id'])?></td><td><?=e($s['course_name'])?></td><td><?=e($s['year_level']??'Not set')?></td><td><a class="button secondary" href="<?=e(url('enrollments',['student'=>$s['id'],'q'=>$q,'term'=>$term]))?>">Select</a></td></tr><?php endforeach;?><?php if(!$matches):?><tr><td colspan="5">No students found.</td></tr><?php endif;?></tbody></table></div><?php endif;?></section>
<?php if($student):?>
<section class="panel"><div class="toolbar"><div><h2><?=e($student['name'])?></h2><p class="muted"><?=e($student['course_name'])?> · Student #<?=e($sid)?> · Year <?=e($student['year_level']??'not set')?></p></div><a class="button secondary" href="<?=e(url('enrollments'))?>">Change student</a></div>
<?php if(!$year):?><div class="notice">Ask an administrator to set this student's year level in Students before enrolling.</div><?php else:?>
<form method="get" class="search"><input type="hidden" name="page" value="enrollments"><input type="hidden" name="student" value="<?=e($sid)?>"><label>Curriculum year<select name="year"><?php for($i=1;$i<=(int)$student['year_level'];$i++):?><option value="<?=$i?>"<?=selected($year,$i)?>>Year <?=$i?></option><?php endfor;?></select></label><?php term_select($term,false);?><button>Show subjects</button></form>
<p class="muted">Only mapped subjects from the selected program and year are shown. Previously enrolled subjects and unmet prerequisites are blocked. Earlier years are available for missing subjects.</p>
<form method="post" action="<?=e(url('enrollments',['student'=>$sid,'year'=>$year,'term'=>$term]))?>"><?=csrf_field()?><input type="hidden" name="action" value="create"><input type="hidden" name="student_id" value="<?=e($sid)?>"><input type="hidden" name="year_level" value="<?=e($year)?>"><input type="hidden" name="term_id" value="<?=e($term)?>"><div class="subject-options"><?php $available=0;foreach($choices as $c):$block=enrollment_block($c);if(!$block)$available++;?><label class="check"><input type="checkbox" name="class_ids[]" value="<?=e($c['id'])?>"<?=$block?' disabled':''?>><span><?=e($c['class_name'].' — '.$c['description'])?><small class="muted"><?=e($c['teacher'].' · '.$c['schedule'].' · '.unit_label($c['units']))?></small><?php if($block):?><small class="pill"><?=e($block)?></small><?php endif;?></span></label><?php endforeach;?><?php if(!$choices):?><p>No mapped subjects offered in this year and term. Ask an administrator to configure Curriculum or Classes.</p><?php endif;?></div><div class="spaced"><button<?=$available?'':' disabled'?>>Enroll selected subjects</button></div></form><?php endif;?></section>
<section class="panel"><h2>Enrollment and subject history</h2><div class="table-wrap"><table><thead><tr><th>Subject</th><th>Term</th><th>Units</th><th>Overall grade</th><th>Status</th><th>Action</th></tr></thead><tbody><?php foreach($history as $r):$locked=$r['legacy_id']!==null||(int)$r['period_count']>0;?><tr><td><?=e($r['class_name'].' — '.$r['description'])?></td><td><?=e(term_label($r))?></td><td><?=e(unit_label($r['units']))?></td><td><?=e(summary_label($r))?></td><td><?=e($r['overall']===null?'Enrolled / in progress':((float)$r['overall']>=DEMO_PASS_MARK?'Passed':'Review required'))?></td><td><?php if($locked):?>Grade recorded · locked<?php else:?><form method="post" action="<?=e(url('enrollments',['student'=>$sid]))?>" class="inline" data-confirm><?=csrf_field()?><input type="hidden" name="student_id" value="<?=e($sid)?>"><input type="hidden" name="id" value="<?=e($r['id'])?>"><input type="hidden" name="action" value="delete"><label class="check"><input type="checkbox" name="confirm" value="yes" required> Confirm</label><button class="danger">Remove</button></form><?php endif;?></td></tr><?php endforeach;?><?php if(!$history):?><tr><td colspan="6">No enrollment history.</td></tr><?php endif;?></tbody></table></div></section><?php endif;?>
