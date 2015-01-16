#!C:\Ruby193\bin\ruby
# coding: shift_jis

require 'pp'
require 'cgi'

$total_spf = ''
$total_loop_count = 0
$now_domain = ''

print "Content-Type: text/html\n\n"
print "<HTML lang='ja'>"
print "<head>"
print "<meta charset='sjis'>"
print "<title>Include SPF checker"
print "</title>"
print "</head>"
print "<BODY>\n"
print "<h3>SPF</h3>"
print "<table border=1>"


##########################################
# 再帰的にSPFレコードを調査してテーブル表示する関数
def SearchIncludeDom domain
	count = 0
	
	# nslookupコマンドの出力を整形
	spf = `nslookup -type=txt #{domain}`
	spf = spf.match(%r{\"(.|\s|\n)+})[0]
	spf = spf.gsub("\"", "").split("\s")
	
	
	# includeドメインの抽出
	include_doms = spf.select {|txt|
		# txt =~ %r{[include:|all]}
		txt =~ %r{include:}
	}
	# spf配列からincludeドメインを削除
	spf.delete_if{|txt|
		# txt =~ %r{[include:|all]}
		txt =~ %r{include:}
	}
	# 改めてspf配列の最後尾にincludeドメインを追加
	include_doms.each {|txt|
		spf.push(txt)
	}
	
	
	$total_spf << "<tr>\n"
	
	# includeを階層的に見せるためのインデント
	while count < $total_loop_count
		count += 1
		$total_spf << "<td>"
		$total_spf << "</td>"
	end
	
	$total_spf << "<td><b>"
	$total_spf << domain
	$total_spf << "</b></td>"
	
	
	# spf配列の要素数分ループ
	spf.each{|txt|
		include_dom = txt.match(%r{include:(.+)})
		
		# $total_spf << "<td>"
		# $total_spf << txt
		# $total_spf << "</td>"
		
		# includeドメインのときは再帰する
		if include_dom
			
			$total_spf << "\n</tr>\n"
			
			# インデントの数は再帰する前後で調整
			$total_loop_count += 1
			SearchIncludeDom(include_dom[1])
			$total_loop_count -= 1
		# elsif txt !~ /v=spf1/ && txt !~ /~all/
		else
			$total_spf << "<td>"
			$total_spf << txt
			$total_spf << "</td>"
		end
		
	}
	
	return $total_spf
end
##########################################


cgi_data = CGI.new
domain	 = cgi_data['domain']
# domain = "auchakudan.ddo.jp"
# domain = "mobi.clown1234.ddo.jp"

allspf = SearchIncludeDom(domain)
# SearchIncludeDom(domain)

print allspf
print "</tr>"
print "</table>\n"

print "<input type='button' onclick='location.href=\"./index.html\"' value='戻る' >"

print "</BODY></HTML>"
