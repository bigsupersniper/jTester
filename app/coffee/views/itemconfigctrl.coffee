#import jTester namespace
jTester = window.jTester
config = jTester.Config

#class ItemConfigCtrl
jTester.app.controller 'ItemConfigCtrl' ,
  class ItemConfigCtrl
    constructor : ($scope) ->
      #item list
      $scope.items = []
      #item config
      $scope.item = {}
      #private
      _itemconfig = {}

      #save all item config to file
      save = ()->
        config = jTester.Config
        config.items = _itemconfig
        config.save config

      $scope.set = ()->
        index = -1
        for obj , i in $scope.items
          if obj.key == $scope.item.key
            index = i
        item = { key : $scope.item.key , value : $scope.item.value }
        if index == -1
          $scope.items.push { key : $scope.item.key , value : $scope.item.value }
        else
          $scope.items[index] = item
        _itemconfig[$scope.item.key] = $scope.item.value
        $scope.item.key = ""
        $scope.item.value = ""
        save()

      $scope.reset = (index)->
        item = $scope.items[index]
        $scope.item.key = item.key
        $scope.item.value = item.value

      $scope.remove = (index)->
        item = $scope.items[index]
        delete _itemconfig[item.key]
        $scope.items.splice index , 1
        save()

      $scope.clear = ()->
        $scope.items = []
        _itemconfig = {}
        save()

      #init page
      for k , v of config.items || {}
        $scope.items.push { key : k , value : v }
      _itemconfig = config.items || {}