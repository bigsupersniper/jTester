
#################### class IndexCtrl ####################################

class window.IndexCtrl
  constructor : ($scope , $http , $modal ,$sce , $timeout) ->

    $scope.loading = true
    $timeout ()->
      $scope.loading = false
    , 1500

    $scope.menus = [
      {
        title :  "设置"
        click : ()->
          openOptions()
      }
      {
        title :  "下载内容"
        click : ()->
          openDownloads()
      }
    ]

    jTester.alert =
      show : (type , message , timeout)->
        timeout = timeout || 3000
        $modal.open {
          templateUrl : jTester.global.templateUrls.alert
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

    jTester.file.openFile = ($context)->
      $modal.open {
        templateUrl: jTester.global.templateUrls.file
        backdrop : 'static'
        resolve :{
          context : ()->
            return $context
        }
        controller : 'OpenFileCtrl'
      }

    jTester.file.saveFile = ($context)->
      $modal.open {
        templateUrl: jTester.global.templateUrls.savefile
        backdrop : 'static'
        resolve :{
          context : ()->
            return $context
        }
        controller: 'SaveFileCtrl'
      }

    $scope.showDevTools = ()->
      jTester.global.showDevTools()

    $scope.tabs = []
    resolve = (obj) ->
      obj ?= {}
      $context =
        $http : $http
        $sce : $sce
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
              $context.action = that
              if that.script.length > 10
                eval "(#{that.script})($context);"
          }
        $scope.tabs.push tab

    $scope.openAbout = ()->
      $modalInstance = $modal.open {
        templateUrl: jTester.global.templateUrls.about
        backdrop : 'center'
        controller: ($scope)->

      }

    openOptions = ()->
      $modalInstance = $modal.open {
        templateUrl: jTester.global.templateUrls.config
        backdrop : 'static'
        controller: 'ConfigCtrl'
      }

    openDownloads = ()->
      $modalInstance = $modal.open {
        templateUrl: jTester.global.templateUrls.downloadlist
        backdrop : 'center'
        controller: 'DownlistCtrl'
      }

      $modalInstance.result.then (result)->
        if result == 'success'
          jTester.alert.success '保存成功'

    #run when page loaded
    if !jTester.config.host
      openOptions()

    #resolve test method
    resolve window.Controllers

########################## class ConfigCtrl ##############################

class window.ConfigCtrl
  constructor : ($scope , $modalInstance) ->
    jTester = window.jTester
    headers = jTester.config.headers
    $scope.headers = []
    $scope.config = {
      host : jTester.config.host
      defaultPath : jTester.config.defaultPath
    }

    objToArray = ()->
      $scope.headers = []
      for k , v of headers
        $scope.headers.push ({
          key : k
          value : v
        })

    objToArray()

    $scope.set = ()->
      headers[$scope.config.key]= $scope.config.value
      objToArray()
      $scope.config.key = ""
      $scope.config.value = ""

    $scope.remove = (index)->
      header = $scope.headers[index]
      delete headers[header.key]
      $scope.headers.splice index , 1

    $scope.save = ()->
      #remove last / .replace /(\/*$)/g,""
      jTester.config.host = $scope.config.host
      jTester.config.defaultPath = $scope.config.downdir || jTester.config.defaultPath
      jTester.global.saveConfig()
      $modalInstance.close 'success'

    $scope.cancel = ()->
      if !jTester.config.host
        alert '请先设置服务器地址'
      else
        $modalInstance.close 'dismiss'

########################## class OpenFileCtrl ##############################

class window.OpenFileCtrl
  constructor : ($scope , $modalInstance , context)->
    context.$modalInstance = $modalInstance
    $scope.files = []
    $scope.change = (file)->
      $scope.files.push file

    $scope.remove = (index)->
      $scope.files.splice index , 1

    $scope.upload = ()->
      context.params.files = $scope.files
      new jTester.http(context).upload()

    $scope.cancel = ()->
      $modalInstance.close 'dismiss'

########################## class SaveFileCtrl ##############################

class window.SaveFileCtrl
  constructor : ($scope , $modalInstance , context)->
    context.$modalInstance = $modalInstance
    $scope.params =
      filename  : context.params.action
      defaultPath : jTester.config.defaultPath
      downlink : jTester.global.URL.resolve jTester.config.host , "/#{context.params.controller}/#{context.params.action}"

    $scope.save = ()->
      context.params.downdir = $scope.params.downdir || jTester.config.defaultPath
      new jTester.http(context).down()

    $scope.cancel = ()->
      $modalInstance.close 'dismiss'

########################## class DownlistCtrl ##############################

class window.DownlistCtrl
  constructor : ($scope , $modalInstance)->
    $scope.items = jTester.downlist

    $scope.showItemInFolder = (path)->
      if jTester.global.fileExistsSync path
        jTester.global.showItemInFolder path
      else
        alert '文件已删除'

    $scope.remove = (index)->
      $scope.items.splice index , 1
      jTester.global.saveDownlist()

    $scope.clear = ()->
      jTester.downlist = []
      $scope.items = []
      jTester.global.saveDownlist()

    $scope.cancel = ()->
      $modalInstance.close 'dismiss'