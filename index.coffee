falcorExpress = require 'falcor-express'
bodyParser = require 'body-parser'
Router = require 'falcor-router'
express = require 'express'
pg = require 'pg'
rx = require 'rx'

pg.connect process.env.DATABASE_URL || 'postgres://dailyquest:dailyquest@localhost/dailyquest', (err, client, done) ->
  if err
    return console.error 'error connecting to pg', err

  app = express()
  app.set 'port', process.env.PORT || 3000

  app.use bodyParser.text({type: 'text/*'})
  app.use bodyParser.urlencoded({type: 'application/x-www-form-urlencoded', extended: true})
  app.use (express.static __dirname + '/public')
  app.use '/bower_components', (express.static __dirname + '/bower_components')

  app.use '/dailyquest.json', falcorExpress.dataSourceRoute(
    (req, res) ->
      new Router([
        {
          route: 'quest[{ranges:ids}].name'
          get: (pathSet) -> all().map((r) -> {path: ['quest', r.id, 'name'], value: r.name})
        }
        {
          route: 'add'
          call: (callPath, args) ->
            [name] = args
            add(name).map((r) -> {path: ['quest', r.id, 'name'], value: r.name})
        }]))

  pgrx = (query) ->
    rx.Observable.create((o) ->
      query.on('row', (r) -> o.onNext(r))
      query.on('end', () -> o.onCompleted()))

  byId = (id) -> pgrx(client.query('select id, name from quest where id = $1', [id]))
  all = () -> pgrx(client.query('select id, name from quest'))
  add = (name) -> pgrx(client.query('insert into quest (name, start_date) values ($1,localtimestamp) returning id, name', [name]))

  mark = (req, res) ->
      client.query 'select id, date from daily_mark where quest = $1 order by date', [req.quest.id], (err, pgres) ->
        res.send pgres.rows
  create = (req, res) ->
      client.query 'insert into daily_mark (quest,date) values ($1,localtimestamp) returning id, date', [req.quest.id], (err, pgres) ->
        res.send pgres.rows[0]

  app.listen (app.get 'port'), () ->
    console.log "started; port = " + app.get('port')
