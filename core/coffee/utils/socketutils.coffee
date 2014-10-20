#import jTester namespace
jTester = window.jTester
__require = jTester.require
__net = __require.net
__util = __require.util
__events = __require.events

#class clientsocket
class clientsocket
  constructor : ()->
    @client = {}
    @connected = false

    @connect = (host , port)->
      @client = __net.connect { host : host , port : port} , ()=>
        @client.on 'data', (data)=>
          @emit 'data' , data

        @client.on 'error' , (error)=>
          @connected = false
          @emit 'error' , error

        @client.on 'end' , ()=>
          @connected = false
          @emit 'end'

        @connected = true
        @emit 'connect'

    @send = (msg)->
      @client.write msg + '\r\n'

    @close = ()->
      if @connected
        @client.end()

#inherits EventEmitter class
__util.inherits clientsocket , __events

#output
window.jTester.clientsocket = clientsocket
