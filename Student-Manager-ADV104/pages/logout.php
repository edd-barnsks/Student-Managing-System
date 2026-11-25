<?php if(!defined('APP_ENTRY'))exit; if($_SERVER['REQUEST_METHOD']!=='POST')deny(); logout_user(); redirect('login');
