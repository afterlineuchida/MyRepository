<?php
require_once('./config.php');

function connectDb() {
    $db = mysql_connect(DB_HOST, DB_USER, DB_PASS) or die('can not connect to DB: '.mysql_error());
    mysql_select_db(DB_NAME) or die('can not select DB: '.mysql_error());
	mysql_set_charset("utf8" , $db);
}

function h($s) {
    return htmlspecialchars($s);
}

function r($s) {
    return mysql_real_escape_string($s);
}

function jump($s) {
    header('Location: '.SITE_URL.$s);
    exit;
}