#import jTester namespace
jTester = window.jTester

#class UploadFileCtrl
angularapp = window.angularapp
angularapp.controller 'UploadFileCtrl' ,
  class OpenFileCtrl
    constructor : ($scope , $uibModalInstance , uiUploader , context)->
      context.$uibModalInstance = $uibModalInstance

      $scope.files = []

      $scope.change = (files)->
        console.log files

      $scope.remove = (index)->
        $scope.files.splice index , 1

      $scope.upload = ()->
        context.params.files = $scope.files
        ##new jTester.http(context).postMultipart()

      $scope.cancel = ()->
        $uibModalInstance.close 'dismiss'