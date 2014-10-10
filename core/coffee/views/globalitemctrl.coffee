#import jTester namespace
jTester = window.jTester
__fs = jTester.require.fs
__config = jTester.config
__globalitems = __config.globalitems

#class GlobalItemCtrl
angularapp = window.angularapp
angularapp.controller 'GlobalItemCtrl' ,
  class GlobalItemCtrl
    constructor : ($scope , $modalInstance) ->
      items = __globalitems || {}
      $scope.items = []
      $scope.item = {}

      objToArray = ()->
        $scope.items = []
        for k , v of items
          $scope.items.push ({
            key : k
            value : v
          })

      #exec at startup
      objToArray()

      $scope.set = ()->
        items[$scope.item.key]= $scope.item.value
        objToArray()
        $scope.item.key = ""
        $scope.item.value = ""

      $scope.reset = (index)->
        item = $scope.items[index]
        $scope.item.key = item.key
        $scope.item.value = item.value

      $scope.remove = (index)->
        item = $scope.items[index]
        delete items[item.key]
        $scope.items.splice index , 1

      $scope.save = ()->
        __globalitems = items
        __config.save()
        $modalInstance.close 'success'

      $scope.cancel = ()->
        $modalInstance.close 'dismiss'
