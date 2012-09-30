context = cubism.context()
    .step(1e4)
    .size(960)

getThing = (name, selector) ->
  context.metric( (start,stop,step,callback)->
    url = "/metric?selector=#{selector}&start=#{start}&stop=#{stop}&step=#{step}"
    d3.json url, (data) ->
      return callback(new Error('could not load data')) unless data
      callback(null, data)

  , selector)

$ ->
  d3.select("body").selectAll(".axis")
      .data(["top", "bottom"])
      .enter().append("div")
      .attr("class", (d)-> return d + " axis" )
      .each((d) -> d3.select(this).call(context.axis().ticks(12).orient(d)))

  d3.select("body").append("div")
      .attr("class", "rule")
      .call(context.rule())

  d3.select("body").selectAll(".horizon")
      .data([
        getThing('conn count', 'connections'),
        getThing('cache hit', 'cache_hit')
       ])
      .enter().insert("div", ".bottom")
      .attr("class", "horizon")
      .call(context.horizon()) #.extent([0, 15]))

  context.on("focus", (i) ->
    d3.selectAll(".value").style("right", i == null ? null : context.size() - i + "px")
  )




