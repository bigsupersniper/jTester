/**
 * Created by sniper on 2014/10/11.
 * 在require的CoffeScript引用的外部JS的全局变量必须加上window
 */
(function(){
    //namespace
    window.jTester = {}

    //handle uncaughtException
    process.on('uncaughtException', function(err) {
        console.log(err);
        var message = decodeURIComponent(err.message)
        return alert(message);
    });

    jTester.restart = function() {
        var child, child_process;
        jTester.require.nw.Window.get().hide();
        child_process = require("child_process");
        child = child_process.spawn(process.execPath, [], {
            detached: true
        });
        child.unref();
        jTester.require.nw.App.quit();
    };

    //import node require
    var require = window.require;

    window.jTester.require = {
        nw: require('nw.gui'),
        fs: require('fs'),
        net : require('net'),
        util : require('util'),
        events : require('events'),
        path: require('path'),
        querystring: require('querystring'),
        url: require('url'),
        dateformat : require('./node_modules/dateformat'),
        request: require('./node_modules/request'),
        uuid: require('./node_modules/node-uuid/uuid'),
        formdata: require('./node_modules/request/node_modules/form-data/lib/form_data'),
        cryptojs : require ('./node_modules/crypto-js')
    };

    //register .coffee extension
    require ( './node_modules/coffee-script/register')
    //require module by order
    //global
    require ('./coffee/config.coffee')
    //utils
    require ('./coffee/utils/utils.coffee')
    //views
    require ('./coffee/views/indexctrl.coffee')
    require ('./coffee/views/jsonctrl.coffee')
    require ('./coffee/views/httpctrl.coffee')
    require ('./coffee/views/downlistctrl.coffee')
    require ('./coffee/views/uploadfilectrl.coffee')
    require ('./coffee/views/savefilectrl.coffee')
    //utils
    require ('./coffee/utils/httputils.coffee')

}).call(this);