
#config angular module
app = window.angular.module 'jTester', ['ui.bootstrap' , 'ngRoute']
app.templateUrls =
  http : "./app/views/http.html"
  alert : "./app/views/alert.html"
  upload : "./app/views/upload.html"
  json : "./app/views/json.html"
  help : "./app/views/help.html"
  about : "./app/views/about.html"

app.config(($routeProvider , $locationProvider , $compileProvider) ->
  $routeProvider.when('/http', {templateUrl: app.templateUrls.http , controller: 'HttpCtrl'})
  $routeProvider.when('/json', {templateUrl: app.templateUrls.json, controller:'JsonCtrl' })
  $routeProvider.when('/help', {templateUrl: app.templateUrls.help, controller: ($scope)-> })
  $routeProvider.otherwise({redirectTo: '/http'})
  #configure html5 to get links working on node-webkit
  $locationProvider.html5Mode {
    enabled: true
    requireBase: false
  }
  #href unsafe solution
  $compileProvider.aHrefSanitizationWhitelist(/^\s*(app):/);
)

#export module app
window.jTester.app = app
