contents = []
Dir.chdir(File.join(File.dirname(__FILE__), "..", "public")) do
  Dir["**/**"].each do |item|
    next if File.directory?(item)
    contents << item
  end
end

File.open("cache.manifest", "w") do |f|
  f.puts "CACHE MANIFEST"
  f.puts(contents.sort)
end
