require 'sequel'
DB = Sequel.connect ENV['TARGET_DB']

loop do
  puts 'work'

  $stdout.flush
  sleep(ENV['PEROID']  ? ENV['PEROID'].to_i : 10)
end
