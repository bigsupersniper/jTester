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
        alert(message);
    });

    //import node require
    var require = window.require

    //register .coffee extension
    require ( './node_modules/coffee-script/register')
    //require module by order
    //global
    require ('./coffee/config.coffee')
    //utils
    require ('./coffee/utils/httprequest')
    require ('./coffee/utils/aes')
    require ('./coffee/utils/string')
    //views
    require ('./coffee/views/viewstart')
    require ('./coffee/views/indexctrl')
    require ('./coffee/views/jsonctrl')
    require ('./coffee/views/httpctrl')
    require ('./coffee/views/uploadctrl')
    require ('./coffee/views/httpconfigctrl')
    require ('./coffee/views/itemconfigctrl')

})();