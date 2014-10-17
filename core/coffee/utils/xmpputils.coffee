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

    @connect = ()->
      __xmpp.connect {
        jid : @jid
        password : @password
        host : @host
        port : @port
      }

      __xmpp.on 'online', (data)=>
        @connected = true
        @emit 'online' , data

      __xmpp.on 'chat' , (from, message)=>
        @emit 'chat' , from, message

      __xmpp.on 'stanza' , (stanza)=>
        @emit 'stanza' , stanza

      __xmpp.on 'error' , (error)=>
        @connected = false
        @emit 'error' , error

      __xmpp.on 'close' , ()=>
        @connected = false
        @emit 'close'

    @send = (to , message , group)->
      #message fix with empty string
      __xmpp.send to , message + ' ' , group

    @close = ()->
      if @connected
        __xmpp.disconnect()

#inherits EventEmitter class
__util.inherits simplexmpp , __events

#output
window.jTester.simplexmpp = simplexmpp