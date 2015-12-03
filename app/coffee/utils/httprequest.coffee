
fs = window.require 'fs'
request = window.require './node_modules/request'

#build options
buildOptions = (context)->
  options = {}
  if context.url
    options.url = context.url
  else if context.baseUrl && context.uri
    options.baseUrl = context.baseUrl
    options.uri = context.uri
  return options

#submit request
buildRequest = (options , context)->
  #before send callback
  if typeof context.beforeSend == "function"
    context.beforeSend()
  #main request body
  request(options).on('error' , (err)->
    if typeof context.error == "function"
      context.error err , null
  ).on('response' , (response)->
    if response.statusCode == 200
      response.on 'data' , (chunk) ->
        if typeof context.complete ==  "function"
          context.complete response , chunk + ''
    else
      if typeof context.error == "function"
        context.error null , response
  )

#static class  HttpRequest
HttpRequest =
  #get
  get : (context)->
    options = buildOptions(context)
    options.method = "GET"
    if context.data
      options.qs = context.data
    buildRequest options , context
  #post
  post : (context)->
    options = buildOptions(context)
    options.method = "POST"
    if context.data
      options.form = context.data
    buildRequest options , context
  #post as json
  postjson : (context)->
    options = buildOptions(context)
    options.method = "POST"
    if context.data
      options.body = context.data
    options.json = true
    buildRequest options , context
  #upload
  upload : (context)->
    options = buildOptions(context)
    options.method = "POST"
    formData = {}
    if context.data && typeof context.data == "object"
      formData = context.data
    if context.files && Array.isArray context.files
      attachments = []
      for fp in context.files
        attachments.push fs.createReadStream fp
      formData.attachments = attachments
    options.formData = formData
    buildRequest options , context
  #download
  saveAs : (context)->
    options = buildOptions(context)
    options.method = "GET"
    if context.data
      options.qs = context.data
    #before send callback
    if typeof context.beforeSend == "function"
      context.beforeSend()
    #main request body
    request(options).on('error' , (err)->
      if typeof context.error == "function"
        context.error err , null
    ).on('response' , (response)->
      if response.statusCode == 200
        if fs.existsSync context.savefile
          fs.unlinkSync context.savefile
        #open write
        file = fs.createWriteStream context.savefile , 'utf-8'

        response.on 'data' , (chunk)->
          file.write chunk

        response.on 'end' , ()->
          file.end()
          if typeof context.complete ==  "function"
            context.complete response

        response.on 'error' , (e)->
          file.end()
          file.unlinkSync()
          if typeof context.error == "function"
            context.error error , null
    )

#export module  
window.jTester.HttpRequest = HttpRequest