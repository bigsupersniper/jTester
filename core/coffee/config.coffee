#root path
__apppath = "./core"

#import jTester namespace
jTester = window.jTester
__fs = jTester.require.fs

#all views path
views =
  index : __apppath + "/views/index.html"
  help : __apppath + "/views/help.html"
  about : __apppath + "/views/about.html"
  config : __apppath + "/views/config.html"
  globalitem : __apppath + "/views/globalitem.html"
  alert : __apppath + "/views/alert.html"
  uploadfile : __apppath + "/views/uploadfile.html"
  savefile : __apppath + "/views/savefile.html"
  downloadlist : __apppath + "/views/downloadlist.html"

#config angular module
window.angularapp = window.angular.module 'jTester', ['ui.bootstrap' , 'angularFileUpload' , 'ngRoute']
window.angularapp.config(($routeProvider , $locationProvider) ->
  $routeProvider.when('/index', {templateUrl: views.index, controller: 'IndexPartCtrl'})
  $routeProvider.when('/help', {templateUrl: views.index, controller: ($scope, $modal) ->
    $modal.open {
      templateUrl: views.help
      backdrop: 'center'
      controller: ($scope)->
    }
  })
  $routeProvider.when('/socket', {templateUrl: views.socket, controller: ($scope)-> })
  $routeProvider.otherwise({redirectTo: '/index'})
  #configure html5 to get links working on node-webkit
  $locationProvider.html5Mode(true)
)

#config
config =
  baseitems :
    address : ''
    savefilepath : ''
    testfile : ''
    headers : {}
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
    if !config.baseitems
      config.baseitems = {}
  if !__fs.existsSync config.baseitems.savefilepath
    if !__fs.existsSync "D:\\"
      config.baseitems.savefilepath = "C:\\"
    else
      config.baseitems.savefilepath = "D:\\"
    #save config
    config.save(config)
  if !config.baseitems.testfile || !__fs.existsSync config.baseitems.testfile
    config.baseitems.testfile =  './coffee/test/default.coffee'
    if !config.baseitems.headers
      config.baseitems.headers = {}
    if !config.globalitems
      config.globalitems = {}
    #save config
    config.save(config)
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
#file or alert can't ref
window.jTester.file = {}
window.jTester.alert = {}