<?php
if(PHP_SAPI!=='cli')exit;
require __DIR__.'/../includes/grading.php';
function expect($actual,$expected){if($actual!==$expected)throw new RuntimeException(var_export($actual,true).' != '.var_export($expected,true));}
function input_values($values){return array_combine(array_keys(GRADE_COMPONENTS),$values);}
expect(array_sum(array_column(GRADE_COMPONENTS,1)),100);
expect(compute_grade(input_values(['90','85','95','100','80']))['score'],'90.75');
expect(compute_grade(input_values(array_fill(0,5,'0')))['score'],'0.00');
expect(compute_grade(input_values(array_fill(0,5,'100')))['score'],'100.00');
expect(compute_grade(input_values(['0.00','0','0.02','0','0']))['score'],'0.01');
expect(compute_grade(input_values(['0.01','0','0','0','0']))['score'],'0.00');
foreach(['','-1','101','100.01','90.123','1e2','NaN',[],null] as $bad){
    $values=input_values([$bad,'80','80','80','80']);
    try{compute_grade($values);throw new RuntimeException('Invalid input accepted');}catch(DomainException $e){}
}
$values=input_values(['90','85','95','100','80']);$values['score']='0';expect(compute_grade($values)['score'],'90.75');
echo "All grade calculation tests passed.\n";
