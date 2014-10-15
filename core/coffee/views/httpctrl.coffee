#import jTester namespace
jTester = window.jTester
__config = jTester.config
__cache = jTester.cache
__baseitems = __config.baseitems

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
                  action : that
                if that.script.length > 10
                  eval "(#{that.script})($context);"
            }
          tabs.push tab
        return tabs

      #load test data once , then save to cache
      if !(__cache.httptabs instanceof Array)
        #import test file
        window.require __baseitems.testfile
        #resolve window.Controllers
        __cache.httptabs = resolve window.Controllers

      #init tabs
      $scope.tabs = __cache.httptabs
