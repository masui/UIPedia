# -*- coding: utf-8 -*-
#
# ACM Digital LibraryのデータをScrapbox型式に変換する
#

require 'net/http'
require 'net/https'

class Bib
  USERAGENT = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.0.1) Gecko/20060111 Firefox/1.5.0.1'

  def initialize
    @data = {}
  end

  def get__(server,command)
    #puts "get(#{server},#{command})"
    body = ''
    Net::HTTP.start(server, 80) {|http|
      response = http.get(command, 'User-Agent' => USERAGENT)
      body = response.body
    }
    body.force_encoding("utf-8")
    body.sub!(/^\xef\xbb\xbf/,'') # UTF指示のバイト列
    body
  end

  def get(server,command)
    http = Net::HTTP.new('dl.acm.org', 443)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    req = Net::HTTP::Get.new(command, {'User-Agent' => USERAGENT})
    res = http.request(req)
    body = res.body
  end

  def parse(refer)
    refer.split(/\n/).each { |line|
      line.chomp!
      if line =~ /^%(.)\s+(.*)$/ then
        key = $1
        value = $2
        if @data[key].nil? then
          @data[key] = []
        end
        # 日本人(?)は名前に空白を入れない
        #if key == 'A' && value =~ /[\x80-\xff]/ then
        if key == 'A' && value !~ /^[ -~｡-ﾟ]*$/ then
          value.sub!(/ /,'')
        end
        @data[key] << value
      end
    }
  end

  def wikititle
    ''
  end

  def wikibody
    ''
  end
end

class ACMBib < Bib
  def initialize(doistring)
    super()
    doistring = doistring.to_s
    if doistring =~ /(id=)?(\d+)\.(\d+)/ then
      @parentid = $2
      @id = $3
    elsif doistring =~ /id=(\d+)/ then
      @id = $1
    elsif doistring =~ /(\d+)$/ then
      # 1267739
      @id = $1
    end
    server = 'dl.acm.org'
    command = "/exportformats.cfm?id=#{@id}&expformat=endnotes"

    acmdata = get(server,command)

    pre = false
    out = []

    acmdata.split(/[\r\n]+/).each { |line|
      line.chomp!
      if line =~ /^<pre/i then
        pre = true
      elsif line =~ /^<\/pre/i then
        pre = false
      else
        out << line if pre
      end
    }
    refer = out.join("\n")+"\n"
    parse(refer)
  end

  def wikititle
    "#{@data['A'][0]}: #{@data['T'][0]}"
  end

  def wikibody
#    if @data['0'][0] == 'Conference Paper' then
      <<EOF
[[タイトル]]
 #{@data['T'][0]}
[[ソース]]
 #{@data['B'] ? @data['B'][0] : @data['J'] ? @data['J'][0] : ''}
[[巻]]
 #{@data['V'] ? @data['V'][0] : ''}
[[号]]
 #{@data['N'] ? @data['N'][0] : ''}
[[ページ]]
 #{@data['P'][0]}
[[年]]
 #{@data['D'][0]}
[[ISBN]]
 #{@data['@'] ? @data['@'][0] : ''}
[[著者]]
 #{@data['A'].collect { |a| '['+a.sub(/\s*$/,'')+']' }.join("\n ")}
[[概要]]
[[内容]]
[[コメント]]
[http://dl.acm.org/exportformats.cfm?id=#{@id}&expformat=bibtex BibTeX] [http://dl.acm.org/citation.cfm?id=#{@id} ACM]
EOF
  end
end

class NIIBib < Bib
  def initialize(niistring)
    super()
    niistring =~ /(\d+)/
    @naid = $1
    server = 'ci.nii.ac.jp'
    command = "/naid/#{@naid}.bix"
    refer = get(server,command)
    parse(refer)
  end

  def wikititle
    "#{@data['A'][0]}: #{@data['T'][0]}"
  end

  def wikibody
    if @data['0'][0] == 'Journal Article' then
      <<EOF
[[タイトル]]
 #{@data['T'][0]}
[[ソース]]
 #{@data['J'][0]}
[[巻]]
 #{@data['V'][0]}
[[号]]
 #{@data['N'][0]}
[[ページ]]
 #{@data['P'][0]}
[[年]]
 #{@data['D'][0]}
[[著者]]
 #{@data['A'].collect { |a| '['+a+']' }.join("\n ")}
[[概要]]
[[内容]]
[[コメント]]
[http://ci.nii.ac.jp/naid/#{@naid}.bib BibTeX] [http://ci.nii.ac.jp/naid/#{@naid} CiNii]
EOF
    end
  end
end

if $0 == __FILE__ then
  DOI = '1124831'
  acmbib = ACMBib.new(DOI)
  puts acmbib.wikibody
end
