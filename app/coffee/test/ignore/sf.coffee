#import jTester namespace
jTester = window.jTester

#request entrance
submitRequest = (context , useToken , callback)->
  client_id = jTester.Config.items["client_id"] || ""
  if !jTester.Config.items["imei"]
    jTester.Config.items["imei"] = jTester.String.getUUID()
    jTester.Config.save jTester.Config
  imei = jTester.Config.items["imei"] || ""
  once = jTester.String.getUUID()
  timestamp = (new Date()).valueOf() + ''
  plainText = JSON.stringify context.data || {}
  if useToken
    api_secret = jTester.Config.items["api_secret"] || ""
    api_token =  jTester.Config.items["api_token"] || ""
    secret_key = api_secret
    signature = "client_id=#{client_id}&api_secret=#{api_secret}&timestamp=#{timestamp}&once=#{once}&api_token=#{api_token}&parameters=#{plainText}&imei=#{imei}"
    context.data =
      client_id : client_id
      timestamp :  timestamp
      api_token : api_token
      once : once
      imei : imei
      signature : jTester.String.computeMD5 signature
      ciphertext : jTester.AES.encrypt_ecb secret_key , plainText
  else
    client_secret = jTester.Config.items["client_secret"] || ""
    secret_key = client_secret
    signature = "client_id=#{client_id}&client_secret=#{client_secret}&timestamp=#{timestamp}&once=#{once}&parameters=#{plainText}&imei=#{imei}"
    context.data =
      client_id : client_id
      timestamp :  timestamp
      once : once
      imei : imei
      signature : jTester.String.computeMD5 signature
      ciphertext : jTester.AES.encrypt_ecb secret_key , plainText
  #config callback
  context.beforeSend = ()->
    context.$scope.defaultHttpHandler.beforeSend context
  context.complete = (response , body)->
    if body
      result = JSON.parse body
      if result.success == "1"
        planText = jTester.AES.decrypt_ecb secret_key , result.data
        if planText
          result.data = JSON.parse planText
        else
          result.data = planText
      if callback && result.data
        callback result.data
    context.$scope.defaultHttpHandler.complete context , response , result
  context.error = (err , response)->
    context.$scope.defaultHttpHandler.error context, err , response
  #submit request
  jTester.HttpRequest.post context

#local tests
UnitTests = {}

#***************************************** Auth api part *****************************************#
UnitTests.Auth = {}
#UserController
UnitTests.Auth.User =
  UrlConfig :
    data : {
      type : 1
      local : "http://localhost:6079"
      debug : "http://192.168.1.43:6079"
      release : "http://220.172.189.196:6079"
    }
    submit : (context)->
      type = context.data.type || 1
      if type == 2
        jTester.Config.http.baseUrl = context.data.debug
      else if type == 3
        jTester.Config.http.baseUrl = context.data.release
      else
        jTester.Config.http.baseUrl = context.data.local
      jTester.Config.save jTester.Config
      context.ref.result = context.$sce.trustAsHtml "#{new Date().toLocaleString()}<p></p>#{new window.JSONFormatter().jsonToHTML(jTester.Config.http)}"
  HybridLogin :
    uri : "/User/HybridLogin"
    data : {
      username : "201002044062"
      password : "123456"
      schoolcode : "10614"
    }
    submit : (context)->
      context.baseUrl = jTester.Config.http.baseUrl
      submitRequest context , false , (data)->
        config = jTester.Config
        config.items["api_token"] = data["api_token"]
        config.items["api_secret"] = data["api_secret"]
        school_url = data["serverurl"]
        baseurl =  jTester.Config.http.baseUrl
        if baseurl.indexOf 'http://localhost' < 0 || baseurl.indexOf 'http://127.0.0.1' < 0
          config.items["school_url"] = "http://" + school_url
        else
          config.items["school_url"] = "http://localhost:6080"
        config.save config

#***************************************** School api part *****************************************#
UnitTests.School = {}
#UserController
UnitTests.School.User =
  UrlConfig :
    submit : (context)->
      data =
        baseUrl : jTester.Config.items["school_url"] || ''
      context.ref.result = context.$sce.trustAsHtml "#{new Date().toLocaleString()}<p></p>#{new window.JSONFormatter().jsonToHTML(data)}"
  GetUserInfo :
    uri : "/User/GetUserInfo"
    submit : (context)->
      context.baseUrl = jTester.Config.items["school_url"] || ''
      submitRequest context , true

#ScheduleInfoController
UnitTests.School.ScheduleInfo =
  CreateQuestion :
    uri : "/ScheduleInfo/CreateQuestion"
    data : {
      description : ""
      picurl : ""
      thumbpicurl : ""
      expire : 5
      options : [
        {
          flag: "A"
          description: ""
        },
        {
          flag: "B"
          description: ""
        }
      ]
    }
    submit : (context)->
      context.baseUrl = jTester.Config.items["school_url"] || ''
      submitRequest context , true
  GetQuestionByCode :
    uri : "/ScheduleInfo/GetQuestionByCode"
    data : {
      secretcode : ""
    }
    submit : (context)->
      context.baseUrl = jTester.Config.items["school_url"] || ''
      submitRequest context , true
  SubmitQuestionAnswer :
    uri : "/ScheduleInfo/SubmitQuestionAnswer"
    data : {
      questionid : ""
      secretcode : ""
      option : ""
    }
    submit : (context)->
      context.baseUrl = jTester.Config.items["school_url"] || ''
      submitRequest context , true
  GetQuestionStats :
    uri : "/ScheduleInfo/GetQuestionStats"
    data : {
      questionid : ""
    }
    submit : (context)->
      context.baseUrl = jTester.Config.items["school_url"] || ''
      submitRequest context , true

#***************************************** export window.UnitTests *****************************************#
window.UnitTests = {}
for key , module of UnitTests
  for cn , ctrl of module
    moduleName = key + '_' + cn
    window.UnitTests[moduleName] = {}
    for an , act of ctrl
      window.UnitTests[moduleName][an] = act