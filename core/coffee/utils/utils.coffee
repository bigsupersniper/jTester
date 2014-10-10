#import jTester namespace
jTester = window.jTester
__require = jTester.require
__uuid = __require.uuid
__fs = __require.fs
__path = __require.path

#aes
aesutils =
  encrypt : (key , data, mode)->
    key = CryptoJS.enc.Utf8.parse key
    data = CryptoJS.enc.Utf8.parse data
    mode = mode || CryptoJS.mode.ECB
    encrypted = CryptoJS.AES.encrypt(data, key , {
      mode: mode
    })

    return encrypted.ciphertext.toString CryptoJS.enc.Base64

  decrypt : (key , data , mode)->
    key = CryptoJS.enc.Utf8.parse key
    mode = mode || CryptoJS.mode.ECB
    decrypted = CryptoJS.AES.decrypt(data, key , {
      mode: mode
    })

    return decrypted.toString(CryptoJS.enc.Utf8)

#stringutils
stringutils =
  random : (len)->
    x = "0123456789abcefghijklmnopqrstuvwxyzABCEFGHIJKLMNOPQRSTUVWXYZ"
    temp = ''
    while len >= 0
      temp  +=  x.charAt( Math.ceil( Math.random() * 100000000 )% x.length )
      len--
    return temp
  md5 : (str)->
    return CryptoJS.MD5(str + '').toString(CryptoJS.enc.Hex)
  guid : ()->
    return __uuid.v4().replace(/-/g , "")

#fileutils
fileutils =
  showItemInFolder : (path)->
    __nw.Shell.showItemInFolder(path)
  unlinkSync : (path)->
    if __fs.existsSync path
      __fs.unlinkSync path
  extname : (file)->
    return __path.extname file

#output
window.jTester.aesutils = aesutils
window.jTester.stringutils = stringutils
window.jTester.fileutils = fileutils