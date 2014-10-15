#import jTester namespace
jTester = window.jTester
__require = jTester.require
__nw = __require.nw
__views = jTester.views
__config = jTester.config
__baseitems = __config.baseitems

#class IndexCtrl
angularapp = window.angularapp
angularapp.controller 'IndexCtrl' ,
  class IndexCtrl
    constructor : ($scope ,$modal , $timeout ) ->

      $scope.loading = true
      $timeout ()->
        $scope.loading = false
      , 1500

      #static class jTester.alert
      jTester.alert =
        show : (type , message , timeout)->
          timeout = timeout || 3000
          $modal.open {
            templateUrl : __views.alert
            backdrop : 'center'
            resolve : {
              message : ()->
                return message
              type : ()->
                return type
              timeout : ()->
                return timeout
            }
            controller: ($scope , $modalInstance , $timeout , message , type, timeout)->
              $scope.message = message
              $scope.type = type
              $timeout ()->
                $modalInstance.close 'dismiss'
              , timeout
          }
        success : (message , timeout)->
          @show('success' , message, timeout)
        error : (message, timeout)->
          @show('danger' , message, timeout)

      #static class jTester.file
      jTester.file =
        openFile : ($context)->
          $modal.open {
            templateUrl: __views.uploadfile
            backdrop : 'static'
            resolve :{
              context : ()->
                return $context
            }
            controller : 'UploadFileCtrl'
          }
        saveFile : ($context)->
          $modal.open {
            templateUrl: __views.savefile
            backdrop : 'static'
            resolve :{
              context : ()->
                return $context
            }
            controller: 'SaveFileCtrl'
          }

      #global nav menus
      $scope.menus =
        showDevTools : ()->
          __nw.Window.get().showDevTools()
        restart : ()->
          #Clear the HTTP cache in memory and the one on disk
          __require.nw.App.clearCache()
          jTester.restart()
        quit : ()->
          __require.nw.App.quit()
        baseconfig :()->
          $modal.open {
            templateUrl: __views.config
            backdrop : 'static'
            controller: 'ConfigCtrl'
          }
        globalconfig : ()->
          $modal.open {
            templateUrl: __views.globalitem
            backdrop : 'static'
            controller: 'GlobalItemCtrl'
          }
        download : ()->
          $modalInstance = $modal.open {
            templateUrl: __views.downloadlist
            backdrop : 'center'
            controller: 'DownlistCtrl'
          }

          $modalInstance.result.then (result)->
            if result == 'success'
              jTester.alert.success '保存成功'
        help : ()->
          $modal.open {
            templateUrl: __views.help
            backdrop : 'center'
            controller: ($scope)->
          }
        about : ()->
          $modal.open {
            templateUrl: __views.about
            backdrop : 'center'
            controller : ($scope)->
              $scope.versions = [
                { title : "jTester", value : "v0.2.2.20141012" }
                { title : "Chromium", value : process.versions['chromium'] }
                { title : "Node-Webkit", value : process.versions['node-webkit'] }
                { title : "Node", value : process.versions['node'] }
                { title : "ArgularJS", value : "v1.2.26" }
                { title : "Angular-ui-Bootstrap", value : "v0.11.2" }
                { title : "bootstrap css", value : "v3.2.0" }
                { title : "cryptojs", value : "v3.1.2" }
                { title : "coffee-script", value : "v1.8.0" }
                { title : "node-uuid", value : "v1.4.1" }
                { title : "request", value : "v2.33.0" }
              ]
          }

      #run when page loaded
      if !__baseitems.address
        menus.baseconfig()
