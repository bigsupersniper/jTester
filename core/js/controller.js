// Generated by CoffeeScript 1.7.1
(function() {
  window.datadecrypt = function(api_secret, data) {
    if (data.data !== "" && data.success) {
      data.data = jTester.AES.decrypt(api_secret, data.data);
      data.data = JSON.parse(data.data);
    }
    return data;
  };

  window.Controllers = {
    Home: {
      Get: function() {
        $context.params = {
          controller: "home",
          action: "Get"
        };
        return new jTester.http($context).get();
      },
      Post: function() {
        $context.params = {
          controller: "home",
          action: "Post"
        };
        return new jTester.http($context).post();
      },
      Upload: function() {
        $context.params = {
          controller: "home",
          action: "upload"
        };
        $context.maxDataSize = 10;
        return jTester.file.openFile($context);
      },
      Down: function() {
        $context.params = {
          controller: "home",
          action: "down"
        };
        return new jTester.file.saveFile($context);
      }
    }
  };

}).call(this);
