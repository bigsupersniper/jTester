#import jTester namespace
jTester = window.jTester

#class UploadFileCtrl
jTester.app.controller 'UploadFileCtrl' ,
  class OpenFileCtrl
    constructor : ($scope , $uibModalInstance , context)->
      $scope.files = []
      context.$uibModalInstance = $uibModalInstance

      $scope.change = (file)->
        if file
          $scope.files.push file
          $scope.$apply()

      $scope.remove = (index)->
        $scope.files.splice index , 1

      $scope.upload = ()->
        context.files = []
        for file in $scope.files
          context.files.push file.path
        jTester.HttpRequest.upload(context)

      $scope.cancel = ()->
        $uibModalInstance.close 'dismiss'