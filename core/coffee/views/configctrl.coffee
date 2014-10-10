#import jTester namespace
jTester = window.jTester
__require = jTester.require
__fs = __require.fs
__nw = __require.nw
__config = jTester.config
__baseitems = __config.baseitems
__fileutils = jTester.fileutils

#class ConfigCtrl
angularapp = window.angularapp
angularapp.controller 'ConfigCtrl' ,
  class ConfigCtrl
    constructor : ($scope , $modalInstance , $window) ->
      headers = __baseitems.headers
      $scope.headers = []

      objToArray = ()->
        $scope.headers = []
        for k , v of headers
          $scope.headers.push ({
            key : k
            value : v
          })

      #exec at startup
      objToArray()

      $scope.config = {
        testfile : __baseitems.testfile
        address : __baseitems.address
        savefilepath : __baseitems.savefilepath
      }

      $scope.set = ()->
        headers[$scope.config.key]= $scope.config.value
        objToArray()
        $scope.config.key = ""
        $scope.config.value = ""

      $scope.reset = (index)->
        header = $scope.headers[index]
        $scope.config.key = header.key
        $scope.config.value = header.value

      $scope.remove = (index)->
        header = $scope.headers[index]
        delete headers[header.key]
        $scope.headers.splice index , 1

      $scope.save = ()->
        #remove last / .replace /(\/*$)/g,""
        __baseitems.address = $scope.config.address
        __baseitems.savefilepath = $scope.config.defaultpath || __baseitems.savefilepath
        __config.save()
        $modalInstance.close 'success'

      $scope.cancel = ()->
        if !__baseitems.address
          jTester.alert.error '请先设置服务器地址'
        else
          $modalInstance.close 'dismiss'

      $scope.changedir = (dir)->
        $scope.config.savefilepath = dir
        __baseitems.savefilepath = dir

      $scope.change = (file)->
        ext = __fileutils.extname file
        if ext == ".js" || ext == ".coffee"
          #清空上一次测试集合
          window.Controllers = undefined
          if ext == ".js"
            js = __fs.readFileSync file , { encoding : "utf-8"}
            window.eval js
          else if ext == ".coffee"
            window.require file
          #验证文件是否包含测试代码
          if window.Controllers
            __baseitems.testfile = file
            __config.save()
            jTester.restart()
          else
            jTester.alert.error '该脚本文件不包含 window.Controllers 对象'
        else
          jTester.alert.error '不是 javascript 文件'