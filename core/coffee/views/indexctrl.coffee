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
    constructor : ($scope , $http , $modal ,$sce , $timeout , $window) ->

      $scope.loading = true
      $timeout ()->
        $scope.loading = false
      , 1500

      $scope.menus = [
        {
          title :  "基础配置"
          click : ()->
            openConfig()
        }
        {
          title :  "全局项配置"
          click : ()->
            openGlobalItem()
        }
        {
          title :  "下载内容"
          click : ()->
            openDownloads()
        }
        {
          title :  "重启"
          click : ()->
            #$window.location.reload()
            jTester.restart()
        }
      ]

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
      jTester.file.openFile = ($context)->
        $modal.open {
          templateUrl: __views.uploadfile
          backdrop : 'static'
          resolve :{
            context : ()->
              return $context
          }
          controller : 'UploadFileCtrl'
        }

      jTester.file.saveFile = ($context)->
        $modal.open {
          templateUrl: __views.savefile
          backdrop : 'static'
          resolve :{
            context : ()->
              return $context
          }
          controller: 'SaveFileCtrl'
        }

      $scope.showDevTools = ()->
        __nw.Window.get().showDevTools()

      $scope.openAbout = ()->
        $modal.open {
          templateUrl: __views.about
          backdrop : 'center'
          controller : ($scope)->
            $scope.versions = [
              { title : "jTester", value : "v0.2.0" }
              { title : "Chromium", value : process.versions['chromium'] }
              { title : "Node-Webkit", value : process.versions['node-webkit'] }
              { title : "Node", value : process.versions['node'] }
              { title : "ArgularJS", value : "v1.2.26" }
              { title : "Angular-UI-Bootstrap", value : "v0.11.2" }
              { title : "CryptoJS", value : "v3.1.2" }
              { title : "Bootstrap CSS", value : "v3.2.0" }
            ]
        }

      $scope.openHelp = ()->
        $modal.open {
          templateUrl: __views.help
          backdrop : 'center'
          controller: ($scope)->

        }

      openConfig = ()->
        $modal.open {
          templateUrl: __views.config
          backdrop : 'static'
          resolve : [
            $window : ()->
              return $window
          ]
          controller: 'ConfigCtrl'
        }

      openGlobalItem = ()->
        $modal.open {
          templateUrl: __views.globalitem
          backdrop : 'static'
          controller: 'GlobalItemCtrl'
        }

      openDownloads = ()->
        $modalInstance = $modal.open {
          templateUrl: __views.downloadlist
          backdrop : 'center'
          controller: 'DownlistCtrl'
        }

        $modalInstance.result.then (result)->
          if result == 'success'
            jTester.alert.success '保存成功'

      #resolve test method
      $scope.tabs = []
      resolve = (obj) ->
        obj ?= {}
        for ck , cv of obj
          tab =
            controller : ck
            actions : []
          for ak , av of cv
            tab.actions.push {
              action : ak
              script : av.toString()
              rows : av.toString().match(///\n///g).length + 2
              exec : ()->
                that = this
                $context =
                  $http : $http
                  $sce : $sce
                  action : that
                if that.script.length > 10
                  eval "(#{that.script})($context);"
            }
          $scope.tabs.push tab

      #resolve test method
      window.require __baseitems.testfile
      resolve window.Controllers

      #run when page loaded
      if !__baseitems.address
        openConfig()

