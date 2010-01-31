require 'yaml'
require 'fileutils'

def file_for(name)
  File.join("data", name.downcase.gsub(/[^0-9a-z]/, "-") + ".html")
end

def htmlify(text)
  text.gsub(/&/) { "&amp;" }.
       gsub(/</) { "&lt;" }.
       gsub(/>/) { "&gt;" }
end

def autolink(text)
  htmlify(text).gsub(/\[\[(.*?)\]\]/) do
    target = $1
    if DATA[target]
      "<a href='#{file_for($1)}'>#{target}</a>"
    else
      warn "no such figure #{target.inspect}"
      target
    end
  end
end

DATA = YAML.load_file(File.join(File.dirname(__FILE__), "..", "data", "figs.yml"))
NAMES = DATA.keys.sort_by { |name| name.downcase.sub(/^(a|an|the)\s+/, "") }

FileUtils.mkdir_p("public/data")

File.open("public/data/contents.html", "w") do |f|
  f.puts "<div id='content'>"
  f.puts "<ul>"
  NAMES.each do |name|
    f.puts "<li><a href='#{file_for(name)}'>#{name}</a></li>"
  end
  f.puts "</ul>"
  f.puts "</div>"
end

NAMES.each do |name|
  File.open("public/#{file_for(name)}", "w") do |f|
    f.puts "<div id='content'>"
    f.puts "<h2>#{name}</h2>"
    start = DATA[name]["start"]
    f.puts "<ol start='#{start ? '0' : '1'}'>"
    f.puts "<li><span class='idx'>0</span> <div class='step'>#{htmlify(start)}</div></li>" if start
    index = 1
    DATA[name]['steps'].each do |step|
      instruction = step.is_a?(String) ? step : step['step']
      comment = step.is_a?(String) ? nil : step['comment']
      figure = step.is_a?(String) ? nil : step['figure']

      f.print "<li><div class='idx'"
      f.print " style='visibility: hidden'" if instruction.nil?
      f.print ">#{index}</div> "
      f.print "<div class='step'>"

      if instruction
        f.print(htmlify(instruction))
        index += 1
      end

      f.print " <span class='comment'>(#{autolink(comment)})</span>" if comment
      f.print " <span class='figure'>[#{autolink(figure)}]</span>" if figure

      f.print "</div>"
      f.puts '</li>'
    end
    f.puts "</ol>"
    f.puts "</div>"
  end
end
