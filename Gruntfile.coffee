module.exports = (grunt) ->
    grunt.loadNpmTasks('grunt-contrib-coffee')
    grunt.loadNpmTasks('grunt-contrib-jade')
    grunt.loadNpmTasks('grunt-contrib-sass')
    grunt.loadNpmTasks('grunt-contrib-watch')

    grunt.initConfig
        coffee:
            compile:
                options:
                    join: true
                files:
                    'public/build/js/app.js': ['public/coffee/app.coffee']
        sass:
            compile:
                options:
                    style: 'compressed'
                files: [
                    cwd: 'public/sass'
                    src: ['**/*.sass', '**/*.scss']
                    dest: 'public/build/css'
                    expand: false
                    ext: '.min.css'
                ]
        jade:
            compile:
                options:
                    client: false,
                    pretty: false
                files: [
                    cwd: 'public/jade'
                    src: '**/*.jade'
                    dest: 'public/build'
                    expand: true
                    ext: '.html'
                ]
        watch:
            coffee:
                files: ['public/**/*.coffee']
                tasks: ['coffee']
            jade:
                files: ['public/jade/**/*.jade']
                tasks: ['jade']
            sass:
                files: ['public/sass/**/*.sass']
                tasks: ['sass']