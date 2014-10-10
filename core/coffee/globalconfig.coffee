#namespace
window.jTester = {}

#import reference
require = window.require

window.jTester.require =
  nw : require 'nw.gui'
  fs : require 'fs'
  path : require 'path'
  querystring : require 'querystring'
  url : require 'url'
  request : require './node_modules/request'
  uuid : require './node_modules/node-uuid'
  formdata : require './node_modules/request/node_modules/form-data'

#handle uncaughtException
process.on 'uncaughtException' , (err)->
  alert err.message

#config angular module
window.angularapp = angular.module 'jTester' , ['ui.bootstrap' , 'angularFileUpload']

#register .coffee extension
require './node_modules/coffee-script/register'

#require module by order
#global
require './coffee/config.coffee'
#utils
require './coffee/utils/utils.coffee'
#views
require './coffee/views/indexctrl.coffee'
require './coffee/views/configctrl.coffee'
require './coffee/views/globalitemctrl.coffee'
require './coffee/views/downlistctrl.coffee'
require './coffee/views/uploadfilectrl.coffee'
require './coffee/views/savefilectrl.coffee'
#utils
require './coffee/utils/httputils.coffee'

jTester.restart = ()->
  jTester.require.nw.Window.get().hide()
  child_process = require("child_process")
  child = child_process.spawn(process.execPath, [], {detached: true});
  child.unref()
  jTester.require.nw.App.quit()
