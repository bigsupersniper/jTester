#import jTester namespace
jTester = window.jTester
__require = jTester.require
__nw = __require.nw
__views = jTester.views
__config = jTester.config

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
        download : ()->
          $modalInstance = $modal.open {
            templateUrl: __views.downloadlist
            backdrop : 'center'
            controller: 'DownlistCtrl'
          }

          $modalInstance.result.then (result)->
            if result == 'success'
              jTester.alert.success '保存成功'
        about : ()->
          $modal.open {
            templateUrl: __views.about
            backdrop : 'center'
            controller : ($scope)->
              $scope.versions = [
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
                { title : "simple-xmpp", value : "v0.1.92" }
                { title : "dateformat", value : "v1.0.8" }
              ]
          }