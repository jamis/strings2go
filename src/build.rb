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

def emit_step(f, index, step)
  instruction = step.is_a?(String) ? step : step['step']
  comment = step.is_a?(String) ? nil : step['comment']
  figure = step.is_a?(String) ? nil : step['figure']
  dup = step.is_a?(String) ? nil : step['dup']

  f.print "<li"
  if figure
    f.print " class='figure'"
  elsif dup
    f.print " class='dup'"
  end
  f.print "><div class='idx'"
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

  return index
end

DATA = YAML.load_file(File.join(File.dirname(__FILE__), "..", "data", "figs.yml"))
NAMES = DATA.keys.sort_by { |name| name.downcase.sub(/^(a|an|the)\s+/, "") }

FileUtils.mkdir_p("public/data")

puts "database contains #{DATA.length} figures"

File.open("public/data/contents.html", "w") do |f|
  f.puts "<div id='content'>"
  f.puts "<ul>"
  NAMES.each do |name|
    sort_name = name.sub(/^(a|an|the)\s+(.*)/i) { $2 + ", " + $1 }
    f.puts "<li><a href='#{file_for(name)}'>#{sort_name}</a></li>"
  end
  f.puts "</ul>"
  f.puts "</div>"
end

NAMES.each do |name|
  File.open("public/#{file_for(name)}", "w") do |f|
    f.puts "<div id='content'>"
    f.puts "<h2>#{name}</h2>"
    start = DATA[name]["start"]
    f.puts "<ol>"
    index = start ? emit_step(f, 0, start) : 1
    DATA[name]['steps'].each do |step|
      index = emit_step(f, index, step)
    end
    f.puts "</ol>"
    f.puts "</div>"
  end
end
