
nw = require 'nw.gui'
fs = require 'fs'
Path = require 'path'
QueryString = require 'querystring'
URL = require 'url'
request = require './node_modules/request'
FormData = require './node_modules/request/node_modules/form-data'
rootdir = "./core"

process.on 'uncaughtException' , (err)->
  alert err.message

window.jTester = {}
window.jTester.config = {}
window.jTester.alert = {}
window.jTester.file = {}
window.jTester.downlist = []

try
  config = fs.readFileSync rootdir + '/config.json' , { encoding : "utf-8" }
  if config
    jTester.config = JSON.parse config
    if !jTester.config.headers
      jTester.config.headers = {}
    if !jTester.config.defaultPath
      jTester.config.defaultPath = "D:\\"

  downlist = fs.readFileSync rootdir + '/download.json' , { encoding : "utf-8" }
  if downlist
    jTester.downlist = JSON.parse downlist
catch e
  jTester.config =
    headers : {}
    host : ""
    defaultPath : "D:\\"
  alert e.message

window.jTester.global =
  URL : URL
  rmfile : (path)->
    if fs.existsSync path
      fs.unlinkSync path
  fileExistsSync : (path)->
    return fs.existsSync path
  saveConfig : ()->
    try
      config = JSON.stringify window.jTester.config
      fs.writeFileSync rootdir + '/config.json' , config , { encoding : "utf-8" }
    catch e
      alert e.message
  saveDownlist : ()->
    try
      downlist = JSON.stringify window.jTester.downlist
      fs.writeFileSync rootdir + '/download.json' , downlist , { encoding : "utf-8" }
    catch e
      alert e.message
  showItemInFolder : (path)->
    nw.Shell.showItemInFolder(path)
  showDevTools : ()->
    nw.Window.get().showDevTools()
  templateUrls :
    about : rootdir + "/views/about.html"
    config : rootdir + "/views/config.html"
    globalitem : rootdir + "/views/globalitem.html"
    alert : rootdir + "/views/alert.html"
    file : rootdir + "/views/file.html"
    savefile : rootdir + "/views/savefile.html"
    downloadlist : rootdir + "/views/downloadlist.html"

window.appjTester = angular.module 'jTester' , ['ui.bootstrap']
appjTester.run ($templateCache)->
  $templateCache.put jTester.global.templateUrls.about , fs.readFileSync jTester.global.templateUrls.about , { encoding : "utf-8" }
  $templateCache.put jTester.global.templateUrls.config , fs.readFileSync jTester.global.templateUrls.config , { encoding : "utf-8" }
  $templateCache.put jTester.global.templateUrls.globalitem , fs.readFileSync jTester.global.templateUrls.globalitem , { encoding : "utf-8" }
  $templateCache.put jTester.global.templateUrls.alert , fs.readFileSync jTester.global.templateUrls.alert , { encoding : "utf-8" }
  $templateCache.put jTester.global.templateUrls.file , fs.readFileSync jTester.global.templateUrls.file , { encoding : "utf-8" }
  $templateCache.put jTester.global.templateUrls.savefile , fs.readFileSync jTester.global.templateUrls.savefile , { encoding : "utf-8" }
  $templateCache.put jTester.global.templateUrls.downloadlist , fs.readFileSync jTester.global.templateUrls.downloadlist , { encoding : "utf-8" }

########################## class jTester.http ##############################
class window.jTester.http
  constructor : ($context)->
    @$context = $context
    @$http = $context.$http || {}
    @$sce = $context.$sce || {}
    @params = $context.params || {}
    @action = $context.action || {}
    @cipher = $context.cipher || (data)-> return data

    @execProxy = (method) ->
      @action.submit = true
      url = URL.resolve jTester.config.host , "/#{@params.controller}/#{@params.action}/"
      config = {method : method , url : url , headers: jTester.config.headers, data : @params.data }
      if method == "POST"
        config.transformRequest = (obj)->
          str = []
          for k , v of obj
            str.push(encodeURIComponent(k) + "=" + encodeURIComponent(v))
          return str.join '&'
        config.headers["Content-Type"] = "application/x-www-form-urlencoded"

      @$http(config).success (data , status , headers , config) =>
          @action.submit = false
          dataType = headers("content-type") || ""
          if dataType.indexOf "application/json" > -1
            data = @cipher(data)
            @action.result = @$sce.trustAsHtml "#{new Date().toLocaleString()} <p></p> #{new JSONFormatter().jsonToHTML(data)}"
          else
            @action.result = @$sce.trustAsHtml "#{new Date().toLocaleString()} <p></p> #{data}}"
      .error (data , status , headers, config) =>
          @action.submit = false
          jTester.alert.error "#{url} , 请求失败"

    @getFileName = (cd)->
      if cd
        arr = cd.split(";")
        filename = ""
        for k in arr
          k = k.trim()
          if k.indexOf('filename') == 0
            if k.indexOf('*=') == 8
              filename = decodeURIComponent(k.replace "filename*=UTF-8''" , "")
            else
              filename = k.replace "filename=" , ""
            break
        return filename
      else
        return ""

    @createFile = (dir , filename , ext)->
      path = Path.join dir , filename
      file = null
      if !fs.existsSync path
        file = fs.createWriteStream path
      else
        name = Path.basename path , ext
        i = 1
        while true
          _name = name + "(#{i++})" + ext
          path = Path.join dir , _name
          if !fs.existsSync path
            file = fs.createWriteStream path
            break
      return file

  get : () ->
    @execProxy "GET"

  post : () ->
    @execProxy "POST"

  put : () ->
    @execProxy "PUT"

  delete : () ->
    @execProxy "DELETE"

  down : () ->
    @$context.$modalInstance.close 'dismiss'
    @$context.action.submit = true
    options =
      uri : URL.resolve jTester.config.host , "/#{@params.controller}/#{@params.action}/"
      method : "GET",
      headers : jTester.config.headers
      form : @params.data

    req = request options
    req.on 'response' , (res)=>
      console.log res
      filename = @getFileName res.headers['content-disposition']
      ext = Path.extname filename
      if !filename
        filename = @params.action
      file = @createFile @params.downdir , filename , ext
      if res.statusCode == 200
        res.on 'data' , (chunk) ->
          file.write chunk
        res.on 'end' , ()=>
          file.end()
          jTester.alert.success "#{file.path} 已下载完成"
          #添加到下载内容历史记录列表中
          jTester.downlist.push {
            filename : Path.basename file.path
            link : options.uri + QueryString.stringify @params.data
            path : file.path
          }
          jTester.global.saveDownlist()
          @$context.action.submit = false
      else
        jTester.alert.error "下载出错,HTTP #{res.statusCode}"
        file.end()
        fs.unlinkSync file.path
        @$context.action.submit = false

      res.on 'error' ,(e)=>
        @$context.action.submit = false
        jTester.alert.error e.message

  upload : ()->
    @action.submit = true
    #close modal
    @$context.$modalInstance.close 'dismiss'

    url = URL.resolve jTester.config.host , "/#{@params.controller}/#{@params.action}/"
    form = new FormData()
    #form.maxDataSize = @$context.maxDataSize * 1024 * 1024 if @$context.maxDataSize

    if @params.data
      for k , v of @params.data
        form.append k , v

    if @params.files
      for file , i in @params.files
        form.append 'file' + i , fs.createReadStream file

    #modify form-data source submit(parms , cb) to submit(params , headers , cb)
    form.submit url , jTester.config.headers , (err , res)=>
      if err
        @action.submit = false
        jTester.alert.error err.message
      else
        dataType = res.headers["content-type"] || ''
        res.on 'data' , (chunk)=>
          @action.submit = false
          data = chunk + ''
          if dataType.indexOf "application/json" > -1
            data = JSON.parse data
            @action.result = @$sce.trustAsHtml "#{new Date().toLocaleString()} <p></p> #{new JSONFormatter().jsonToHTML(data)}"
          else
            @action.result = @$sce.trustAsHtml "#{new Date().toLocaleString()} <p></p> #{data}"


