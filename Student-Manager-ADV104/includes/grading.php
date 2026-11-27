<?php
// Demo grading policy. Each component is a percentage from 0 to 100.
// Change only after the school approves a policy; existing grades are snapshots.
const GRADE_COMPONENTS = [
    'exam_score'=>['Exams',40],
    'quiz_score'=>['Quizzes / activities',20],
    'project_score'=>['Projects',25],
    'attendance_score'=>['Attendance',10],
    'participation_score'=>['Participation / others',5],
];
function grade_points(string $value, string $label): int {
    if (!preg_match('/^\d{1,3}(\.\d{1,2})?$/D', $value) || (float)$value > 100) {
        throw new DomainException("$label must be 0–100 with up to two decimal places.");
    }
    $parts=explode('.', $value);
    return (int)$parts[0]*100 + (int)str_pad($parts[1]??'',2,'0');
}
function grade_decimal(int $points): string { return sprintf('%d.%02d', intdiv($points,100), $points%100); }
function compute_grade(array $values): array {
    $total=0; $scores=[];
    foreach (GRADE_COMPONENTS as $key=>[$label,$weight]) {
        $points=grade_points(is_string($values[$key]??null)?$values[$key]:'',$label);
        $scores[$key]=grade_decimal($points); $total+=$points*$weight;
    }
    // Integer arithmetic: round half up to the nearest hundredth.
    $scores['score']=grade_decimal(intdiv($total+50,100));
    return $scores;
}
function grade_role_label(string $role): string { return $role==='staff'?'Enrollment staff':ucfirst($role); }
