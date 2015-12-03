

httpRequests = httpRequests || {}
httpRequests.Home = {}
httpRequests.Home.Login =
  params :
    username : "admin"
    password : "123456"
  handler : ()->
    console.log this.params

window.httpRequests = httpRequests

tabs = []

for tn , th of httpRequests
  handlers = []
  for hn , hh of th
    handlers.push
      name : hn,
      params : hh.params
      handler : hh.handler
  tabs.push
    title : tn
    handlers : handlers

window.tabs = tabs

