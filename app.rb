require 'sinatra'
require 'sequel'
require 'json'
require 'uri'

class Datascope < Sinatra::Application
  get '/' do
    haml :index
  end

  get '/history.json' do
    time = Time.now - 2*60*60
    (0..120).map do |t|
      {
        time: time + t*60,
        connections: (12*t/160).to_i,
        cache_hit: 0.98
      }
    end.to_json
  end

  get '/stats.json' do
    {
      time: Time.now,
    }.to_json
  end



end
