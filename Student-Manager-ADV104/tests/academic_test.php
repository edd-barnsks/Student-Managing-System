<?php
if(PHP_SAPI!=='cli')exit;
require __DIR__.'/../includes/academic.php';
function expect($actual,$expected){if($actual!==$expected)throw new RuntimeException(var_export($actual,true).' != '.var_export($expected,true));}
$r=['existing_id'=>null,'overall'=>null,'prerequisite_class_id'=>null,'prerequisite_grade'=>null,'prerequisite'=>'CC102'];
expect(enrollment_block($r),null);
expect(enrollment_block(array_replace($r,['existing_id'=>1])),'Already enrolled');
expect(enrollment_block(array_replace($r,['existing_id'=>1,'overall'=>'75.00'])),'Already taken · passed');
expect(enrollment_block(array_replace($r,['existing_id'=>1,'overall'=>'74.99'])),'Already taken · review required');
expect(enrollment_block(array_replace($r,['prerequisite_class_id'=>2])),'Prerequisite not passed: CC102');
expect(enrollment_block(array_replace($r,['prerequisite_class_id'=>2,'prerequisite_grade'=>'74.99'])),'Prerequisite not passed: CC102');
expect(enrollment_block(array_replace($r,['prerequisite_class_id'=>2,'prerequisite_grade'=>'75.00'])),null);
expect(summary_label(['period_count'=>0,'legacy_score'=>'90.00','overall'=>'90.00']),'90.00 (legacy)');
expect(summary_label(['period_count'=>0,'legacy_score'=>null,'overall'=>null]),'Not graded');
expect(summary_label(['period_count'=>1,'legacy_score'=>'90.00','overall'=>null]),'Pending (1/3)');
expect(summary_label(['period_count'=>3,'legacy_score'=>null,'overall'=>'91.67']),'91.67');
echo "11 academic rule tests passed.\n";
