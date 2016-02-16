#import jTester
jTester = window.jTester
__aes = jTester.aesutils
__config = jTester.config
__httpconfig = __config.httpconfig
__stringutils = jTester.stringutils

#ad api post request
window.dapi =
  getkeys : ()->
    return {
      client_id: __httpconfig.items["client_id"] || ""
      client_secret: __httpconfig.items["client_secret"] || ""
      api_token: __httpconfig.items["api_token"] || ""
      api_secret: __httpconfig.items["api_secret"] || ""
    }
  #decrypt data.data
  decrypt : (api_secret , data)->
    if data.data != "" && data.data != null && data.success
      data.data = jTester.aesutils.decrypt api_secret , data.data
      data.data = JSON.parse data.data
    return data
  #need client identify
  clientcall : ($context , url, plainText , decrypt)->
    that = this
    keys = that.getkeys()
    client_id = keys.client_id
    client_secret = keys.client_secret
    once = __stringutils.guid()
    timestamp = (new Date()).valueOf() + ''
    signature = "client_id=#{client_id}&client_secret=#{client_secret}&timestamp=#{timestamp}&once=#{once}&parameters=#{plainText}"
    $context.params =
      url : url
      data : {
        client_id : client_id
        timestamp :  timestamp
        once : once
        signature : __stringutils.md5(signature)
        ciphertext : jTester.aesutils.encrypt(client_secret , plainText)
      }

    if decrypt
      $context.datahandle = (data)->
        return that.decrypt(client_secret , data)

    new jTester.http($context).post()
  #need access token
  tokencall : ($context ,controller , action , plainText , decrypt)->
    that = this
    keys = that.getkeys()
    client_id = keys.client_id
    api_token = keys.api_token
    api_secret = keys.api_secret
    once = __stringutils.guid()
    timestamp = (new Date()).valueOf() + ''
    plainText = plainText
    signature = "client_id=#{client_id}&api_secret=#{api_secret}&timestamp=#{timestamp}&once=#{once}&api_token=#{api_token}&parameters=#{plainText}"
    $context.params =
      controller : controller
      action : action
      data : {
        client_id : client_id
        timestamp :  timestamp
        api_token : api_token
        once : once
        signature : __stringutils.md5(signature)
        ciphertext : jTester.aesutils.encrypt(api_secret , plainText)
      }

    if decrypt
      $context.datahandle = (data)->
        return that.decrypt(api_secret , data)

    new jTester.http($context).post()

#test metadata
window.Controllers =
  User :
    Login : ()->
      plainText = JSON.stringify {
        "password" : jTester.stringutils.md5("123456")
        "username" : "test"
      }
      window.dapi.clientcall $context , "/User/Login" , plainText , false
    UpdatePassword : ()->
      api_secret = window.dapi.getkeys().api_secret
      plainText = JSON.stringify {
        oldpassword : jTester.aesutils.encrypt(api_secret ,"123456")
        newpassword : jTester.aesutils.encrypt(api_secret ,"123456")
      }
      window.dapi.tokencall $context , "User" , "UpdatePassword" , plainText
    RetrievePassword : ()->
      plainText = JSON.stringify {
        username : ""
        email : ""
      }
      window.dapi.clientcall $context , "User" , "RetrievePassword" , plainText
    Logout : ()->
      plainText = JSON.stringify {}
      window.dapi.tokencall $context , "User" , "Logout" , plainText
  EC :
    GetBaseInfo : ()->
      plainText = JSON.stringify {}
      window.dapi.tokencall $context , "EC" , "GetBaseInfo" , plainText , true
    EditBaseInfo : ()->
      plainText = JSON.stringify {
        contactname : ""
        contactphone : ""
        provid : ""
        cityid : ""
        address : ""
        email : ""
      }
      window.dapi.tokencall $context , "EC" , "EditBaseInfo" , plainText
    GetBalance : ()->
      plainText = JSON.stringify {}
      window.dapi.tokencall $context , "EC" , "GetBalance" , plainText , true
    GetPayList : ()->
      plainText = JSON.stringify {
        begindate : ""
        enddate : ""
        usedtype : ""
        showtype : ""
        page : ""
        pagesize : ""
      }
      window.dapi.tokencall $context , "EC" , "GetPayList" , plainText , true
    AddMember : ()->
      plainText = JSON.stringify {
        name : ""
        phone : ""
        usertype : ""
        flash : ""
        flashed : ""
        hangupsms : ""
        hangupedsms : ""
      }
      window.dapi.tokencall $context , "EC" , "AddMember" , plainText
    EditMember : ()->
      plainText = JSON.stringify {
        mid : ""
        name : ""
        usertype: ""
        flash : ""
        flashed : ""
        hangupsms : ""
        hangupedsms : ""
      }
      window.dapi.tokencall $context , "EC" , "EditMember" , plainText
    DeleteMember : ()->
      plainText = JSON.stringify {
        mid : ""
      }
      window.dapi.tokencall $context , "EC" , "DeleteMember" , plainText
    GetMemberList : ()->
      plainText = JSON.stringify {
        qs : ""
        page : 1
        pagesize : 10
      }
      window.dapi.tokencall $context , "EC" , "GetMemberList" , plainText , true
    GetTaskList : ()->
      plainText = JSON.stringify {
        qs : ""
        page : 1
        pagesize : 10
      }
      window.dapi.tokencall $context , "EC" , "GetTaskList" , plainText , true
  Sys :
    Feedback : ()->
      plainText = JSON.stringify {
        feedback : ""
      }
      window.dapi.tokencall $context , "Sys" , "Feedback" , plainText
    GetNoticeList : ()->
      plainText = JSON.stringify {
        qs : ""
        page : 1
        pagesize : 10
      }
      window.dapi.tokencall $context , "Sys" , "GetNoticeList" , plainText , true
    GetNewsList : ()->
      plainText = JSON.stringify {
        qs : ""
        page : 1
        pagesize : 10
      }
      window.dapi.tokencall $context , "Sys" , "GetNewsList" , plainText , true
    GetActivityList : ()->
      plainText = JSON.stringify {
        qs : ""
        page : 1
        pagesize : 10
      }
      window.dapi.tokencall $context , "Sys" , "GetActivityList" , plainText , true
  Product :
    AddFlashInfo : ()->
      plainText = JSON.stringify {
        content : ""
        callstatus : ""
        calledstatus : ""
        isdefault : ""
        startdate : ""
        enddate : ""
        weekcycle : ""
        starttime : ""
        endtime : ""
      }
      window.dapi.tokencall $context , "Product" , "AddFlashInfo" , plainText
    EditFlashInfo : ()->
      plainText = JSON.stringify {
        flashid : ""
        content : ""
        callstatus : ""
        calledstatus : ""
        isdefault : ""
        startdate : ""
        enddate : ""
        weekcycle : ""
        starttime : ""
        endtime : ""
      }
      window.dapi.tokencall $context , "Product" , "EditFlashInfo" , plainText
    DeleteFlashInfo : ()->
      plainText = JSON.stringify {
        flashid : ""
      }
      window.dapi.tokencall $context , "Product" , "DeleteFlashInfo" , plainText
    GetFlashInfoList : ()->
      plainText = JSON.stringify {
        qs : ""
        page : 1
        pagesize : 10
      }
      window.dapi.tokencall $context , "Product" , "GetFlashInfoList" , plainText , true
    AddHangupSms : ()->
      plainText = JSON.stringify {
        content : ""
        callstatus : ""
        calledstatus : ""
        isdefault : ""
        startdate : ""
        enddate : ""
        weekcycle : ""
        starttime : ""
        endtime : ""
      }
      window.dapi.tokencall $context , "Product" , "AddHangupSms" , plainText
    EditHangupSms : ()->
      plainText = JSON.stringify {
        smsid : ""
        content : ""
        callstatus : ""
        calledstatus : ""
        isdefault : ""
        startdate : ""
        enddate : ""
        weekcycle : ""
        starttime : ""
        endtime : ""
      }
      window.dapi.tokencall $context , "Product" , "EditHangupSms" , plainText
    DeleteHangupSms : ()->
      plainText = JSON.stringify {
        smsid : ""
      }
      window.dapi.tokencall $context , "Product" , "DeleteHangupSms" , plainText
    GetHangupSmsList : ()->
      plainText = JSON.stringify {
        qs : ""
        page : 1
        pagesize : 10
      }
      window.dapi.tokencall $context , "Product" , "GetHangupSmsList" , plainText , true
    GetVoiceOutList : ()->
      plainText = JSON.stringify {
        qs : ""
        page : 1
        pagesize : 10
      }
      window.dapi.tokencall $context , "Product" , "GetVoiceOutList" , plainText , true
  Msg :
    Send : ()->
      plainText = JSON.stringify {
        recid : ""
        title : ""
        content : ""
      }
      window.dapi.tokencall $context , "Msg" , "Send" , plainText
    Delete : ()->
      plainText = JSON.stringify {
        msgid : ""
      }
      window.dapi.tokencall $context , "Msg" , "Delete" , plainText
    GetList : ()->
      plainText = JSON.stringify {
        qs : ""
        type : 0
        page : 1
        pagesize : 10
      }
      window.dapi.tokencall $context , "Msg" , "GetList" , plainText , true
  Client :
    GetLastVersion : ()->
      plainText = JSON.stringify {}
      window.dapi.clientcall $context , "Client" , "GetLastVersion" , plainText
  Shop :
    SubmitOrder : ()->
      $context.params =
        controller : "Shop"
        action : "SubmitOrder"
        data : {
          userid : "1000",
          items : JSON.stringify([
            {
              id : "10000",
              count : 3
            },
            {
              id : "10003",
              count : 4
            }
          ])
        }
      new jTester.http($context).post()
    ComfirmOrder : ()->
      $context.params =
        controller : "Shop"
        action : "ComfirmOrder"
        data : {
          orderid : "",
        }
      new jTester.http($context).post()
    GetOrderRecord : ()->
      $context.params =
        controller : "Shop"
        action : "GetOrderRecord"
        data : {
          userid : "1000",
        }
      new jTester.http($context).post()