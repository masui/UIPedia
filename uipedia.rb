# -*- coding: utf-8 -*-
# -*- ruby -*-
#

require 'cgi'
require 'sinatra'
# require 'sinatra/cross_origin'
# require 'json'

require './bibconv'

# enable :cross_origin

get '/index.html' do
  'UIPedia'
end

get /\/(http.*)/ do |url|
  url = CGI.unescape(url)
  bib = nil
  if url =~ /dl\.acm/ then
    bib = ACMBib.new(url)
  elsif url =~ /ci\.nii\.ac\.jp/ then
    bib = NIIBib.new(url)
  end
  if bib
    title = bib.wikititle
    body = bib.wikibody
    redirect "https://scrapbox.io/UIPedia/#{CGI.unescape_html(title)}?body=#{CGI.escape(CGI.unescape_html(body))}"
  end
end
