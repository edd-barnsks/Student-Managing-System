<?php
function e($value): string { return htmlspecialchars((string)$value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8'); }
function rows(string $sql, array $params=[]): array { $s=db()->prepare($sql); $s->execute($params); return $s->fetchAll(); }
function one(string $sql, array $params=[]): ?array { return rows($sql,$params)[0] ?? null; }
function execute(string $sql, array $params=[]): int { $s=db()->prepare($sql); $s->execute($params); return $s->rowCount(); }
function url(string $page, array $params=[]): string { return 'index.php?'.http_build_query(['page'=>$page]+$params); }
function redirect(string $page, array $params=[]): never { header('Location: '.url($page,$params),true,303); exit; }
function flash(string $message): void { $_SESSION['flash']=$message; }
function csrf(): string { return $_SESSION['csrf'] ??= bin2hex(random_bytes(32)); }
function csrf_field(): string { return '<input type="hidden" name="csrf" value="'.e(csrf()).'">'; }
function check_csrf(): void { if (!hash_equals(csrf(), post('csrf'))) { http_response_code(403); exit('Invalid form token. Refresh and try again.'); } }
function post(string $key): string { return is_string($_POST[$key]??null) ? $_POST[$key] : ''; }
function query(string $key): string { return is_string($_GET[$key]??null) ? $_GET[$key] : ''; }
function text_field(string $key, int $max, string $label, bool $required=true): string { $v=trim(post($key)); if (($required && $v==='') || strlen($v)>$max) throw new DomainException("$label is required or exceeds $max characters."); return $v; }
function id_field(string $key): int { $v=filter_var(post($key),FILTER_VALIDATE_INT,['options'=>['min_range'=>1]]); if ($v===false) throw new DomainException('Select a valid record.'); return $v; }
function password_field(string $key='password'): string { $p=post($key); if(strlen($p)<10 || strlen($p)>72 || str_contains($p,"\0")) throw new DomainException('Password must contain 10–72 bytes.'); return $p; }
function username_field(): string { $v=trim(post('username')); if(!preg_match('/^[a-zA-Z0-9_.-]{3,50}$/D',$v)) throw new DomainException('Username must be 3–50 letters, numbers, dots, underscores or hyphens.'); return $v; }
function error_log_file(Throwable $ex): void { error_log(date('c').' '.get_class($ex).' '.$ex->getMessage().PHP_EOL,3,__DIR__.'/../logs/error.log'); }
function audit(string $action, string $target): void { $u=$_SESSION['auth']??[]; execute('INSERT INTO audit_logs(actor_role,actor_id,action,target) VALUES(?,?,?,?)',[$u['role']??'public',$u['id']??null,$action,$target]); }
function transaction(callable $fn) { $pdo=db(); $pdo->beginTransaction(); try { $r=$fn(); $pdo->commit(); return $r; } catch(Throwable $e) { if($pdo->inTransaction())$pdo->rollBack(); throw $e; } }
function val(string $key, array $record=[]): string { return e($_SERVER['REQUEST_METHOD']==='POST' && isset($_POST[$key]) ? post($key) : ($record[$key]??'')); }
function selected($a,$b): string { return (string)$a===(string)$b?' selected':''; }
function deny(): never { http_response_code(403); exit('Access denied. <a href="index.php">Return to Student Manager</a>'); }
function missing(): never { http_response_code(404); exit('Record not found. <a href="index.php">Return to Student Manager</a>'); }
function confirmed(): void { if(post('confirm')!=='yes') throw new DomainException('Confirm the deletion before continuing.'); }
function search_term(): string { return substr(trim(query('q')),0,100); }
function search_form(string $page,?int $term=null): void { ?><form method="get" class="search"><input type="hidden" name="page" value="<?=e($page)?>"><input name="q" maxlength="100" placeholder="Search records…" value="<?=e(search_term())?>"><?php if($page==='classes')term_select($term);?><button>Search</button><a class="button secondary" href="<?=e(url($page))?>">Clear</a></form><?php }
function delete_form(string $page,int $id,string $action='delete'): void { ?><form method="post" action="<?=e(url($page))?>" class="inline delete" data-confirm><?=csrf_field()?><input type="hidden" name="action" value="<?=e($action)?>"><input type="hidden" name="id" value="<?=$id?>"><label class="check"><input type="checkbox" name="confirm" value="yes" required> Confirm</label><button class="danger">Delete</button></form><?php }
