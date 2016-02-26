#import jTester namespace
jTester = window.jTester
config = jTester.Config
path = window.require 'path'
nw = window.require 'nw.gui'
fs = window.require 'fs'

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
          delete global.require.cache[config.http.testfile]
          window.require file
          #check if contains main object
          if window.UnitTests
            config.http.testfile = file
            config.save config
            #recreate tabs
            $scope.createTabs()
            #load test code
            loadTestCode()
            $scope.alert.success '载入测试文件成功'
          else
            $scope.alert.error 'window.UnitTests object not found'
        else
          $scope.alert.error 'invalid test file'

      $scope.save = ()->
        if !$scope.httpconfig.baseUrl
          jTester.error.success 'invalid url'
        else
          config.http.baseUrl = $scope.httpconfig.baseUrl
          config.http.testfile = $scope.httpconfig.testfile
          config.save config
          $scope.alert.success '保存成功'

      aceEditor = {}

      $scope.aceOptions =
        mode : 'coffee',
        useWrapMode : true
        showGutter: true
        theme:'tomorrow_night_eighties'
        onLoad : (editor)->
          aceEditor = editor

      $scope.saveAndReloadCode = ()->
        $scope.saveCode()
        delete global.require.cache[config.http.testfile]
        window.require config.http.testfile
        $scope.createTabs()
        $scope.alert.success '保存并重载成功'

      $scope.saveCode = ()->
        fs.exists $scope.testfile , (exists)->
          if exists
            fs.writeFile $scope.testfile, aceEditor.getValue() , (err)->
              if err
                $scope.alert.error err
              else
                $scope.alert.success '保存成功'

      #load test code
      loadTestCode = ()->
        fs.exists jTester.Config.http.testfile , (exists)->
          if exists
            fs.readFile jTester.Config.http.testfile , 'utf-8' , (err , data)->
              $scope.testfile = jTester.Config.http.testfile
              $scope.testcode = data

      #register httpconfig change event for config save method
      config.httpChange = ()->
        $scope.httpconfig =
          baseUrl : config.http.baseUrl || ''
          testfile : config.http.testfile || ''

      #******************************** init part ********************************#
      loadTestCode()

