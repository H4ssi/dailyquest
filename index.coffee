express = require 'express'
expressResource = require 'express-resource'
bodyParser = require 'body-parser'
pg = require 'pg'

pg.connect process.env.DATABASE_URL || 'postgres://florian:florian@localhost/dailyquest', (err, client, done) ->
  if err
    return console.error 'error connecting to pg', err

  app = express()
  app.set 'port', process.env.PORT || 3000
  app.use (express.static __dirname + '/public')
  app.use '/bower_components', (express.static __dirname + '/bower_components')
  app.use bodyParser.json()

  quest = app.resource 'quest',
    load: (id, next) ->
      client.query 'select id, name from quest where id = $1', [id], (err, result) ->
        if err
          next err, null
        else if result.rows.length != 1
          next "no such quest", null
        else
          next null, result.rows[0]
    index: (req, res) ->
      client.query 'select id, name from quest', (err, pgres) ->
        res.send pgres.rows
    create: (req, res) ->
      client.query 'insert into quest (name, start_date) values ($1,localtimestamp) returning id, name', [req.body.name], (err, pgres) ->
        res.send pgres.rows[0]
    update: (req, res) ->
      res.send "todo" # TODO
    show: (req, res) ->
      res.send req.quest

  mark = app.resource 'mark',
    index: (req, res) ->
      console.log req
      client.query 'select id, date from daily_mark where quest = $1 order by date', [req.quest.id], (err, pgres) ->
        res.send pgres.rows
    create: (req, res) ->
      client.query 'insert into daily_mark (quest,date) values ($1,localtimestamp) returning id, date', [req.quest.id], (err, pgres) ->
        res.send pgres.rows[0]

  quest.add mark

  app.listen (app.get 'port'), () ->
    console.log "started; port = " + app.get('port')
