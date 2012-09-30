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
    parsed = results.map{|row| JSON.parse(row[:data])}

    if selector == 'query_1'
      query = "SELECT * FROM \"aws_instances\" WHERE (\"id\" = ?) LIMIT ?"
      stat_statements = parsed.map{|row| row['stat_statements'].find{|h| h['query'] == query }}
      values = stat_statements.map{|h| h ? h['total_time'].to_f/h['calls'].to_f : 0}
    elsif selector == 'select'
      values = values_by_regex parsed, /select/i
    elsif selector == 'select_ms'
      values = values_by_regex parsed, /select/i, :ms
    elsif selector == 'update'
      values = values_by_regex parsed, /update/i
    elsif selector == 'update_ms'
      values = values_by_regex parsed, /update/i, :ms
    elsif selector == 'insert'
      values = values_by_regex parsed, /insert/i
    elsif selector == 'insert_ms'
      values = values_by_regex parsed, /insert/i, :ms
    elsif selector == 'delete'
      values = values_by_regex parsed, /delete/i
    else
      values = parsed.map{|d| d[selector] }
    end

    JSON.dump values
  end

  def values_by_regex(parsed, regex, ms=false)
    stat_statements = parsed.map{|row| row['stat_statements'].find{|h| h['query'] =~ regex }}
    values = stat_statements.map do |h|
      if h
        if ms
          h['total_time'].to_f/h['calls'].to_f
        else
          h['calls']
        end
      else
        0
      end
    end
  end

end
