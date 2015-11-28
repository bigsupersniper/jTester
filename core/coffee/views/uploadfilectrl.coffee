#import jTester namespace
jTester = window.jTester

#class UploadFileCtrl
angularapp = window.angularapp
angularapp.controller 'UploadFileCtrl' ,
  class OpenFileCtrl
    constructor : ($scope , $uibModalInstance , $log, context)->
      context.$uibModalInstance = $uibModalInstance
      context.$scope = $scope
      $scope.files = []

      $scope.change = (file)->
        if file
          $scope.files.push file
          $scope.$apply()

      $scope.remove = (index)->
        $scope.files.splice index , 1

      $scope.upload = ()->
        context.params.files = $scope.files
        new jTester.http(context).upload()

      $scope.cancel = ()->
        $uibModalInstance.close 'dismiss'