#import jTester namespace
jTester = window.jTester
__cryptojs = jTester.require.cryptojs
__aes = jTester.aesutils
__stringutils = jTester.stringutils
__config = jTester.config
__globalitems = __config.globalitems
__clientsocket = jTester.clientsocket

#class HttpCtrl
angularapp = window.angularapp
angularapp.controller 'SocketCtrl' ,
  class SocketCtrl
    constructor : ($scope , $interval) ->

############################ClientSocket########################################
      _client =
        msgs : []
        task : {}
        token : __globalitems.sockettoken
        tokenkey : __globalitems.sockettokenkey
        imei : __globalitems.socketimei
        sa : ()->
          if $scope.client.socket.connected
            sha1 = __cryptojs.SHA1(@imei).toString()
            b64 = __aes.encrypt @tokenkey , sha1
            auth = "SA:#{@token}##{b64}"
            $scope.client.socket.send auth
        #update msgs every one second
        starttask : ()->
          @task = $interval ()=>
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
          , 1000

      $scope.client =
        host : '127.0.0.1'
        port : 2020
        message : ''
        connected : false
        msgs : []
        socket : new __clientsocket()
        connect : ()->
          if @host && @port
            @socket.on 'connect' , ()=>
              _client.starttask()
              _client.sa()
              @connected = @socket.connected
              _client.msgs.push "#{new Date().toLocaleString()} connect server success"

            @socket.on 'data' , (data)->
              _client.msgs.push data.toString()

            @socket.on 'error' , (error)->
              _client.msgs.push error.message

            @socket.on 'end' , ()=>
              @connected = @socket.connected
              #close task
              $interval.cancel _client.task
              _client.msgs.push "#{new Date().toLocaleString()} disconnect from server"

            @socket.connect @host , @port
        send : ()->
          if @connected && @message && @message.length > 0
            @socket.send @message
        disconnect : ()->
          if @connected
            @socket.close()
        clear : ()->
          @msgs = []

############################ComponentSocket########################################
      _component =
        msgs : []
        task : {}
        key : __globalitems.componentkey
        password : __globalitems.componentpassword
        handshake : ()->
          if $scope.component.socket.connected
            sha1 = __cryptojs.SHA1(@password).toString()
            b64 = __aes.encrypt @key , sha1
            auth = "HANDSHAKE:#{b64}"
            $scope.component.socket.send auth
        #update msgs every one second
        starttask : ()->
          @task = $interval ()=>
            if @msgs.length > 0
              msg = @msgs.shift()
              $scope.component.msgs.push msg
          , 1000

      $scope.component =
        host : '127.0.0.1'
        port : 2025
        message : ''
        msgs : []
        connected : false
        socket : new __clientsocket()
        connect : ()->
          if @host && @port
            @socket.on 'connect' , ()=>
              _component.starttask()
              _component.handshake()
              @connected = @socket.connected
              _component.msgs.push "#{new Date().toLocaleString()} connect server success"

            @socket.on 'data' , (data)->
              _component.msgs.push data.toString()

            @socket.on 'error' , (error)->
              _component.msgs.push error.message

            @socket.on 'end' , ()=>
              @connected = @socket.connected
              _component.msgs.push "#{new Date().toLocaleString()} disconnect from server"

            @socket.connect @host , @port
        deliver : ()->
          date = new Date()
          msg = JSON.stringify {
            senderid : Math.round(Math.random() * 10),
            receiverid : 2,
            logid : Math.round(Math.random() * 10000),
            status : Math.round(Math.random() * 10) % 2,
            name : __stringutils.random(10),
            ismute : Math.round(Math.random() * 10) % 2 == 0,
            memo : __stringutils.random(20),
            time : date.getFullYear() + "-" + (date.getMonth() + 1) + "-" + date.getDate() + " " + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds()
          }
          encrypt = __aes.encrypt _component.key , msg
          encrypt = "DELIVER:" + encrypt
          _component.msgs.push encrypt
          @socket.send encrypt
        send : ()->
          if @connected && @message && @message.length > 0
            @socket.send @message
        disconnect : ()->
          if @connected
            @socket.close()
        clear : ()->
          @msgs = []