
#所有window.Controllers里面的测试方法只能引用全局变量
#例如：__http = jTester.http
#若以变量__http引用则会出错，必须引用 jTester.http

#test metadata
window.Controllers =
  Home :
    Get : ()->
      $context.params =
        controller : "Home"
        action : "Get"
        data : {}
      new jTester.http($context).get()
    Post : ()->
      $context.params =
        controller : "Home"
        action : "Post"
        data : {}
      new jTester.http($context).post()
    Upload : ()->
      $context.params =
        controller : "Home"
        action : "Upload"
        data : {}
      jTester.file.openFile $context
    Download : ()->
      $context.params =
        controller : "Home"
        action : "Download"
        data : {}
      new jTester.file.saveFile $context