#import jTester namespace
jTester = window.jTester

#default callback
beforeSubmit = (context)->
  context.baseUrl = jTester.Config.http.baseUrl
  context.beforeSend = ()->
    context.$scope.defaultHttpHandler.beforeSend context
  context.complete = (response , body)->
    context.$scope.defaultHttpHandler.complete context , response , body
  context.error = (err , response)->
    context.$scope.defaultHttpHandler.error context, err , response

window.UnitTests =
  Home :
    Get :
      uri : "/Home/Get"
      data : {}
      beforeSubmit : beforeSubmit
      submit : (context)->
        jTester.HttpRequest.get(context)
    Post :
      uri : "/Home/PostAsJson"
      data :
        a : 1
        b : "sdfsdf"
      beforeSubmit : beforeSubmit
      submit : (context)->
        jTester.HttpRequest.post(context)
    PostAsJson :
      uri : "/Home/PostAsJson"
      data :
        a : 1
        b : "sdfsdf"
      beforeSubmit : beforeSubmit
      submit : (context)->
        jTester.HttpRequest.postjson(context)
    PostFile :
      uri : "/Home/PostFile"
      data :
        a : 1
        b : 2
      beforeSubmit : beforeSubmit
      submit : (context)->
        context.$scope.openFileUpload(context)
