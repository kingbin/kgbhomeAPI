require './lib/kgbhomeAPI'

log = File.new("logs/sinatra.log", "a")
STDOUT.reopen(log)
STDERR.reopen(log)

run KGBHomeAPI::App
