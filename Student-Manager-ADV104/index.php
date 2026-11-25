<?php
// Single front controller; individual page modules are not directly executable.
ini_set('display_errors','0'); ini_set('session.use_strict_mode','1');
header('X-Content-Type-Options: nosniff'); header('X-Frame-Options: DENY'); header('Cache-Control: no-store'); header("Content-Security-Policy: default-src 'self'; img-src 'self' data:; style-src 'self'; script-src 'self'; form-action 'self'; frame-ancestors 'none'; base-uri 'self'");
session_name('student_manager_session'); session_set_cookie_params(['httponly'=>true,'samesite'=>'Lax','secure'=>!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS']!=='off','path'=>'/']); session_start();
require __DIR__.'/config/database.php'; require __DIR__.'/includes/functions.php'; require __DIR__.'/includes/auth.php';
define('APP_ENTRY',true);
$page=query('page')?:'dashboard';
$routes=['login'=>[], 'register'=>[], 'dashboard'=>['admin','teacher','student'],'students'=>['admin','teacher'],'classes'=>['admin','teacher','student'],'courses'=>['admin'],'staff'=>['admin'],'enrollments'=>['admin','teacher'],'grades'=>['admin','teacher','student'],'accounts'=>['admin'],'profile'=>['admin','teacher','student'],'audit'=>['admin'],'export'=>['admin'],'logout'=>['admin','teacher','student']];
if(!array_key_exists($page,$routes))missing();
$error=''; $user=null;
try {
    if($routes[$page])$user=require_user($routes[$page]); else $user=current_user();
    if(in_array($page,['login','register'],true)&&$user)redirect('dashboard');
    if($_SERVER['REQUEST_METHOD']==='POST')check_csrf();
    ob_start(); require __DIR__.'/pages/'.$page.'.php'; $content=ob_get_clean();
    require __DIR__.'/includes/layout.php';
} catch(Throwable $ex) { if(ob_get_level())ob_end_clean(); error_log_file($ex); http_response_code(500); echo '<h1>Something went wrong</h1><p>Check MySQL, import the database, and verify config/database.php. See logs/error.log for technical details.</p><a href="index.php">Try again</a>'; }
