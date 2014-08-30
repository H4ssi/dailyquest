module.exports = (grunt) ->
    grunt.initConfig {
        pkg: grunt.file.readJSON 'package.json'
        env:
            localBinPath:
                concat:
                    PATH:
                        value: 'grunt_bin'
                        delimiter: ':'
        coffee:
            clientScripts:
                files: [{
                    expand: true
                    src:  'public/**/*.coffee'
                    dest: './'
                    ext:  '.js' }]
        haml:
            clientHtml:
                files: (grunt.file.expandMapping ['public/**/*.haml'], './', {
                    rename: (base, path) ->
                        return base + (path.replace /\.haml$/, '.html') })
                options:
                    language: 'ruby'
        express:
            heroku:
                options:
                    script: 'index.coffee'
                    background: false
        watch:
            watchClientScripts:
                files: ['public/**/*.coffee']
                tasks: ['coffee:clientScripts']
            watchClientHtml:
                files: ['public/**/*.haml']
                tasks: ['haml:clientHtml']
    }

    grunt.loadNpmTasks 'grunt-env'
    grunt.loadNpmTasks 'grunt-express-server'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-haml'
    grunt.loadNpmTasks 'grunt-contrib-watch'

    grunt.registerTask 'default', ['env:localBinPath', 'coffee', 'haml']
    grunt.registerTask 'heroku',  ['default', 'express:heroku']
