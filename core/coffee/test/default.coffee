

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