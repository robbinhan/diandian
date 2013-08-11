require 'rubygems'
require 'nokogiri'
require 'time'
require 'date'
link = "http://robbinhan.logdown.com/";
creator = "robbinhan"
pub_date = Time.now.rfc2822
date_time = DateTime.parse(pub_date.to_s)
post_date = date_time.strftime("%F %T %z")
post_type = "post"
post_name = 1
status = "publish"

xml = IO.read("diandian.xml")
xml = Nokogiri::XML xml
items = Hash.new
xml.xpath("//Post").each do |node|
  item = Hash.new
  item["content"] ||= node.xpath(".//Text").inner_text
  item['title']   ||= node.xpath(".//Title").inner_text
  item['post_name'] ||= post_name
  items[post_name.to_i] ||= item
  post_name += 1
end

builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
  xml.rss('xmlns:excerpt'=>'http://wordpress.org/export/1.2/excerpt/', 'xmlns:content' => 'http://purl.org/rss/1.0/modules/content/',
          'xmlns:dc' => 'http://purl.org/dc/elements/1.1/', 'xmlns:wp' => 'http://wordpress.org/export/1.2/',
          'version'=>'2.0') {
    xml.channel{
      xml.title creator
      xml.link link
      xml.description ""
      xml.pubdate pub_date
      xml['wp'].wxr_version 1.2
      xml['wp'].base_site_url link
      xml['wp'].base_blog_url link
      xml.generator creator
      items.each do |key,item_hash|
        xml.item{
          xml.title item_hash["title"].empty? ? "No Title" : item_hash["title"];
          xml.link link
          xml.pubDate pub_date
          xml['dc'].creator creator
          xml['content'].encoded{
           xml.cdata(item_hash['content'])
          }
          xml['wp'].post_date post_date
          xml['wp'].post_type post_type
          xml['wp'].post_name item_hash['post_name']
          xml['wp'].status status
        }
      end
    }
  }
end

f1 = File.new("./diandian_convert.xml","w");
f1.puts builder.to_xml
