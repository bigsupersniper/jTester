// Generated by CoffeeScript 1.6.3
(function() {
  window.IndexCtrl = (function() {
    function IndexCtrl($scope, $http, $modal, $sce) {
      var openOptions, resolve;
      $scope.menus = [
        {
          title: "设置",
          click: function() {
            return openOptions();
          }
        }
      ];
      jTester.alert = {
        show: function(type, message) {
          return $modal.open({
            template: '<alert type="type" style="text-align: center ; margin-bottom : 0px">{{ message }}</alert>',
            backdrop: 'center',
            resolve: {
              message: function() {
                return message;
              },
              type: function() {
                return type;
              }
            },
            controller: function($scope, $modalInstance, $timeout, message, type) {
              $scope.message = message;
              $scope.type = type;
              return $timeout(function() {
                return $modalInstance.close('dismiss');
              }, 2000);
            }
          });
        },
        success: function(message) {
          return this.show('success', message);
        },
        error: function(message) {
          return this.show('danger', message);
        }
      };
      jTester.file.openFile = function($context) {
        return $modal.open({
          templateUrl: jTester.global.templateUrls.file,
          backdrop: 'static',
          resolve: {
            context: function() {
              return $context;
            }
          },
          controller: 'OpenFileCtrl'
        });
      };
      jTester.file.saveFile = function($context) {
        return $modal.open({
          templateUrl: jTester.global.templateUrls.savefile,
          backdrop: 'static',
          resolve: {
            context: function() {
              return $context;
            }
          },
          controller: 'SaveFileCtrl'
        });
      };
      $scope.showDevTools = function() {
        return jTester.global.showDevTools();
      };
      $scope.tabs = [];
      resolve = function(obj) {
        var $context, ak, av, ck, cv, tab, _results;
        if (obj == null) {
          obj = {};
        }
        $context = {
          $http: $http,
          $sce: $sce
        };
        _results = [];
        for (ck in obj) {
          cv = obj[ck];
          tab = {
            controller: ck,
            actions: []
          };
          for (ak in cv) {
            av = cv[ak];
            tab.actions.push({
              action: ak,
              script: av.toString(),
              rows: av.toString().match(/\n/g).length + 2,
              exec: function() {
                var that;
                that = this;
                $context.action = that;
                if (that.script.length > 10) {
                  return eval("(" + that.script + ")($context);");
                }
              }
            });
          }
          _results.push($scope.tabs.push(tab));
        }
        return _results;
      };
      openOptions = function() {
        var $modalInstance;
        $modalInstance = $modal.open({
          templateUrl: jTester.global.templateUrls.config,
          backdrop: 'static',
          controller: 'ConfigCtrl'
        });
        return $modalInstance.result.then(function(result) {
          if (result === 'success') {
            return jTester.alert.success('保存成功');
          }
        });
      };
      if (!jTester.config.host) {
        openOptions();
      }
      resolve(window.Controllers);
    }

    return IndexCtrl;

  })();

  window.ConfigCtrl = (function() {
    function ConfigCtrl($scope, $modalInstance) {
      var headers, jTester, objToArray;
      jTester = window.jTester;
      headers = jTester.config.headers;
      $scope.headers = [];
      $scope.config = {
        host: jTester.config.host,
        defaultPath: jTester.config.defaultPath
      };
      objToArray = function() {
        var k, v, _results;
        $scope.headers = [];
        _results = [];
        for (k in headers) {
          v = headers[k];
          _results.push($scope.headers.push({
            key: k,
            value: v
          }));
        }
        return _results;
      };
      objToArray();
      $scope.set = function() {
        headers[$scope.config.key] = $scope.config.value;
        objToArray();
        $scope.config.key = "";
        return $scope.config.value = "";
      };
      $scope.remove = function(index) {
        var header;
        header = $scope.headers[index];
        delete headers[header.key];
        return $scope.headers.splice(index, 1);
      };
      $scope.save = function() {
        jTester.config.host = $scope.config.host;
        jTester.config.defaultPath = $scope.config.downdir || jTester.config.defaultPath;
        jTester.global.saveConfig();
        return $modalInstance.close('success');
      };
      $scope.cancel = function() {
        if (!jTester.config.host) {
          return jTester.alert.success('请先设置服务器地址');
        } else {
          return $modalInstance.close('dismiss');
        }
      };
    }

    return ConfigCtrl;

  })();

  window.OpenFileCtrl = (function() {
    function OpenFileCtrl($scope, $modalInstance, context) {
      context.$modalInstance = $modalInstance;
      $scope.files = [];
      $scope.change = function(file) {
        return $scope.files.push(file);
      };
      $scope.remove = function(index) {
        return $scope.files.splice(index, 1);
      };
      $scope.upload = function() {
        context.params.files = $scope.files;
        return new jTester.http(context).upload();
      };
      $scope.cancel = function() {
        return $modalInstance.close('dismiss');
      };
    }

    return OpenFileCtrl;

  })();

  window.SaveFileCtrl = (function() {
    function SaveFileCtrl($scope, $modalInstance, context) {
      var downlink;
      downlink = "" + jTester.config.host + "/" + context.params.controller + "/" + context.params.action;
      context.$modalInstance = $modalInstance;
      $scope.params = {
        filename: context.params.action,
        defaultPath: jTester.config.defaultPath,
        downlink: downlink
      };
      $scope.save = function() {
        context.params.downdir = $scope.params.downdir || jTester.config.defaultPath;
        return new jTester.http(context).down();
      };
      $scope.cancel = function() {
        return $modalInstance.close('dismiss');
      };
    }

    return SaveFileCtrl;

  })();

}).call(this);

/*
//@ sourceMappingURL=indexcontroller.map
*/
