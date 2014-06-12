<!DOCTYPE html>
<html lang="ja">
<head>
	<meta charset="utf-8">
	<title>投稿ページ</title>
</head>

<body>
<form method="POST" action="./blog_insert.php">
	<span style="font-size: 30px; bold; float: left;" >なめぶろ投稿ページ</span>
	<table style="float: left;">
		<tr>
			<th>名前</th>
			<th>カテゴリー</th>
		</tr>
		<tr>
			<td>
				<select name="member" >
					<option value="すみと">すみと</option>
					<option value="かをり">かをり</option>
					<option value="なる">なる</option>
					<option value="ちょび">ちょび</option>
					<option value="しんや">しんや</option>
					<option value="かさやん">かさやん</option>
					<option value="ウチダ">ウチダ</option>
				</select>
			</td>
			<td><input type="text" name="category" ></td>
		</tr>
	</table>
	
	<div style="clear: both;">
		<p>タイトル:</p>
		<p><input type="text" name="subject" ></p>
		<p>本文:</p>
		<p><textarea name="body" rows="40" cols="80"></textarea></p>
		<input type="submit" value="投稿">
	</div>
</form>
</body>
</html>
