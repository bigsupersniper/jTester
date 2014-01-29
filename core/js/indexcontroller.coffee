
#################### class IndexCtrl ####################################

class window.IndexCtrl
  constructor : ($scope , $http , $modal ,$sce ) ->

    $scope.menus = [
      {
        title :  "设置"
        click : ()->
          openOptions()
      }
    ]

    jTester.alert =
      show : (type , message)->
        $modal.open {
          template: '<alert type="type" style="text-align: center ; margin-bottom : 0px">{{ message }}</alert>'
          backdrop : 'center'
          resolve : {
            message : ()->
              return message
            type : ()->
              return type
          }
          controller: ($scope , $modalInstance , $timeout , message , type)->
            $scope.message = message
            $scope.type = type
            $timeout ()->
              $modalInstance.close 'dismiss'
            , 2000
        }
      success : (message)->
        @show('success' , message)
      error : (message)->
        @show('danger' , message)

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

    openOptions = ()->
      $modalInstance = $modal.open {
        templateUrl: jTester.global.templateUrls.config
        backdrop : 'static'
        controller: 'ConfigCtrl'
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
        jTester.alert.success '请先设置服务器地址'
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
    downlink = "#{jTester.config.host}/#{context.params.controller}/#{context.params.action}"
    context.$modalInstance = $modalInstance
    $scope.params =
      filename  : context.params.action
      defaultPath : jTester.config.defaultPath
      downlink : downlink

    $scope.save = ()->
      context.params.downdir = $scope.params.downdir || jTester.config.defaultPath
      new jTester.http(context).down()

    $scope.cancel = ()->
      $modalInstance.close 'dismiss'