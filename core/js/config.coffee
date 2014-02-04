
nw = require 'nw.gui'
fs = require 'fs'
Path = require 'path'
QueryString = require 'querystring'
URL = require 'url'
HTTP = require 'http'
FormData = require './node_modules/form-data'
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
    config : rootdir + "/views/config.html"
    alert : rootdir + "/views/alert.html"
    file : rootdir + "/views/file.html"
    savefile : rootdir + "/views/savefile.html"
    downloadlist : rootdir + "/views/downloadlist.html"

app = angular.module 'jTester' , ['ui.bootstrap']
app.run ($templateCache)->
  window.templateCache = $templateCache
  $templateCache.put jTester.global.templateUrls.config , fs.readFileSync jTester.global.templateUrls.config , { encoding : "utf-8" }
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

    @execProxy = (method) ->
      @action.submit = true
      url = URL.resolve jTester.config.host , "/#{@params.controller}/#{@params.action}/"
      @$http({method : method , url : url , headers: jTester.config.headers, params : @params.data })
      .success (data , status , headers , config) =>
          @action.submit = false
          dataType = headers("content-type") || ""
          if dataType.indexOf "application/json" > -1
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
    url = "/#{@params.controller}/#{@params.action}"
    urlobj = URL.parse(jTester.config.host)
    options =
      host : urlobj.hostname
      port : urlobj.port || 80
      method : "GET"
      path : url + QueryString.stringify @params.data
      headers : jTester.config.headers
    @$context.$modalInstance.close 'dismiss'
    @$context.action.submit = true
    HTTP.get options , (res)=>
      filename = @getFileName res.headers['content-disposition']
      ext = Path.extname filename
      if !filename
        filename = @params.action
      file = @createFile @params.downdir , filename , ext
      if res.statusCode == 200
        res.on('data' , (chunk) ->
          file.write chunk
        ).on('end' , ()=>
          file.end()
          jTester.alert.success "#{file.path} 已下载完成"
          #添加到下载内容历史记录列表中
          jTester.downlist.push {
            filename : Path.basename file.path
            link : URL.resolve jTester.config.host , options.path
            path : file.path
          }
          jTester.global.saveDownlist()
          @$context.action.submit = false
        )
      else
        jTester.alert.error "下载出错,HTTP #{res.statusCode}"
        file.end()
        fs.unlinkSync file.path
        @$context.action.submit = false

      res.on('error' ,(e)=>
        @$context.action.submit = false
        jTester.alert.error e.message
      )

  upload : ()->
    form = new FormData()
    if @params.data
      for k , v of @params.data
        form.append k , v

    if @params.files
      for file , i in @params.files
        form.append 'file' + i , fs.createReadStream file

    @action.submit = true
    #close modal
    @$context.$modalInstance.close 'dismiss'

    url = URL.resolve jTester.config.host , "/#{@params.controller}/#{@params.action}/"
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