require './lib/kgbhomeAPI'

log = File.new("log/sinatra.log", "a")
#STDOUT.reopen(log)
#STDERR.reopen(log)
$stdout.reopen(log)
$stderr.reopen(log)

run KGBHomeAPI::App
