require 'sinatra'
require 'sequel'
require 'json'
DB = Sequel.connect ENV['DATABASE_URL']

class Datascope < Sinatra::Application
  get '/' do
    haml :index
  end

  get '/metric' do
    selector =  params[:selector]
    start = DateTime.parse params[:start]
    stop = DateTime.parse params[:stop]
    step = params[:step].to_i

    results = DB[:stats].select(:data).filter(created_at: (start..stop)).all
    JSON.dump results.map{|row| JSON.parse(row[:data])[selector]}
  end

end
