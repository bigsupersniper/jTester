#import jTester namespace
jTester = window.jTester
nw = window.require 'nw.gui'

#class IndexCtrl
jTester.app.controller 'IndexCtrl' ,
  class IndexCtrl
    constructor : ($scope ,$uibModal , $timeout , $location) ->
      $scope.loading = true
      $timeout ()->
        $scope.loading = false
      , 1500

      #******************************** alert notify part ********************************#
      $scope.alert =
        show : (type , message , timeout)->
          timeout = timeout || 3000
          $uibModal.open {
            templateUrl : jTester.app.templateUrls.alert
            backdrop : 'center'
            resolve : {
              message : ()->
                return message
              type : ()->
                return type
              timeout : ()->
                return timeout
            }
            controller: ($scope , $uibModalInstance , $timeout , message , type, timeout)->
              $scope.message = message
              $scope.type = type
              $timeout ()->
                $uibModalInstance.close 'dismiss'
              , timeout
          }
        success : (message , timeout)->
          @show('success' , message, timeout)
        error : (message, timeout)->
          @show('danger' , message, timeout)

      #******************************** file upload part ********************************#
      $scope.openFileUpload = (context)->
          $uibModal.open {
            templateUrl: jTester.app.templateUrls.upload
            backdrop : 'static'
            resolve :{
              context : ()->
                return context
            }
            controller : 'UploadFileCtrl'
          }

      #******************************** menubar part ********************************#
      createMenubar = ()->
        $scope.navigate = [ 'Run' , 'HTTP']
        #redirect url
        redirect = (path)->
          $location.path path
          $scope.$apply()

        menus = [
          {
            label : '  DevTools  '
            click : ()->
              nw.Window.get().showDevTools()
          }
          {
            label : '  Restart  '
            click : ()->
              #Clear the HTTP cache in memory and the one on disk
              nw.App.clearCache()
              nw.Window.get().hide()
              child_process = require 'child_process'
              child = child_process.spawn(process.execPath, [], {
                detached: true
              })
              child.unref()
              nw.App.quit()
          }
          {
            label : '  Quit  '
            click : ()->
              nw.App.quit()
          }
          {
            label : '  HTTP  '
            click : ()->
              $scope.navigate = [ 'Run' , 'HTTP']
              redirect '/http'
          }
          {
            label : '  JSON  '
            click : ()->
              $scope.navigate = [ 'Run' , 'JSON']
              redirect '/json'
          }
          {
            label : '  About  '
            click : ()->
              $uibModal.open {
                templateUrl: jTester.app.templateUrls.about
                backdrop : 'center'
                controller : ($scope)->
                  $scope.open = (url)->
                    if url
                      nw.Shell.openExternal(url)

                  $scope.versions = [
                    { title : "Chromium", value : process.versions['chromium'] , url : ''}
                    { title : "Node-Webkit", value : process.versions['node-webkit'] , url : 'https://github.com/rogerwang/node-webkit'}
                    { title : "Node", value : process.versions['node'] , url : 'https://nodejs.org/'}
                    { title : "Ace", value : "v1.2.3" , url : 'https://ace.c9.io/#nav=about'}
                    { title : "ArgularJS", value : "v1.4.8" , url : 'https://angularjs.org/'}
                    { title : "Angular-ui-Bootstrap", value : "v0.14.3" , url : 'http://angular-ui.github.io/bootstrap/'}
                    { title : "ui-ace", value : "v0.2.3" , url : 'https://github.com/angular-ui/ui-ace'}
                    { title : "bootstrap css", value : "v3.2.0" , url : 'http://getbootstrap.com/'}
                    { title : "cryptojs", value : "v3.1.5" , url : 'https://github.com/evanvosberg/crypto-js'}
                    { title : "coffee-script", value : "v1.10.0" , url : 'http://coffeescript.org/'}
                    { title : "node-uuid", value : "v1.4.7" , url : ''}
                    { title : "request", value : "v2.74.0" , url : ''}
                    { title : "dateformat", value : "v1.0.12" , url : ''}
                  ]
              }
          }
        ]

        #menubar
        menubar = new nw.Menu { type: 'menubar' }

        #file menu
        filemenu = new nw.MenuItem { label : '  File  ' }
        subfilemenu = new nw.Menu()
        for m in menus[0..2]
          subfilemenu.append new nw.MenuItem { label : m.label , click : m.click }
        filemenu.submenu = subfilemenu

        #test menu
        testmenu = new nw.MenuItem { label : '  Run  ' }
        subtestmenu = new nw.Menu()
        for m in menus[3..4]
          subtestmenu.append new nw.MenuItem { label : m.label , click : m.click }
        testmenu.submenu = subtestmenu

        #help menu
        helpmenu = new nw.MenuItem { label : '  Help  ' }
        subhelpmenu = new nw.Menu()
        for m in menus[5..5]
          subhelpmenu.append new nw.MenuItem { label : m.label , click : m.click }
        helpmenu.submenu = subhelpmenu

        #final append
        menubar.append filemenu
        menubar.append testmenu
        menubar.append helpmenu
        nw.Window.get().menu = menubar

      #******************************** init part ********************************#
      createMenubar()