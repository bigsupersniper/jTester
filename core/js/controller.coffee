
window.Controllers =
  Home :
    Get : ()->
      $context.params =
        controller : "home"
        action : "Get"
      new jTester.http($context).get()
    Post : ()->
      $context.params =
        controller : "home"
        action : "Post"
      new jTester.http($context).post()
    Upload : ()->
      $context.params =
        controller : "home"
        action : "upload"
      $context.maxDataSize = 10
      jTester.file.openFile $context
    Down : ()->
      $context.params =
        controller : "home"
        action : "down"
      new jTester.file.saveFile $context
  WeChat :
    Login : () ->
      $context.params =
        controller : "wechat/api",
        action : "login.do" ,
        data :
          mobile : "138",
          uPass : "138",
          versionInfo : "1.0",
          deviceInfo : "node-webkit"
      new jTester.http($context).post()
    Register : ()->
      $context.params =
        controller : "wechat/api",
        action : "register.do" ,
        data :
          mobile : "138",
          uPass : "138",
          description : "138",
          nickName : "138"
      new jTester.http($context).post()
  IM :
    Login : () ->
      $context.params =
        controller : "user",
        action : "login" ,
        data :
          mobile : "user1",
          uPass : "user1",
          versionInfo : "1.0",
          deviceInfo : "node-webkit"
      new jTester.http($context).post()
    Register : ()->
      $context.params =
        controller : "user",
        action : "register" ,
        data :
          mobile : "user1",
          uPass : "user1",
          rePass : "user1",
          description : "user1 register from asp.net mvc 4",
          nickName : "user1"
      new jTester.http($context).post()
    ListAllUsers : ()->
      $context.params =
        controller : "user",
        action : "ListAllUsers" ,
        cipher : true ,
        cipherKey : "be7bca1e6945a6c18d1e281804f2237e"
      new jTester.http($context).get()