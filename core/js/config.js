// Generated by CoffeeScript 1.7.1
(function() {
  var FormData, HTTP, Path, QueryString, URL, app, config, downlist, e, fs, nw, rootdir;

  nw = require('nw.gui');

  fs = require('fs');

  Path = require('path');

  QueryString = require('querystring');

  URL = require('url');

  HTTP = require('http');

  FormData = require('./node_modules/form-data');

  rootdir = "./core";

  process.on('uncaughtException', function(err) {
    return alert(err.message);
  });

  window.jTester = {};

  window.jTester.config = {};

  window.jTester.alert = {};

  window.jTester.file = {};

  window.jTester.downlist = [];

  try {
    config = fs.readFileSync(rootdir + '/config.json', {
      encoding: "utf-8"
    });
    if (config) {
      jTester.config = JSON.parse(config);
      if (!jTester.config.headers) {
        jTester.config.headers = {};
      }
      if (!jTester.config.defaultPath) {
        jTester.config.defaultPath = "D:\\";
      }
    }
    downlist = fs.readFileSync(rootdir + '/download.json', {
      encoding: "utf-8"
    });
    if (downlist) {
      jTester.downlist = JSON.parse(downlist);
    }
  } catch (_error) {
    e = _error;
    jTester.config = {
      headers: {},
      host: "",
      defaultPath: "D:\\"
    };
    alert(e.message);
  }

  window.jTester.global = {
    URL: URL,
    fileExistsSync: function(path) {
      return fs.existsSync(path);
    },
    saveConfig: function() {
      try {
        config = JSON.stringify(window.jTester.config);
        return fs.writeFileSync(rootdir + '/config.json', config, {
          encoding: "utf-8"
        });
      } catch (_error) {
        e = _error;
        return alert(e.message);
      }
    },
    saveDownlist: function() {
      try {
        downlist = JSON.stringify(window.jTester.downlist);
        return fs.writeFileSync(rootdir + '/download.json', downlist, {
          encoding: "utf-8"
        });
      } catch (_error) {
        e = _error;
        return alert(e.message);
      }
    },
    showItemInFolder: function(path) {
      return nw.Shell.showItemInFolder(path);
    },
    showDevTools: function() {
      return nw.Window.get().showDevTools();
    },
    templateUrls: {
      about: rootdir + "/views/about.html",
      config: rootdir + "/views/config.html",
      alert: rootdir + "/views/alert.html",
      file: rootdir + "/views/file.html",
      savefile: rootdir + "/views/savefile.html",
      downloadlist: rootdir + "/views/downloadlist.html"
    }
  };

  app = angular.module('jTester', ['ui.bootstrap']);

  app.run(function($templateCache) {
    $templateCache.put(jTester.global.templateUrls.about, fs.readFileSync(jTester.global.templateUrls.about, {
      encoding: "utf-8"
    }));
    $templateCache.put(jTester.global.templateUrls.config, fs.readFileSync(jTester.global.templateUrls.config, {
      encoding: "utf-8"
    }));
    $templateCache.put(jTester.global.templateUrls.alert, fs.readFileSync(jTester.global.templateUrls.alert, {
      encoding: "utf-8"
    }));
    $templateCache.put(jTester.global.templateUrls.file, fs.readFileSync(jTester.global.templateUrls.file, {
      encoding: "utf-8"
    }));
    $templateCache.put(jTester.global.templateUrls.savefile, fs.readFileSync(jTester.global.templateUrls.savefile, {
      encoding: "utf-8"
    }));
    return $templateCache.put(jTester.global.templateUrls.downloadlist, fs.readFileSync(jTester.global.templateUrls.downloadlist, {
      encoding: "utf-8"
    }));
  });

  window.jTester.http = (function() {
    function http($context) {
      this.$context = $context;
      this.$http = $context.$http || {};
      this.$sce = $context.$sce || {};
      this.params = $context.params || {};
      this.action = $context.action || {};
      this.execProxy = function(method) {
        var url;
        this.action.submit = true;
        url = URL.resolve(jTester.config.host, "/" + this.params.controller + "/" + this.params.action + "/");
        return this.$http({
          method: method,
          url: url,
          headers: jTester.config.headers,
          params: this.params.data
        }).success((function(_this) {
          return function(data, status, headers, config) {
            var dataType;
            _this.action.submit = false;
            dataType = headers("content-type") || "";
            if (dataType.indexOf("application/json" > -1)) {
              return _this.action.result = _this.$sce.trustAsHtml("" + (new Date().toLocaleString()) + " <p></p> " + (new JSONFormatter().jsonToHTML(data)));
            } else {
              return _this.action.result = _this.$sce.trustAsHtml("" + (new Date().toLocaleString()) + " <p></p> " + data + "}");
            }
          };
        })(this)).error((function(_this) {
          return function(data, status, headers, config) {
            _this.action.submit = false;
            return jTester.alert.error("" + url + " , 请求失败");
          };
        })(this));
      };
      this.getFileName = function(cd) {
        var arr, filename, k, _i, _len;
        if (cd) {
          arr = cd.split(";");
          filename = "";
          for (_i = 0, _len = arr.length; _i < _len; _i++) {
            k = arr[_i];
            k = k.trim();
            if (k.indexOf('filename') === 0) {
              if (k.indexOf('*=') === 8) {
                filename = decodeURIComponent(k.replace("filename*=UTF-8''", ""));
              } else {
                filename = k.replace("filename=", "");
              }
              break;
            }
          }
          return filename;
        } else {
          return "";
        }
      };
      this.createFile = function(dir, filename, ext) {
        var file, i, name, path, _name;
        path = Path.join(dir, filename);
        file = null;
        if (!fs.existsSync(path)) {
          file = fs.createWriteStream(path);
        } else {
          name = Path.basename(path, ext);
          i = 1;
          while (true) {
            _name = name + ("(" + (i++) + ")") + ext;
            path = Path.join(dir, _name);
            if (!fs.existsSync(path)) {
              file = fs.createWriteStream(path);
              break;
            }
          }
        }
        return file;
      };
    }

    http.prototype.get = function() {
      return this.execProxy("GET");
    };

    http.prototype.post = function() {
      return this.execProxy("POST");
    };

    http.prototype.put = function() {
      return this.execProxy("PUT");
    };

    http.prototype["delete"] = function() {
      return this.execProxy("DELETE");
    };

    http.prototype.down = function() {
      var options, url, urlobj;
      url = "/" + this.params.controller + "/" + this.params.action;
      urlobj = URL.parse(jTester.config.host);
      options = {
        host: urlobj.hostname,
        port: urlobj.port || 80,
        method: "GET",
        path: url + QueryString.stringify(this.params.data),
        headers: jTester.config.headers
      };
      this.$context.$modalInstance.close('dismiss');
      this.$context.action.submit = true;
      return HTTP.get(options, (function(_this) {
        return function(res) {
          var ext, file, filename;
          filename = _this.getFileName(res.headers['content-disposition']);
          ext = Path.extname(filename);
          if (!filename) {
            filename = _this.params.action;
          }
          file = _this.createFile(_this.params.downdir, filename, ext);
          if (res.statusCode === 200) {
            res.on('data', function(chunk) {
              return file.write(chunk);
            }).on('end', function() {
              file.end();
              jTester.alert.success("" + file.path + " 已下载完成");
              jTester.downlist.push({
                filename: Path.basename(file.path),
                link: URL.resolve(jTester.config.host, options.path),
                path: file.path
              });
              jTester.global.saveDownlist();
              return _this.$context.action.submit = false;
            });
          } else {
            jTester.alert.error("下载出错,HTTP " + res.statusCode);
            file.end();
            fs.unlinkSync(file.path);
            _this.$context.action.submit = false;
          }
          return res.on('error', function(e) {
            _this.$context.action.submit = false;
            return jTester.alert.error(e.message);
          });
        };
      })(this));
    };

    http.prototype.upload = function() {
      var file, form, i, k, url, v, _i, _len, _ref, _ref1;
      form = new FormData();
      if (this.params.data) {
        _ref = this.params.data;
        for (k in _ref) {
          v = _ref[k];
          form.append(k, v);
        }
      }
      if (this.params.files) {
        _ref1 = this.params.files;
        for (i = _i = 0, _len = _ref1.length; _i < _len; i = ++_i) {
          file = _ref1[i];
          form.append('file' + i, fs.createReadStream(file));
        }
      }
      this.action.submit = true;
      this.$context.$modalInstance.close('dismiss');
      url = URL.resolve(jTester.config.host, "/" + this.params.controller + "/" + this.params.action + "/");
      return form.submit(url, jTester.config.headers, (function(_this) {
        return function(err, res) {
          var dataType;
          if (err) {
            _this.action.submit = false;
            return jTester.alert.error(err.message);
          } else {
            dataType = res.headers["content-type"] || '';
            return res.on('data', function(chunk) {
              var data;
              _this.action.submit = false;
              data = chunk + '';
              if (dataType.indexOf("application/json" > -1)) {
                data = JSON.parse(data);
                return _this.action.result = _this.$sce.trustAsHtml("" + (new Date().toLocaleString()) + " <p></p> " + (new JSONFormatter().jsonToHTML(data)));
              } else {
                return _this.action.result = _this.$sce.trustAsHtml("" + (new Date().toLocaleString()) + " <p></p> " + data);
              }
            });
          }
        };
      })(this));
    };

    return http;

  })();

}).call(this);

//# sourceMappingURL=config.map