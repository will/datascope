require 'sinatra'
require 'sequel'
require 'json'
require 'haml'
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
      values = values_by_regex parsed, /with packed/i, :ms
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

  get '/queries' do
    data = JSON.parse DB[:stats]
                        .select(:data)
                        .order_by(:id.desc)
                        .first[:data]
    JSON.dump data['stat_statements'].map{|s| s['query'] = s['query'][0..50]; s}.sort{|s| s['total_time']}.reverse
  end

  def values_by_regex(parsed, regex, ms=false)
    vals = parsed.map { |row|
      row['stat_statements']
        .select  {|h| h['query'] =~ regex }
        .sort_by {|h| h['total_time']}
        .inject([0,0]) { |m,h| [m.first + h['calls'].to_i, m.last + h['total_time'].to_f ] }
    }

    if ms
      vals.map {|pair| pair.first.zero? ? 0 : pair.last/pair.first}
    else
      vals.map(&:first)
    end
  end

end
