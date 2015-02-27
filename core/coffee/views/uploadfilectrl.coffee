#import jTester namespace
jTester = window.jTester

#class UploadFileCtrl
angularapp = window.angularapp
angularapp.controller 'UploadFileCtrl' ,
  class OpenFileCtrl
    constructor : ($scope , $modalInstance , context)->
      context.$modalInstance = $modalInstance
      $scope.files = []
      $scope.change = (file)->
        $scope.files.push file

      $scope.remove = (index)->
        $scope.files.splice index , 1

      $scope.upload = ()->
        context.params.files = $scope.files
        new jTester.http(context).postMultipart()

      $scope.cancel = ()->
        $modalInstance.close 'dismiss'