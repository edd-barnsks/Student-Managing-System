<?php
function term_label(array $term): string {
 return $term['semester']==='unspecified'?'Unassigned / historical':$term['academic_year'].' · '.(['first'=>'First semester','second'=>'Second semester','summer'=>'Summer'][$term['semester']]??$term['semester']);
}
function terms(): array {return rows("SELECT id,academic_year,semester FROM academic_terms ORDER BY semester='unspecified',academic_year DESC,FIELD(semester,'summer','second','first','unspecified')");}
function term_options(): array {$out=[];foreach(terms() as $t)$out[$t['id']]=term_label($t);return $out;}
function term_select(?int $term, bool $all=true): void { ?><label>Academic term<select name="term" <?=$all?'':'required'?>><?php if($all):?><option value="">All terms</option><?php endif;?><?php foreach(terms() as $t):?><option value="<?=e($t['id'])?>"<?=selected($term,$t['id'])?>><?=e(term_label($t))?></option><?php endforeach;?></select></label><?php }
function term_query(): ?int {$id=positive_query('term');if($id&&!one('SELECT id FROM academic_terms WHERE id=?',[$id]))missing();return $id;}
function unit_label($units): string {return $units===null?'Units not set':rtrim(rtrim(number_format((float)$units,1,'.',''),'0'),'.').' units';}
