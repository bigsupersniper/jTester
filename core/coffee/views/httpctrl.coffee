#import jTester namespace
jTester = window.jTester
__require = jTester.require
__path = __require.path
__config = jTester.config
__cache = jTester.cache
__httpconfig = __config.httpconfig
__fileutils = jTester.fileutils


#class HttpCtrl
angularapp = window.angularapp
angularapp.controller 'HttpCtrl' ,
  class HttpCtrl
    constructor : ($scope , $http , $sce) ->
      $scope.tabs = []

      #resolve window.Controllers
      resolve = (obj) ->
        obj ?= {}
        tabs = []
        for ck , cv of obj
          tab =
            controller : ck
            actions : []
          for ak , av of cv
            tab.actions.push {
              name : ak #action name
              script : av.toString() #action js code
              rowcount : av.toString().match(///\n///g).length + 2 #action code rows
              execute : ()->
                that = this
                $context =
                  $http : $http
                  $sce : $sce
                  $scope : $scope
                  action : that
                if that.script.length > 10
                  eval "(#{that.script})($context);"
            }
          tabs.push tab
        return tabs

      #load test data once , then save to cache
      if !(__cache.httptabs instanceof Array)
        #import test file
        window.require __httpconfig.testfile
        #resolve window.Controllers
        __cache.httptabs = resolve window.Controllers
      #init tabs
      $scope.tabs = __cache.httptabs
      #config tab
      $scope.config =
        host : __httpconfig.host
        testfile : __httpconfig.testfile
        savefilepath : __httpconfig.savefilepath

      $scope.items = []
      $scope.item = {}
      $scope.defaultdir = __path.dirname(process.execPath) + '\\core\\coffee\\test'
      items = __httpconfig.items || {}

      objToArray = ()->
        $scope.items = []
        for k , v of items
          $scope.items.push ({
            key : k
            value : v
          })

      objToArray()

      $scope.set = ()->
        items[$scope.item.key]= $scope.item.value
        objToArray()
        $scope.item.key = ""
        $scope.item.value = ""

      $scope.reset = (index)->
        item = $scope.items[index]
        $scope.item.key = item.key
        $scope.item.value = item.value

      $scope.remove = (index)->
        item = $scope.items[index]
        delete items[item.key]
        $scope.items.splice index , 1

      $scope.changedir = (dir)->
        $scope.config.savefilepath = dir
        __httpconfig.savefilepath = dir

      $scope.change = (file)->
        ext = __fileutils.extname file
        if ext == ".js" || ext == ".coffee"
          #清空上一次测试集合
          window.Controllers = undefined
          if ext == ".js"
            js = __fs.readFileSync file , { encoding : "utf-8"}
            window.eval js
          else if ext == ".coffee"
            #clear require cache
            if global.require.cache[file]
              delete global.require.cache[file]
            window.require file
          #验证文件是否包含测试代码
          if window.Controllers
            __httpconfig.testfile = file
            __config.save()
            $scope.config.testfile= file
            __cache.httptabs = resolve window.Controllers
            $scope.tabs = __cache.httptabs
            #jTester.restart()
          else
            jTester.alert.error '该脚本文件不包含 window.Controllers 对象'
        else
          jTester.alert.error '不是 javascript 文件'

      $scope.saveall = ()->
          #remove last / .replace /(\/*$)/g,""
        __httpconfig.host = $scope.config.host
        __httpconfig.testfile = $scope.config.testfile
        __httpconfig.savefilepath = $scope.config.savefilepath
        __httpconfig.items = items
        __config.save()
        jTester.alert.success '保存成功'

      for k , v in global.require.cache
        console.log k
        console.log v