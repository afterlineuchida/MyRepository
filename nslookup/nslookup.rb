#!C:\Ruby\bin\ruby
# coding: shift_jis

require 'pp'
require 'cgi'

##########################################
# 再帰的にSPFレコードを調査してハッシュに格納する関数
def SearchIncludeDom(domain, type="txt")
	dom_ary = []
	dom_hash = Hash.new
	
	# nslookupコマンドの出力を整形
	spf = `nslookup -type=#{type} #{domain}`
	spf = spf.match(%r{text =\n\n\s+"((.|\s|\n)*)"})
	
	unless spf.nil?
		spf = spf[1].gsub("\"", "").split("\s")
		
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
		
		# spf配列の要素数分ループ
		spf.each{|txt|
			include_dom = txt.match(%r{include:(.+)})
			
			# includeドメインのときは再帰する
			if include_dom
				dom_ary.push(SearchIncludeDom(include_dom[1]))
			else
				dom_ary.push(txt)
			end
		}
		
		dom_hash[domain] = dom_ary
		
	else
		dom_hash[domain] = dom_ary.push("txt is nothing")
	end
	
	dom_hash
end

#-----------------------------------------

def MakeHtmlTable(hash, idt=-1)
	# Hash型の引数からHTMLのテーブル(表)を作成するメソッド
	#
	# 引数
	# hash	: テーブルの元になるデータ
	# idt	: 再帰時にインデントをつけるときのカウンタ
	
	idt += 1

	table = ""
	table << "<table class='table table-bordered table-striped' >\n" if idt == 0
	table << "<tr>\n"

	# インデントの作成
	for i in 1..idt
		table << "<td></td>"
	end

	hash.each { |dom, txts|
		table << "<td><b>#{dom}</b></td>\n"

		if txts.kind_of?(Array)
			txts.each { |txt|
				if txt.kind_of?(Hash)
					table << "</tr>\n"
					table << MakeHtmlTable(txt, idt)
				else
					table << "<td>#{txt}</td>\n"
				end
			}
		end
		
	}
	table << "</table>\n" if idt == 0
	
	table
end


def GetARecords (domains)
	aRecord = Hash.new

	#改行毎にトリミングして分割
	domains = domains.rstrip.split(/\r?\n/).map { |dom| dom.chomp }

	domains.each {|domain|
		a_ary = []
		
		# nslookupコマンドの出力を整形
		a = `nslookup -type=a #{domain}`
		a = a.split("\n\n")

		#Aレコードが存在しない場合は次のドメインへ
		next if a[1].nil?
		
		domain = a[1].split("\n").map { |arecord| arecord.strip }

		domain.each { |dom|
			d =  dom =~ %r{\s} ? dom.split("\s")[1] : dom
			a_ary.push(d)
		}
		
		aRecord[a_ary.shift] = a_ary
		#pp aRecord
		#abort
	}

	aRecord.delete("request")

	aRecord
end

##########################################

print "Content-Type: text/html\n\n"

cgi_data = CGI.new
domains	 = cgi_data['domains']
type	 = cgi_data['type']
html_table = ""

##タイプ値によって出力する内容を変更
if type == "txt"
	allspf = SearchIncludeDom(domains)
	html_table = MakeHtmlTable(allspf)
elsif type == "a"
	aRecords = GetARecords(domains)

	html_table << "<table class='table table-bordered table-striped' >"
	aRecords.each { |d, a|
		html_table << "<tr>"
		html_table << "<th>#{d}</th>"
		a.each { |ip|
			html_table << "<td class='arecord'>#{ip}</td>"
		}
		html_table << "</tr>"
	}
	html_table << "</table>"
end


html = <<-EOF
<!DOCTYPE html>
<html lang='ja'>
<head>
	<meta charset='shift_jis'>
	<title>Nslookup Tool</title>
	<link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css">
	<style>
	 table th {
	   width: 100px;
	   /*table-layout: fixed;*/
	   word-wrap: break-word;
	 }
	 .arecord {
	   display: table-cell;
	   vertical-align: middle;
	 }
	</style>
</head>

<body>

#{html_table}

<input type='button' class='btn btn-default' onclick='location.href=\"javascript:history.back();\"' value='戻る' />

</body>
</html>
EOF
	
puts html
