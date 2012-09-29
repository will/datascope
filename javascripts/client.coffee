getStats = (callback) -> $.getJSON('/stats.json', callback)

history = []

ensureHistory = (callback) ->
  if history.length == 0
    $.getJSON '/history.json', (d) ->
      history = d
      _.each history, (it) -> it.time = Date.parse(it.time)
      callback()
  else
    callback()

update = ->
  getStats (d) ->
    console.log(d)
    d.time = Date.parse(d.time)
    history.push d
    render(d)
    setTimeout(update, 10000)

render = (data) ->
  $('#connections .count').text(data.connections)
  window.last = data.connections

dateRangeScale = (list, start, stop, size) ->
  ranged = _.select( list, (it) -> it.time >= start && it.time <= stop )
  #console.log('overall list', list)
  #console.log('ranged', ranged)
  origSize = ranged.length
  d3.range(0,size).map( (i) -> ranged[Math.floor( i*origSize/size )] )

context = cubism.context()
    .step(1e3)
    .size(960)

getThing = (name, selector) ->
  context.metric( (start,stop,step,callback)->
    ensureHistory ->
      astart = +start
      astop = +stop
      size = (astop-astart)/step

      data = dateRangeScale(history,start,stop,size)

      values = _.map(data, (it) -> it?[selector])
      console.log(selector, 'values', values)
      callback(null, values)
  , name)

$ ->
  update()

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




