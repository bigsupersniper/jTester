#import jTester namespace
jTester = window.jTester
config = jTester.Config

#class HttpCtrl
jTester.app.controller 'HttpCtrl' ,
  class HttpCtrl
    constructor : ($scope , $http , $sce) ->

      $scope.tabs = []
      $scope.aceOptions =
        mode : 'json',
        useWrapMode : true
        showGutter: true
        theme:'tomorrow_night_eighties'

      $scope.createTabs = ()->
        tabs = []
        for tb , items of window.UnitTests
          tab =
            name : tb
            items : []
          for n , fn of items
            text = (JSON.stringify fn.data || {} , null , 3)
            match = text.match(/\n/gi)
            #textarea rows
            rows = 2
            if Array.isArray match
              rows = match.length + 2
            #init item
            item =
              name : n
              text : text
              rows : rows
              submited : false
              httpSubmit : fn.submit
              beforeSubmit : fn.beforeSubmit

            #init context (do not use context alone)
            item.context =
              $http : $http
              $sce : $sce
              $scope : $scope
              ref : item
              url : fn.url
              baseUrl : fn.baseUrl
              uri : fn.uri
            #item click
            item.submit = ()->
              @context.data = JSON.parse @text
              if typeof @beforeSubmit == "function"
                @beforeSubmit @context
              @httpSubmit @context

            #add item
            tab.items.push item
          #add tab
          tabs.push tab
        $scope.tabs = tabs

      #******************************** defaultHttpHandler part ********************************#
      $scope.defaultHttpHandler =
        beforeSend : (context)->
          if context.ref
            context.ref.submited = true
          if context.$uibModalInstance
            context.$uibModalInstance.close 'dismiss'

        complete : (context, response , body)->
          if context.ref && context.$sce
            context.ref.submited = false
            dataType = response.headers["content-type"] || ""
            if dataType.indexOf "application/json" > -1
              if typeof body == "string"
                body = JSON.parse body
              context.ref.result = context.$sce.trustAsHtml "#{new Date().toLocaleString()}
                  <p></p> #{new window.JSONFormatter().jsonToHTML(body)}"
            else
              context.ref.result = context.$sce.trustAsHtml "#{new Date().toLocaleString()} <p></p> #{body}"
            context.$scope.$apply()

        error : (context, err , response)->
          if context.ref
            context.ref.submited = false
            if err != null && typeof err == "object"
              context.ref.result = context.$sce.trustAsHtml "#{new Date().toLocaleString()}
                      <p></p> #{new window.JSONFormatter().jsonToHTML(err)}"
            else
              context.ref.result = context.$sce.trustAsHtml "#{new Date().toLocaleString()}
                      <p></p> #{response.statusCode} #{response.statusMessage}"
            context.$scope.$apply()

      #******************************** init part ********************************#
      window.require config.http.testfile
      $scope.createTabs()
