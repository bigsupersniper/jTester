#root path
__apppath = "./core"

#import jTester namespace
jTester = window.jTester
__fs = jTester.require.fs

#all views path
views =
  http : __apppath + "/views/http.html"
  alert : __apppath + "/views/alert.html"
  uploadfile : __apppath + "/views/uploadfile.html"
  savefile : __apppath + "/views/savefile.html"
  downloadlist : __apppath + "/views/downloadlist.html"
  json : __apppath + "/views/json.html"
  help : __apppath + "/views/help.html"
  about : __apppath + "/views/about.html"

#config angular module
window.angularapp = window.angular.module 'jTester', ['ui.bootstrap' , 'angularFileUpload' , 'ngRoute']
window.angularapp.config(($routeProvider , $locationProvider , $compileProvider) ->
  $routeProvider.when('/http', {templateUrl: views.http, controller: 'HttpCtrl'})
  $routeProvider.when('/downloads', {templateUrl: views.downloadlist, controller:'DownlistCtrl' })
  $routeProvider.when('/json', {templateUrl: views.json, controller:'JsonCtrl' })
  $routeProvider.when('/help', {templateUrl: views.help, controller: ($scope)-> })
  $routeProvider.otherwise({redirectTo: '/http'})
  #configure html5 to get links working on node-webkit
  $locationProvider.html5Mode(true)
  #href unsafe solution
  $compileProvider.aHrefSanitizationWhitelist(/^\s*(app):/);
)

#config
config =
  httpconfig :
    host : ''
    savefilepath : ''
    testfile : ''
    items : {}
  globalitems : {}
  save : (cfg)->
    try
      cfg = cfg || window.jTester.config
      jsonstring = JSON.stringify cfg
      __fs.writeFileSync __apppath + '/config.json' , jsonstring , { encoding : "utf-8" }
    catch e
      window.alert e.message

#load config.json file
try
  jsonstring = __fs.readFileSync __apppath + '/config.json' , { encoding : "utf-8" }
  if jsonstring
    _config = JSON.parse jsonstring
    _config.save = config.save
    config = _config
    if !config.httpconfig
      config.httpconfig = {}
  if !__fs.existsSync config.httpconfig.savefilepath
    if !__fs.existsSync "D:\\"
      config.httpconfig.savefilepath = "C:\\"
    else
      config.httpconfig.savefilepath = "D:\\"
    #save config
    config.save(config)

  if !config.httpconfig.testfile || !__fs.existsSync config.httpconfig.testfile
    config.httpconfig.testfile =  './coffee/test/default.coffee'
    #save config
    config.save(config)
  if !config.socketconfig
    config.socketconfig = {}
  if !config.globalitems
    config.globalitems = {}
catch e
  window.alert e.message

#download
download =
  history : []
  save : ()->
    try
      jsonstring = JSON.stringify window.jTester.download
      __fs.writeFileSync __apppath + '/download.json' , jsonstring , { encoding : "utf-8" }
    catch e
      window.alert e.message

#load download.json file
try
  jsonstring = __fs.readFileSync __apppath + '/download.json' , { encoding : "utf-8" }
  if jsonstring
    obj = JSON.parse jsonstring
    download.history = obj.history
catch e
  window.alert e.message

#output
window.jTester.views = views
window.jTester.config = config
window.jTester.download = download
window.jTester.cache = {}
#file or alert can't ref
window.jTester.file = {}
window.jTester.alert = {}