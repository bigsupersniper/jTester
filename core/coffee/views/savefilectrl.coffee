#import jTester namespace
jTester = window.jTester
__url = jTester.require.url
__config = jTester.config
__baseitems = __config.baseitems

#class SaveFileCtrl
angularapp = window.angularapp
angularapp.controller 'SaveFileCtrl' ,
  class SaveFileCtrl
    constructor : ($scope , $modalInstance , context)->
      context.$modalInstance = $modalInstance
      $scope.params =
        filename  : context.params.action
        savefilepath : __baseitems.savefilepath
        downlink : __url.resolve __baseitems.address , "/#{context.params.controller}/#{context.params.action}"

      $scope.change = (path)->
        $scope.params.savefilepath = path

      $scope.save = ()->
        context.params.savefilepath = $scope.params.savefilepath
        new jTester.http(context).down()

      $scope.cancel = ()->
        $modalInstance.close 'dismiss'