# Copyright Verizon Media. All rights reserved

require 'json'
require 'nokogiri'
require 'kramdown/parser/kramdown'

module Jekyll

    class VespaIndexGenerator < Jekyll::Generator
        priority :lowest

        def generate(site)
            namespace  = site.config["search"]["namespace"]
            noindex    = ["/redirects.json",
                          "/status.json",
                          "/css/denali-theme-vespa-light.css",
                          "/css/denali-theme-vespa.css",
                          "/css/style-light.css",
                          "/css/style.css"]
            operations = []

            site.pages.each do |page|
                if page.data["index"] == true && !noindex.include?(page.url)
                    operations.push({
                        :fields => {
                            :path => page.url,
                            :namespace => namespace,
                            :title => page.data["title"],
                            :content => extract_text(page)
                        }
                    })
                end
            end

            json = JSON.pretty_generate(operations)
            File.open(namespace + "_index.json", "w") { |f| f.write(json) }
        end

        def extract_text(page)
            ext = page.name[page.name.rindex('.')+1..-1]
            if ext == "md"
                input = Kramdown::Document.new(page.content).to_html
            else
                input = page.content
            end
            doc = Nokogiri::HTML(input)
            doc.search('th,td').each{ |e| e.after "\n" }
            content = doc.xpath("//text()").to_s
            page_text = content.gsub("\r"," ").gsub("\n"," ")
        end

    end

end
