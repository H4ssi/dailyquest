express = require 'express'
bodyParser = require 'body-parser'
pg = require 'pg'

pg.connect process.env.DATABASE_URL || 'postgres://florian:florian@localhost/dailyquest', (err, client, done) ->
    if err
        return console.error 'error connecting to pg', err

    app = express()
    app.set 'port', process.env.PORT || 5000
    app.use (express.static __dirname + '/public')
    app.use bodyParser.json()

    router = express.Router()

    app.use '/', router

    router.get '/', (request, response) ->
        response.send '/'

    router.get '/quests', (request, response) ->
        response.send 'test'

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
        lient.query 'insert into quest (name, start_date) values ($1,localtimestamp)', [request.body.name]
        response.send "ok"

    router.get '/quest/:quest_id', (request, response) ->
        response.send request.quest

    app.listen (app.get 'port'), () ->
        console.log "started; port = " + app.get('port')
