


def =
  #http context define
  httpContext :
    url : "" #full http url
    baseUrl : "" #fully qualified uri string used as the base url
    uri : "" #fully qualified uri
    data : {} #object containing querystring values or formdata key-vaalue pair
    files : [] #upload file path arrays
    ref : {} #views item object ref
    $http : {}#argularjs inject object
    $sce : {}#argularjs inject object
    $scope : {}#argularjs inject object
    $uibModalInstance : {} #argularjs inject object
    beforeSend : ()-> #before http request submit callback
    complete : (response , body)-> #http success response callback
    error : (err , response)-> #error when http request/response callback
  #global config define
  config :
    http :
      baseUrl : "" #fully qualified uri string used as the base url
      testfile : "" #main test file path
    items : { } #global key-value pair
    init : ()->
    save : (config)->
  #view tab define
  tab :
    name : "" #tab name
    items : [
      {
        name : "" #tab item name
        url : "" #full http url
        baseUrl : "" #fully qualified uri string used as the base url
        uri : ""  #fully qualified uri
        text : "" #main textarea content
        rows : 0 #textarea rows
        submited : true
        beforeSubmit : (context)->
        submit : ()->
        result : "" #item result
      }
    ]