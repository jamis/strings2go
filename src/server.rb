require 'rubygems'
require 'mongrel'

h = Mongrel::HttpServer.new("0.0.0.0", "3001")
h.register("/", Mongrel::DirHandler.new("public"))
h.run.join
