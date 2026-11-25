<?php
function current_user(): ?array {
    $s=$_SESSION['auth']??null; if(!$s)return null;
    if($s['role']==='student') $u=one('SELECT a.id,a.username,a.student_id,a.active,a.session_version,s.name FROM student_accounts a JOIN students s ON s.id=a.student_id WHERE a.id=? AND a.active=1',[$s['id']]);
    else $u=one('SELECT id,username,name,role,active,session_version FROM staff_accounts WHERE id=? AND active=1',[$s['id']]);
    if(!$u || (int)$u['session_version']!==(int)($s['version']??0) || (isset($u['role']) && $u['role']!==$s['role'])) { unset($_SESSION['auth']); return null; }
    $u['role']=$s['role']; return $u;
}
function require_user(array $roles=[]): array { $u=current_user(); if(!$u)redirect('login'); if($roles && !in_array($u['role'],$roles,true))deny(); return $u; }
function login_user(string $role,string $username,string $password): bool {
    if(!in_array($role,['student','teacher','admin'],true))return false;
    $u=$role==='student'?one('SELECT id,password_hash,session_version FROM student_accounts WHERE username=? AND active=1',[$username]):one('SELECT id,password_hash,session_version FROM staff_accounts WHERE username=? AND role=? AND active=1',[$username,$role]);
    if(!$u || !password_verify($password,$u['password_hash']))return false;
    session_regenerate_id(true); $_SESSION=['auth'=>['id'=>(int)$u['id'],'role'=>$role,'version'=>(int)$u['session_version']]]; return true;
}
function logout_user(): void { $_SESSION=[]; $p=session_get_cookie_params(); setcookie(session_name(),'',time()-3600,$p['path'],$p['domain'],$p['secure'],$p['httponly']); session_destroy(); }
function teacher_class(int $classId,int $teacherId): bool { return one('SELECT id FROM classes WHERE id=? AND teacher_id=?',[$classId,$teacherId])!==null; }
