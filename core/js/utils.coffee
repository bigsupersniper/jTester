

window.jTester.AES =
  encrypt : (key , data)->
    key = CryptoJS.enc.Utf8.parse key
    data = CryptoJS.enc.Utf8.parse data

    encrypted = CryptoJS.AES.encrypt(data, key , {
      mode: CryptoJS.mode.ECB
    })

    return encrypted.ciphertext.toString CryptoJS.enc.Base64

  decrypt : (key , data)->
    key = CryptoJS.enc.Utf8.parse key

    decrypted = CryptoJS.AES.decrypt(data, key , {
      mode: CryptoJS.mode.ECB
    })

    return decrypted.toString(CryptoJS.enc.Utf8)

window.jTester.utils =
  getRandomString : (l)->
    x = "0123456789abcefghijklmnopqrstuvwxyzABCEFGHIJKLMNOPQRSTUVWXYZ"
    temp = ''
    while l >= 0
      temp  +=  x.charAt( Math.ceil( Math.random() * 100000000 )% x.length )
      l--
    return temp
  getMd5Hash : (str)->
    return CryptoJS.MD5(str + '').toString(CryptoJS.enc.Hex)
