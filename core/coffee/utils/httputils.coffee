
#import jTester namespace
jTester = window.jTester
__require = jTester.require
__fs = __require.fs
__request = __require.request
__url = __require.url
__path = __require.path
__querystring = __require.querystring
__formdata = __require.formdata
__config = jTester.config
__httpconfig = __config.httpconfig
__download = jTester.download

#class http
class http
  constructor : (@$context)->
    @$http = @$context.$http || {}
    @$sce = @$context.$sce || {}
    @params = @$context.params || {}
    @headers = @params.headers || {}
    @action = @$context.action || {}
    @datahandle = @$context.datahandle || (data)-> return data

    @submitRequest = (method , json) ->
      @action.submit = true
      url = __url.resolve __httpconfig.host , "#{@params.url}"
      config = {method : method , url : url , headers: @headers, data : @params.data }
      if method == "POST"
        if json
          config.headers["Content-Type"] = "application/json"
        else
          config.transformRequest = (obj)->
            str = []
            for k , v of obj
              str.push(encodeURIComponent(k) + "=" + encodeURIComponent(v))
            return str.join '&'
          config.headers["Content-Type"] = "application/x-www-form-urlencoded"

      @$http(config).then((response) =>
        @action.submit = false
        dataType = response.headers("content-type") || ""
        if dataType.indexOf "application/json" > -1
          data = @datahandle(response.data)
          @action.result = @$sce.trustAsHtml "#{new Date().toLocaleString()} <p></p> #{new window.JSONFormatter().jsonToHTML(data)}"
        else
          @action.result = @$sce.trustAsHtml "#{new Date().toLocaleString()} <p></p> #{data}}"
        @$context.$scope.$apply()
       ,(error) =>
          @action.submit = false
          jTester.alert.error "#{url} , #{error.status} , #{error.statusText}"
      )

    @_getFileName = (cd)->
      if cd
        arr = cd.split(";")
        filename = ""
        for k in arr
          k = k.trim()
          if k.indexOf('filename') == 0
            if k.indexOf('*=') == 8
              filename = decodeURIComponent(k.replace "filename*=UTF-8''" , "")
            else
              filename = k.replace "filename=" , ""
            break
        return filename
      else
        return ""

    @_createFile = (dir , filename , ext)->
      path = __path.join dir , filename
      file = null
      if !__fs.existsSync path
        file = __fs.createWriteStream path
      else
        name = __path.basename path , ext
        i = 1
        while true
          _name = name + "(#{i++})" + ext
          path = __path.join dir , _name
          if !__fs.existsSync path
            file = __fs.createWriteStream path
            break
      return file

  get : () ->
    @submitRequest "GET"

  post : () ->
    @submitRequest "POST"

  postjson : () ->
    @submitRequest "POST" , true

  put : () ->
    @submitRequest "PUT"

  delete : () ->
    @submitRequest "DELETE"

  download : () ->
    @$context.$uibModalInstance.close 'dismiss'
    @$context.action.submit = true
    options =
      uri : __url.resolve __httpconfig.host , "#{@params.url}"
      method : "GET",
      headers : @headers
      form : @params.data

    req = __request options
    req.on 'response' , (res)=>
      filename = @_getFileName res.headers['content-disposition']
      ext = __path.extname filename
      if !filename
        filename = @params.action
      file = @_createFile @params.savefilepath , filename , ext
      if res.statusCode == 200
        res.on 'data' , (chunk) ->
          file.write chunk
        res.on 'end' , ()=>
          file.end()
          jTester.alert.success "#{file.path} 已下载完成"
          #添加到下载内容历史记录列表中
          __download.history.push {
            filename : __path.basename file.path
            link : options.uri + __querystring.stringify @params.data
            path : file.path
          }
          __download.save()
          @$context.action.submit = false
      else
        jTester.alert.error "下载出错,HTTP #{res.statusCode} #{res.statusMessage}"
        file.end()
        __fs.unlinkSync file.path
        @$context.action.submit = false

      res.on 'error' ,(e)=>
        @$context.action.submit = false
        jTester.alert.error e.message

  upload : ()->
    @action.submit = true
    #close modal
    @$context.$uibModalInstance.close 'dismiss'

    url = __url.resolve __httpconfig.host , "#{@params.url}"
    form = new __formdata()
    #form.maxDataSize = @$context.maxDataSize * 1024 * 1024 if @$context.maxDataSize

    if @params.data
      for k , v of @params.data
        form.append k , v

    if @params.files
      for file , i in @params.files
        form.append 'file' + i , __fs.createReadStream file.path

    #modify form-data source submit(parms , cb) to submit(params , headers , cb)
    form.submit url, @headers, (err , res)=>
      if err
        @action.submit = false
        jTester.alert.error err.message
      else
        if res.statusCode == 200
          dataType = res.headers["content-type"] || ''
          res.on 'data' , (chunk)=>
            @action.submit = false
            data = chunk + ''
            if dataType.indexOf "application/json" > -1
              data = JSON.parse data
              data = @datahandle(data)
              @action.result = @$sce.trustAsHtml "#{new Date().toLocaleString()} <p></p> #{new window.JSONFormatter().jsonToHTML(data)}"
            else
              @action.result = @$sce.trustAsHtml "#{new Date().toLocaleString()} <p></p> #{data}"
            @$context.$scope.$apply()
        else
          @action.submit = false
          jTester.alert.error "#{res.statusCode} #{res.statusMessage}"

#output http
window.jTester.http = http
