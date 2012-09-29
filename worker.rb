require './lib/stat_collector'

loop do
  puts StatCollector.capture_stats!
  StatCollector.reset_target_stats!
  $stdout.flush
  sleep(ENV['PEROID']  ? ENV['PEROID'].to_i : 10)
end

