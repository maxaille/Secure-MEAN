@App = angular.module 'MyApp', ['ui.router']
API = location.origin
HTTPS_API = location.origin # replaced with the good https url in the angular.run

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
            # Request to an API subroute, add token in headers
            if config.url.indexOf(HTTPS_API) == 0 and new URL(config.url).pathname.indexOf(new URL(API).pathname) == 0 and token
                config.headers.Authorization = 'Bearer ' + token
            return config;
        response: (res) ->
            if res.config.url.indexOf(HTTPS_API) == 0 and typeof res.data.token != 'undefined'
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
    '$rootScope'
    ($window, $rootScope) ->
        auth =
            parseJwt: (token) =>
                base64Url = token.split('.')[1];
                base64 = base64Url.replace('-', '+').replace '_', '/'
                return JSON.parse $window.atob base64
            saveToken: (token) =>
                $window.localStorage['jwtToken'] = token
                exp = auth.parseJwt(token).exp * 1000
                $rootScope.timerExpiration = setTimeout ->
                    $rootScope.$broadcast 'user:expired'
                , exp - Date.now()
            getToken: =>
                return $window.localStorage['jwtToken']
            isAuthed: =>
                token = auth.getToken()
                if token
                    params = auth.parseJwt token
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
    '$state'
    '$stateParams'
    ($rootScope, $scope, $http, $state, $stateParams) ->
        sendLogin = (user) ->
            return $http.post HTTPS_API + '/login', user
            .success (data) ->
                $rootScope.user = data

        $scope.validate = (form) ->
            # Use 'form' for checking fields
            # todo: hash password
            sendLogin username: $scope.username, password: $scope.password
            .success (data) ->
                $state.go 'start'
            .error (data) ->
                console.log data

        if $stateParams.user
            sendLogin $stateParams.user
            .success ->
                $state.go 'start'
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
            $http.post API + '/api/users', {username: $scope.username, password: $scope.password}
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
    '$window'
    ($rootScope, $state, $http, auth, $window) ->
        $rootScope.title = $state.current.title
        $rootScope.$http = $http
        $rootScope.$window = $window
        $rootScope.$state = $state
        $rootScope.auth = auth

        $http.get '/secure'
        .success (data) ->
            port = data.port
            HTTPS_API = 'https://' + location.hostname + if port == 443 then '' else ':' + port
        .error (data) ->
            throw data

        if token = auth.getToken()
            exp = auth.parseJwt(token).exp * 1000
            $rootScope.timerExpiration = setTimeout ->
                $rootScope.$broadcast 'user:expired'
            , exp - Date.now()

        $rootScope.$on 'user:expired', ->
            console.log 'expired'
]