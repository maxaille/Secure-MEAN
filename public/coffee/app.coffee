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
            params: user: null, oldState: null

        .state 'register',
            url: '/register'
            controller: 'registerCtrl'
            title: 'register'
            templateUrl: '/partials/register.html'

        .state 'secret',
            url: '/secret'
            controller: 'secretCtrl'
            title: 'secret zone'
            templateUrl: '/partials/secret.html'
            secured: true
]

App.factory 'authInterceptor', [
    '$token'
    ($token) ->
        request: (config) ->
            token = $token.getToken()
            # Request to an API subroute, add token in headers
            if config.url.indexOf(HTTPS_API) == 0 and new URL(config.url).pathname.indexOf(new URL(API).pathname) == 0 and token
                config.headers.Authorization = 'Bearer ' + token
            return config;
        response: (res) ->
            if res.config.url.indexOf(HTTPS_API) == 0 and typeof res.data.token != 'undefined'
                $token.saveToken res.data.token
            return res
]

App.config [
    '$httpProvider'
    ($httpProvider) ->
        $httpProvider.interceptors.push 'authInterceptor'
]

App.service '$token', [
    '$window'
    '$rootScope'
    '$timeout'
    ($window, $rootScope, $timeout) ->
        $token =
            parseJwt: (token) =>
                base64Url = token.split('.')[1];
                base64 = base64Url.replace('-', '+').replace '_', '/'
                return JSON.parse $window.atob base64
            saveToken: (token) =>
                if $token.isValid token
                    $window.localStorage['jwtToken'] = token
                else return false
            getToken: =>
                return $window.localStorage['jwtToken']
            removeToken: =>
                return delete $window.localStorage['jwtToken']
            isValid: (token) =>
                if token
                    parsed = $token.parseJwt token
                    return Math.round(Date.now() / 1000) < parsed.exp
                else return false
]

App.controller 'startCtrl', [
    '$rootScope'
    '$scope'
    ($rootScope, $scope) ->
]

App.controller 'secretCtrl', [
    '$rootScope'
    '$scope'
    ($rootScope, $scope) ->
]

App.controller 'loginCtrl', [
    '$rootScope'
    '$scope'
    '$http'
    '$state'
    '$stateParams'
    '$timeout'
    ($rootScope, $scope, $http, $state, $stateParams, $timeout) ->
        sendLogin = (user) ->
            $http.post HTTPS_API + '/login', user
            .success (data) ->
                $rootScope.$broadcast 'user:loggedin', user: data.user, exp: data.exp*1000

        $scope.validate = (form) ->
            # Use 'form' for checking fields
            sendLogin username: $scope.username, password: $scope.password
            .success (data) ->
                $state.go if $stateParams.oldState then $stateParams.oldState.name else 'start'
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
            $http.post HTTPS_API + '/api/users', username: $scope.username, password: $scope.password, email: $scope.email
            .success (data) ->
                $state.go 'login', user: username: $scope.username, password: $scope.password
                console.log data
            .error (data) ->
                console.log data
]

App.run [
    '$rootScope'
    '$state'
    '$location'
    '$http'
    '$token'
    '$window'
    '$timeout'
    ($rootScope, $state, $location, $http, $token, $window, $timeout) ->
        $rootScope.title = $state.current.title
        $rootScope.$http = $http
        $rootScope.$window = $window
        $rootScope.$state = $state
        $rootScope.auth = $token

        $rootScope.user = null

        # Get the HTTPS url for secured request
        $http.get '/secure'
        .success (data) ->
            port = data.port
            HTTPS_API = 'https://' + location.hostname + if port == 443 then '' else ':' + port
        .error (data) ->
            throw data

        # Bind some events...
        $rootScope.$on 'user:loggedin', (e, data) ->
            $rootScope.user = data.user

            $rootScope.timerExpiration = $timeout ->
                $rootScope.$broadcast 'user:disconnected'
            , data.exp - Date.now()
            console.log 'User logged in'

        $rootScope.$on 'user:disconnected', ->
            $rootScope.user = null
            # redirect to login if secured state when token expire, saving the old state
            if $state.current.secured == true
                $state.go 'login', oldState: $state.current
            console.log 'User got disconnected'


        # if valid token, request the user from the server
        if token = $token.getToken()
            parsed = $token.parseJwt token
            exp = parsed.exp * 1000
            if $token.isValid(token) and exp - Date.now() > 0
                $http.get HTTPS_API + '/api/users/' + parsed.id
                .success (user) ->
                    $rootScope.$broadcast 'user:loggedin', user: user, exp: exp
                .error ->
                    console.log 'invalid user ?'
            else $token.removeToken

        # Check for secured states
        $rootScope.$on '$stateChangeStart', (e, toState, toParams, fromState, fromParams) ->
            if !$rootScope.user and toState.secured
                e.preventDefault()
                if fromState.name
                    console.log 'redirecting...'
                    return $state.go 'start'
]