context = cubism.context()
    .step(1e4)
    .size(960)

getThing = (name, selector) ->
  context.metric( (start,stop,step,callback)->
    url = "/metric?selector=#{selector}&start=#{start}&stop=#{stop}&step=#{step}"
    d3.json url, (data) ->
      return callback(new Error('could not load data')) unless data
      callback(null, data)

  , name)



$.getJSON('/queries', (data) ->
  console.log(data)
  $ -> _.each(data, (it) -> $('#queries').append("<li><em>#{it.calls}c, #{it.total_time}ms</em> #{it.query}</li>"))
)

$ ->
  d3.select("#cubism").selectAll(".axis")
      .data(["top", "bottom"])
      .enter().append("div")
      .attr("class", (d)-> return d + " axis" )
      .each((d) -> d3.select(this).call(context.axis().ticks(12).orient(d)))

  d3.select("#cubism").append("div")
      .attr("class", "rule")
      .call(context.rule())

  d3.select("#cubism").selectAll(".horizon")
      .data([
        getThing('conn count'     , 'connections') ,
        getThing('cache hit'      , 'cache_hit')   ,
        getThing('SELECT (count)' , 'select')      ,
        getThing('SELECT (ms)'    , 'select_ms')   ,
        getThing('UPDATE (count)' , 'update')      ,
        getThing('UPDATE (ms)'    , 'update_ms')   ,
        getThing('INSERT (count)' , 'insert')      ,
        getThing('INSERT (ms)'    , 'insert_ms')   ,
        getThing('locks'          , 'locks')       ,
        getThing('voodoo query (ms)', 'query_1')   ,
       ])
      .enter().insert("div", ".bottom")
      .attr("class", "horizon")
      .call(context.horizon().height(60)) #.extent([0, 15]))

  context.on("focus", (i) ->
    d3.selectAll(".value").style("right", i == null ? null : context.size() - i + "px")
  )




