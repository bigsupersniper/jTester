
#所有window.Controllers里面的测试方法只能引用全局变量
#例如：__http = jTester.http
#若以变量__http引用则会出错，必须引用 jTester.http

#test metadata
window.Controllers =
  Home :
    Get : ()->
      $context.params =
        url : "/Home/Get"
        data : {}
      new jTester.http($context).get()
    Post : ()->
      $context.params =
        url : "/Home/Post"
        data : {}
      new jTester.http($context).post()
    Upload : ()->
      $context.params =
        url : "/Home/Upload"
        data : {}
      jTester.file.openFile $context
    Download : ()->
      $context.params =
        url : "/Home/Download"
        data : {}
      new jTester.file.saveFile $context

httpRequests = httpRequests || {}
httpRequests.Home = {}
httpRequests.Home.Login =
  params :
    username : "admin"
    password : "123456"
  handler : ()->
    console.log this.params

window.httpRequests = httpRequests

tabs = []

for tn , th of httpRequests
  handlers = []
  for hn , hh of th
    handlers.push
      name : hn,
      params : hh.params
      handler : hh.handler
  tabs.push
    title : tn
    handlers : handlers

window.tabs = tabs


