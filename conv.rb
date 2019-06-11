#
# S3にPDFをアゲてたものをACMへのリンクに修正
#
require 'json'

begin
  origdata = JSON.parse(File.read("UIPedia.json"))
rescue
  STDERR.puts "masui-photos.json not found"
  exit
end

jsondata = {}
pages = []
jsondata['pages'] = pages

origdata['pages'].each { |page|
  title = page['title']
  found = false
  acmid = nil
  page['lines'].each { |line|
    found = true if line =~ /masui\.org.*pdf/
    if line =~ /http:\/\/dl.acm.org\/citation.cfm\?id=(\d+) ACM/
      acmid = $1
    end
  }
  if found && acmid
    newpage = {}
    newpage['title'] = title
    newlines = []
    page['lines'].each { |line|
      if line =~ /^(.*)https?:\/\/masui\.org(\.s3.amazonaws.com\/.\/.)?\/\w+\.pdf(.*)$/
        line = "#{$1}https://dl.acm.org/ft_gateway.cfm?id=#{acmid}#{$3}"
      end
      newlines << line        
    }
    newpage['lines'] = newlines 
    pages << newpage
  end
}

puts jsondata.to_json
