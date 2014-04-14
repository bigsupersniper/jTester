

window.datadecrypt = (api_secret , data)->
  if data.data != "" && data.success
    data.data = jTester.AES.decrypt api_secret , data.data
    data.data = JSON.parse data.data
  return data

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

