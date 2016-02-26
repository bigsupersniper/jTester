
fs = require 'fs'

#config path
configPath = './app/config.json'

#config define
config =
  http :
    baseUrl : "" #fully qualified uri string used as the base url
    testfile : "" #main test file path
  items : { } #global key-value pair
  #init config
  init : ()->
    if fs.existsSync configPath
      json = fs.readFileSync configPath , { encoding : "utf-8" }
      _config = JSON.parse json
      @http = _config.http || { baseUrl : '' , testfile : ''}
      @items = _config.items || {}
  #save config
  save : (cfg)->
    json = JSON.stringify cfg , null , 4
    fs.writeFileSync  configPath, json , { encoding : "utf-8" }
    if @httpChange
      @httpChange()
    if itemChange
      itemChange()

#init config
config.init()

#export module
window.jTester.Config = config
