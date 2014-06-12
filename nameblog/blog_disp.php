<?php
require_once('./config.php');
require_once('./functions.php');

connectDb();

$blog_sql = "
	SELECT
		*
	FROM
		blog_data";

$blog_res = mysql_query($blog_sql);

while($blog_row = mysql_fetch_assoc($blog_res)) {
	
}