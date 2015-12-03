#import jTester namespace
jTester = window.jTester

#class HttpCtrl
jTester.app.controller 'JsonCtrl' ,
  class JsonCtrl
    constructor : ($scope , $sce) ->
      $scope.data =
        json : ''
        result : ''

      $scope.parse = ()->
        try
          #第一次除去转义字符
          json = JSON.parse $scope.data.json
          #第二次转为Json对象
          json = JSON.parse json
          $scope.data.result = $sce.trustAsHtml new window.JSONFormatter().jsonToHTML(json)
        catch
          jTester.alert.error 'invaild json string'