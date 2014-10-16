#import jTester namespace
jTester = window.jTester
__require = jTester.require
__xmpp = __require.xmpp
__util = __require.util
__events = __require.events

#class simplexmpp
class simplexmpp
  constructor : (options)->
    options ?= {}
    @jid = options.jid || ''
    @password = options.password || ''
    @host = options.host || ''
    @port = options.port || 0
    @client = {}
    @connected = false

    @connect = (host , port)->
      @client = new __xmpp.connect {
        jid : @jid
        password : @password
        host : @host
        port : @port
      }
      @client.on 'online', (data)=>
        @connected = true
        @emit 'online' , data

      @client.on 'chat' , (from, message)=>
        @emit 'chat' , from, message

      @client.on 'stanza' , (stanza)=>
        @emit 'stanza' , stanza

      @client.on 'error' , (error)=>
        @connected = false
        @emit 'error' , error

    @send = (to , message , group)->
      @client.send to , message , group

    @close = ()->
      if @connected
        @client.disconnect()
        @connected = false

#inherits EventEmitter class
__util.inherits simplexmpp , __events

#output
window.jTester.clientsocket = simplexmpp