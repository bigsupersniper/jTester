#import jTester namespace
jTester = window.jTester
__require = jTester.require
__dateformat = __require.dateformat
__cryptojs = jTester.require.cryptojs
__aes = jTester.aesutils
__stringutils = jTester.stringutils
__config = jTester.config
__socketconfig = __config.socketconfig
__clientsocket = jTester.clientsocket


#class HttpCtrl
angularapp = window.angularapp
angularapp.controller 'SocketCtrl' ,
  class SocketCtrl
    constructor : ($scope , $interval) ->
############################SocketConfig########################################
      $scope.items = []
      $scope.item = {}
      items = __socketconfig.items || {}

      objToArray = ()->
        $scope.items = []
        for k , v of items
          $scope.items.push ({
            key : k
            value : v
          })

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

      $scope.saveall = ()->
        __socketconfig.items = items
        __config.save()
        jTester.alert.success '保存成功'

############################ClientSocket########################################
      _client =
        msgs : []
        freshtimer : {}
        token : __socketconfig.items.sockettoken
        tokenkey : __socketconfig.items.sockettokenkey
        imei : __socketconfig.items.socketimei
        sa : ()->
          if $scope.client.socket.connected
            sha1 = __cryptojs.SHA1(@imei).toString()
            b64 = __aes.encrypt @tokenkey , sha1
            auth = "SA:#{@token}##{b64}"
            $scope.client.socket.send auth
        #update msgs every one second
        startfreshtimer : ()->
          @freshtimer = $interval ()=>
            if $scope.client.socket.connected
              if @msgs.length > 0
                msg = @msgs.shift()
                #decrypt when indexof 'push'
                if msg.indexOf('PUSH:') > -1
                  #remove '\r\n'
                  msg = msg.replace '\r\n' , ''
                  descrypt = __aes.decrypt @tokenkey , msg.substring(msg.indexOf(':') + 1)
                  if descrypt
                    msg = "PUSH:" + descrypt
                $scope.client.msgs.push msg
            else
              #close task
              $interval.cancel @freshtimer
          , 1000

      $scope.client =
        host : __socketconfig.items.clienthost || '127.0.0.1'
        port : parseInt __socketconfig.items.clientport || 0
        message : ''
        connected : false
        msgs : []
        socket : new __clientsocket()
        connect : ()->
          if @host && @port
            @socket.on 'connect' , ()=>
              _client.startfreshtimer()
              _client.sa()
              @connected = @socket.connected
              @msgs.push "client connect server success"

            @socket.on 'data' , (data)->
              _client.msgs.push data.toString()

            @socket.on 'error' , (error)=>
              @connected = @socket.connected
              _client.msgs.push error.message

            @socket.on 'end' , ()=>
              @connected = @socket.connected
              @msgs.push "client disconnect from server"

            @socket.connect @host , @port
        send : ()->
          if @connected && @message && @message.length > 0
            @socket.send @message
            @msgs.push "send:#{@message}"
            @message = ''
        disconnect : ()->
          if @connected
            @socket.close()
        clear : ()->
          @msgs = []

############################ComponentSocket########################################
      _component =
        msgs : []
        freshtimer : {}
        key : __socketconfig.items.componentkey
        password : __socketconfig.items.componentpassword
        handshake : ()->
          if $scope.component.socket.connected
            sha1 = __cryptojs.SHA1(@password).toString()
            b64 = __aes.encrypt @key , sha1
            auth = "HANDSHAKE:#{b64}"
            $scope.component.socket.send auth
        #update msgs every one second
        startfreshtimer : ()->
          @freshtimer = $interval ()=>
            if $scope.component.socket.connected
              if @msgs.length > 0
                $scope.component.msgs.push @msgs.shift()
            else
              #close task
              $interval.cancel @freshtimer
          , 1000
        delivertimer : {}
        deliver : ()->
          msg = JSON.stringify {
            senderid : Math.round(Math.random() * 10),
            receiverid : 2,
            logid : Math.round(Math.random() * 10000),
            status : Math.round(Math.random() * 10) % 2,
            name : __stringutils.random(10),
            ismute : Math.round(Math.random() * 10) % 2 == 0,
            memo : __stringutils.random(20),
            time : __dateformat(new Date(), 'yyyy-mm-dd HH:MM:ss')
          }
          encrypt = __aes.encrypt _component.key , msg
          encrypt = "DELIVER:" + encrypt
          _component.msgs.push encrypt
          $scope.component.socket.send encrypt

      $scope.component =
        host : __socketconfig.items.componenthost || '127.0.0.1'
        port : parseInt __socketconfig.items.componentport || 0
        message : ''
        time : 5000
        timerstarted : false
        msgs : []
        connected : false
        socket : new __clientsocket()
        connect : ()->
          if @host && @port
            @socket.on 'connect' , ()=>
              _component.startfreshtimer()
              _component.handshake()
              @connected = @socket.connected
              @msgs.push "component connect server success"

            @socket.on 'data' , (data)->
              _component.msgs.push data.toString()

            @socket.on 'error' , (error)=>
              @connected = @socket.connected
              _component.msgs.push error.message

            @socket.on 'end' , ()=>
              @connected = @socket.connected
              @msgs.push "component disconnect from server"
              console.log @msgs

            @socket.connect @host , @port
        starttimer : ()->
          @stoptimer()
          _component.delivertimer = $interval ()=>
            if @connected
              _component.deliver()
            else
              @stoptimer()
          , @time
          @timerstarted = true
        stoptimer : ()->
          if _component.delivertimer
            $interval.cancel _component.delivertimer
            @timerstarted = false
        send : ()->
          if @connected && @message && @message.length > 0
            @socket.send @message
            @msgs.push "send:#{@message}"
            @message = ''
        disconnect : ()->
          if @connected
            @socket.close()
        clear : ()->
          @msgs = []