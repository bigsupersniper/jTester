#import jTester namespace
jTester = window.jTester
__url = jTester.require.url
__config = jTester.config
__httpconfig = __config.httpconfig

#class SaveFileCtrl
angularapp = window.angularapp
angularapp.controller 'SaveFileCtrl' ,
  class SaveFileCtrl
    constructor : ($scope , $uibModalInstance , context)->
      context.$uibModalInstance = $uibModalInstance
      $scope.params =
        filename  : context.params.action
        savefilepath : __httpconfig.savefilepath
        downlink : __url.resolve __httpconfig.address , "#{context.params.url}"

      $scope.change = (path)->
        $scope.params.savefilepath = path

      $scope.save = ()->
        context.params.savefilepath = $scope.params.savefilepath
        new jTester.http(context).download()

      $scope.cancel = ()->
        $uibModalInstance.close 'dismiss'