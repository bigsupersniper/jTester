#import jTester namespace
jTester = window.jTester
config = jTester.Config
path = window.require 'path'
nw = window.require 'nw.gui'

#class HttpConfigCtrl
jTester.app.controller 'HttpConfigCtrl' ,
  class HttpConfigCtrl
    constructor : ($scope) ->
      #http config
      $scope.httpconfig =
        baseUrl : config.http.baseUrl || ''
        testfile : config.http.testfile || ''
      #default test file dir
      $scope.defaultdir = path.dirname(process.execPath) + '\\app\\coffee\\test'

      $scope.change = (file)->
        ext = path.extname file
        if ext == ".js" || ext == ".coffee"
          window.UnitTests = undefined
          window.require file
          #check if contains main object
          if window.UnitTests
            config.http.testfile = file
            config.save config
            #restart
            nw.Window.get().hide()
            child_process = require 'child_process'
            child = child_process.spawn(process.execPath, [], {
              detached: true
            })
            child.unref()
            nw.App.quit()
          else
            jTester.alert.error 'window.UnitTests object not found'
        else
          jTester.alert.error 'invalid test file'

      $scope.save = ()->
        if !$scope.httpconfig.baseUrl
          jTester.error.success 'invalid url'
        else
          config.http.baseUrl = $scope.httpconfig.baseUrl
          config.http.testfile = $scope.httpconfig.testfile
          config.save config
          jTester.alert.success '保存成功'


