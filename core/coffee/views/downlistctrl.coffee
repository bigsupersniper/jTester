#import jTester namespace
jTester = window.jTester
__require = jTester.require
__nw = __require.nw
__fs = __require.fs
__download = jTester.download
__fileutils = jTester.fileutils

#class DownlistCtrl
angularapp = window.angularapp
angularapp.controller 'DownlistCtrl' ,
  class DownlistCtrl
    constructor : ($scope , $modalInstance)->
      $scope.items = __download.history

      $scope.showItemInFolder = (path)->
        if __fs.existsSync path
          __nw.Shell.showItemInFolder path
        else
          jTester.alert.error '文件已删除'

      $scope.remove = (index)->
        $scope.items.splice index , 1
        __download.save()

      $scope.delete = (index)->
        file = $scope.items.splice index , 1
        __download.save()
        __fileutils.unlinkSync file[0].path

      $scope.clear = ()->
        __download = []
        $scope.items = []
        __download.save()

      $scope.cancel = ()->
        $modalInstance.close 'dismiss'