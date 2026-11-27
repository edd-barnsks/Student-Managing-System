<?php
// Raw individual marks are stored as point totals, not percentages. Use integer hundredths.
function raw_points($value,string $label): int {
 if(!is_string($value)||!preg_match('/^\d{1,5}(\.\d{1,2})?$/D',$value))throw new DomainException("$label must be a non-negative number with at most two decimals (max 99999.99).");
 $parts=explode('.',$value);return (int)$parts[0]*100+(int)str_pad($parts[1]??'',2,'0');
}
function assessment_input(array $form,string $category): array {
 $names=$form[$category.'_title']??null;$earned=$form[$category.'_earned']??null;$max=$form[$category.'_max']??null;
 if(!is_array($names)||!is_array($earned)||!is_array($max)||count($names)<1||count($names)>30||array_keys($names)!==array_keys($earned)||array_keys($names)!==array_keys($max))throw new DomainException('Enter 1–30 complete '.$category.' assessments.');
 $out=[];$e=0;$m=0;$seen=[];
 foreach($names as $k=>$name){if(!is_string($name)||trim($name)===''||strlen(trim($name))>100)throw new DomainException('Each assessment needs a title (up to 100 bytes).');$name=trim($name);$key=strtolower($name);if(isset($seen[$key]))throw new DomainException('Assessment titles must be unique within each category.');$seen[$key]=true;$ep=raw_points($earned[$k],'Earned points');$mp=raw_points($max[$k],'Maximum points');if($mp<=0||$ep>$mp)throw new DomainException('Maximum points must be positive and earned points cannot exceed the maximum.');$e+=$ep;$m+=$mp;$out[]=['title'=>$name,'earned'=>grade_decimal($ep),'maximum'=>grade_decimal($mp)];}
 return ['score'=>grade_decimal(intdiv($e*10000+intdiv($m,2),$m)),'items'=>$out];
}
function assessment_form_rows(string $category,array $saved,bool $posted): array {
 if($posted&&is_array($_POST[$category.'_title']??null)){$out=[];foreach(array_slice($_POST[$category.'_title'],0,30,true) as $i=>$v){$out[]=['title'=>is_string($v)?$v:'','earned'=>is_string($_POST[$category.'_earned'][$i]??null)?$_POST[$category.'_earned'][$i]:'','maximum'=>is_string($_POST[$category.'_max'][$i]??null)?$_POST[$category.'_max'][$i]:''];}if($out)return $out;}
 return $saved?:[['title'=>'','earned'=>'','maximum'=>'']];
}
function period_status(?array $r): string {return !$r?'Not recorded':($r['locked_at']?'Submitted · locked':'Draft');}
function assessment_editor(string $category,array $items): void { ?>
<section class="assessment-group" data-assessment-group="<?=e($category)?>">
 <div class="assessment-heading"><h3><?=$category==='exam'?'Examinations':'Quizzes / activities'?></h3><span><?=$category==='exam'?'40%':'20%'?> weight</span></div>
 <div class="assessment-column-head" aria-hidden="true"><span>Assessment</span><span>Earned</span><span>Maximum</span><span></span></div>
 <div data-assessment-rows><?php foreach($items as $a):?>
  <div class="assessment-row">
   <label><span class="assessment-field-label">Assessment</span><input name="<?=e($category)?>_title[]" maxlength="100" required value="<?=e($a['title'])?>" placeholder="Assessment name"></label>
   <label><span class="assessment-field-label">Earned</span><input type="number" name="<?=e($category)?>_earned[]" min="0" max="99999.99" step="0.01" required value="<?=e($a['earned'])?>" data-earned placeholder="0"></label>
   <label><span class="assessment-field-label">Maximum</span><input type="number" name="<?=e($category)?>_max[]" min="0.01" max="99999.99" step="0.01" required value="<?=e($a['maximum'])?>" data-maximum placeholder="0"></label>
   <button type="button" class="assessment-remove" data-remove-assessment aria-label="Remove assessment" title="Remove assessment"><svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 7h16M9 7V4h6v3M6 7l1 13h10l1-13M10 11v5m4-5v5"/></svg></button>
  </div><?php endforeach;?></div>
 <button type="button" class="assessment-add" data-add-assessment>+ Add assessment</button>
 <div class="assessment-total"><span>Computed category grade</span><output data-category-result aria-live="polite">—</output></div>
</section><?php }
