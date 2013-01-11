class RCD.Views.Entities extends Backbone.View
  template: JST['templates/entities']
  el: "[role='main']"

  initialize: ->
    @collection.on 'reset', @render

  render: ->
    @$el.html(@template(entities: @collection))

    @
