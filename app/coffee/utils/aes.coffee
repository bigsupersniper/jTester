
cryptojs = window.require './node_modules/crypto-js'

AES =
  encrypt_ecb : (key , data)->
    key = cryptojs.enc.Utf8.parse key
    data = cryptojs.enc.Utf8.parse data
    encrypted = cryptojs.AES.encrypt(data, key , {
      mode: cryptojs.mode.ECB
    })

    return encrypted.ciphertext.toString cryptojs.enc.Base64

  decrypt_ecb : (key , data )->
    key = cryptojs.enc.Utf8.parse key
    decrypted = cryptojs.AES.decrypt(data, key , {
      mode: cryptojs.mode.ECB
    })

    return decrypted.toString cryptojs.enc.Utf8

#export module
window.jTester.AES = AES
