
cryptojs = window.require './node_modules/crypto-js'
uuid = window.require './node_modules/node-uuid/uuid'

String =
  createRandomString : (len)->
    x = "0123456789abcefghijklmnopqrstuvwxyzABCEFGHIJKLMNOPQRSTUVWXYZ"
    temp = ''
    while len >= 0
      temp  +=  x.charAt( Math.ceil( Math.random() * 100000000 )% x.length )
      len--
    return temp
  computeMD5 : (str)->
    return cryptojs.MD5(str).toString(cryptojs.enc.Hex)
  getUUID : ()->
    return uuid.v4().replace(/-/g , "")

#export module
window.jTester.String = String