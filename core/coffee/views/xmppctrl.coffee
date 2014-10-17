#import jTester namespace
jTester = window.jTester
__cryptojs = jTester.require.cryptojs
__aes = jTester.aesutils
__stringutils = jTester.stringutils
__config = jTester.config
__simplexmpp = jTester.simplexmpp

#class HttpCtrl
angularapp = window.angularapp
angularapp.controller 'XmppCtrl' ,
  class XmppCtrl
    constructor : ($scope , $interval) ->
      _client =
        msgs : []
        freshtimer : {}
        #update msgs every one second
        startfreshtimer : ()->
          @freshtimer = $interval ()=>
            if $scope.client.connected
              if @msgs.length > 0
                $scope.client.msgs.push @msgs.shift()
            else
              #close task
              $interval.cancel @freshtimer
          , 1000

      $scope.client =
        jid : 'bigsniper@jihe'
        password : '123456'
        host : '127.0.0.1'
        port : 5222
        to : ''
        message : ''
        connected : false
        msgs : []
        xmpp : {}
        connect : ()->
          @xmpp = new __simplexmpp {
            jid : @jid
            password : @password
            host : @host
            port : @port
          }
          @xmpp.on 'online' , (data)=>
            _client.startfreshtimer()
            @connected = @xmpp.connected
            @jid = data.jid
            @msgs.push "#{@jid} login"

          @xmpp.on 'stanza' , (stanza)->
            _client.msgs.push stanza.toString()

          @xmpp.on 'error' , (error)->
            _client.msgs.push error.message

          @xmpp.on 'close' , ()=>
            @connected = @xmpp.connected
            @msgs.push "#{@jid} logout"

          @xmpp.connect()
        send : ()->
          if @connected && @message && @to
            @xmpp.send @to , @message , false
            @msgs.push "to:#{@to} , message:#{@message}"
            @message = ''
        disconnect : ()->
          if @connected
            @xmpp.close()
        clear : ()->
          @msgs = []
