<?php
require_once("./config.php");
require_once("./functions.php");

connectDb();

$sql = "Insert into blog_data (
			member,
			category,
			subject,
			body,
			created,
			modified)
		values (
			'".r($_POST['member'])."',
			'".r($_POST['category'])."',
			'".r($_POST['subject'])."',
			'".r($_POST['body'])."',
			now(),
			now()
		)";

$res = mysql_query($sql) or die("miss");

print "insert_success";