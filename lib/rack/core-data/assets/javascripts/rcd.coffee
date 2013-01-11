window.RCD =
  Collections: {}
  Models: {}
  Routers: {}
  Views: {}

  initialize: ->
    @entities = RCD.entities
    @entitiesView = new RCD.Views.Entities({collection: @entities})
    @entitiesView.render()

    window.app = new RCD.Routers.Root
    for entity in @entities.models
      do (entity) ->
        name = entity.get('name').toLowerCase()
        
        window.app[name] = ->
          @entityView = new RCD.Views.Entity({model: entity})
        window.app.route entity.url(), name
      

    Backbone.history.start({pushState: true, hashChange: false})
