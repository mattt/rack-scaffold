class RCD.Routers.Root extends Backbone.Router
  el:
    "div[role='container']"

  initialize: (options) ->
    @views = {}
    super

  routes:
    '':         'index'

  index: ->
    @_activateNavbarLink("devices")

    RCD.entities.fetch()
    # @views.devices ||= new RPN.Views.Devices(collection: RPN.devices)
    # @views.devices.render()

  _activateNavbarLink: (className) ->
    $li = $("header nav li")
    $li.removeClass("active")
    $li.filter("." + className).addClass("active")
