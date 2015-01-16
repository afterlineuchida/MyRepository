#!C:\Ruby\bin\ruby
# coding: shift_jis

require 'pp'
require 'cgi'

##########################################
# �ċA�I��SPF���R�[�h�𒲍����ăn�b�V���Ɋi�[����֐�
def SearchIncludeDom(domain, type="txt")
	dom_ary = []
	dom_hash = Hash.new
	
	# nslookup�R�}���h�̏o�͂𐮌`
	spf = `nslookup -type=#{type} #{domain}`
	spf = spf.match(%r{text =\n\n\s+"((.|\s|\n)*)"})
	
	unless spf.nil?
		spf = spf[1].gsub("\"", "").split("\s")
		
		# include�h���C���̒��o
		include_doms = spf.select {|txt|
			# txt =~ %r{[include:|all]}
			txt =~ %r{include:}
		}
		# spf�z�񂩂�include�h���C�����폜
		spf.delete_if{|txt|
			# txt =~ %r{[include:|all]}
			txt =~ %r{include:}
		}
		# ���߂�spf�z��̍Ō����include�h���C����ǉ�
		include_doms.each {|txt|
			spf.push(txt)
		}
		
		# spf�z��̗v�f�������[�v
		spf.each{|txt|
			include_dom = txt.match(%r{include:(.+)})
			
			# include�h���C���̂Ƃ��͍ċA����
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
	# Hash�^�̈�������HTML�̃e�[�u��(�\)���쐬���郁�\�b�h
	#
	# ����
	# hash	: �e�[�u���̌��ɂȂ�f�[�^
	# idt	: �ċA���ɃC���f���g������Ƃ��̃J�E���^
	
	idt += 1

	table = ""
	table << "<table class='table table-bordered table-striped' >\n" if idt == 0
	table << "<tr>\n"

	# �C���f���g�̍쐬
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

	#���s���Ƀg���~���O���ĕ���
	domains = domains.rstrip.split(/\r?\n/).map { |dom| dom.chomp }

	domains.each {|domain|
		a_ary = []
		
		# nslookup�R�}���h�̏o�͂𐮌`
		a = `nslookup -type=a #{domain}`
		a = a.split("\n\n")

		#A���R�[�h�����݂��Ȃ��ꍇ�͎��̃h���C����
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

##�^�C�v�l�ɂ���ďo�͂�����e��ύX
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

<input type='button' class='btn btn-default' onclick='location.href=\"javascript:history.back();\"' value='�߂�' />

</body>
</html>
EOF
	
puts html
