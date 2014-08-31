express = require 'express'
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

    router = express.Router()

    app.use '/', router

    router.get '/quests', (request, response) ->
        response.send [{"name": "q1"}, {"name": "q2"}]

    router.param 'quest_id', (req, res, next, id) ->
        client.query 'select * from quest where id = $1', [id], (err, result) ->
            if err
                console.error err
            if result.rows.length
                req.quest_id = id
                req.quest = result.rows[0]
            next()

    router.post '/quest', (request, response) ->
        console.log request.body
        client.query 'insert into quest (name, start_date) values ($1,localtimestamp)', [request.body.name]
        response.send "ok"

    router.get '/quest/:quest_id', (request, response) ->
        response.send request.quest

    router.post '/mark/:quest_id', (request, response) ->
        client.query 'insert into daily_mark (quest,date) values ($1,localtimestamp)', [request.quest_id]
        response.send "ok"

    app.listen (app.get 'port'), () ->
        console.log "started; port = " + app.get('port')
