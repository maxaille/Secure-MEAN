@App = angular.module 'MyApp', ['ui.router']
API = location.origin

App.config [
    '$stateProvider'
    '$urlRouterProvider'
    ($stateProvider, $urlRouterProvider) ->
        $urlRouterProvider.otherwise '/'

        $stateProvider
        .state 'start',
            url: '/'
            title: 'start'
            controller: 'startCtrl'
            templateUrl: '/partials/start.html'

        .state 'login',
            url: '/login'
            controller: 'loginCtrl'
            title: 'login'
            templateUrl: '/partials/login.html'
            params: user: null


        .state 'register',
            url: '/register'
            controller: 'registerCtrl'
            title: 'register'
            templateUrl: '/partials/register.html'
]

App.factory 'authInterceptor', [
    'auth'
    (auth) ->
        request: (config) ->
            token = auth.getToken()
            if config.url.indexOf('/') != 0 and new URL(config.url).pathname.indexOf(new URL(API).pathname) == 0 and token
                config.headers.Authorization = 'Bearer ' + token
            return config;
        response: (res) ->
            if res.config.url.indexOf(API) == 0 and typeof res.data.token != 'undefined'
                auth.saveToken res.data.token
            return res
]

App.config [
    '$httpProvider'
    ($httpProvider) ->
        $httpProvider.interceptors.push 'authInterceptor'
]

App.service 'auth', [
    '$window'
    ($window) ->
        parseJwt: (token) =>
            base64Url = token.split('.')[1];
            base64 = base64Url.replace('-', '+').replace '_', '/'
            return JSON.parse $window.atob base64
        saveToken: (token) =>
            $window.localStorage['jwtToken'] = token
        getToken: =>
            return $window.localStorage['jwtToken']
        isAuthed: =>
            token = this.getToken()
            if token
                params = this.parseJwt token
                return Math.round(new Date().getTime() / 1000) <= params.exp
            else return false
]

App.controller 'startCtrl', [
    '$scope'
    ($scope) ->

]

App.controller 'loginCtrl', [
    '$rootScope'
    '$scope'
    '$http'
    '$stateParams'
    ($rootScope, $scope, $http, $stateParams) ->
        sendLogin = (user) ->
            return $http.post API + '/login', user
            .success (data) ->
                $rootScope.user = data

        $scope.validate = (form) ->
            # Use 'form' for checking fields
            # todo: hash password
            sendLogin username: $scope.username, password: $scope.password
            .success (data) ->
                console.log data
            .error (data) ->
                console.log data

        if $stateParams.user
            sendLogin $stateParams.user
            .success ->
                console.log 'ok'
            .error ->
                console.log 'nok'
]

App.controller 'registerCtrl', [
    '$rootScope'
    '$scope'
    '$http'
    '$state'
    ($rootScope, $scope, $http, $state) ->
        $scope.validate = ->
            if $scope.password != $scope.passwordRepeat then return
            $http.post API + '/register', {username: $scope.username, password: $scope.password}
            .success (data) ->
                $state.go 'login', user: username: $scope.username, password: $scope.password
                console.log data
            .error (data) ->
                console.log data
]

App.run [
    '$rootScope'
    '$state'
    '$http'
    'auth'
    ($rootScope, $state, $http, auth) ->
        $rootScope.title = $state.current.title
        $rootScope.$http = $http

        $http.get API + '/secure'
        .success (data) ->
            $rootScope.https_api = data
        .error (data) ->
            console.log data

        if auth.getToken()
            console.log auth.parseJwt auth.getToken()

]