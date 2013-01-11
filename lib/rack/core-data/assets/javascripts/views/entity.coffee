class RCD.Views.Entity extends Backbone.View
  el: "[role='main']"

  initialize: ->
    @model.on 'reset', @render

    @collection = @model.get('resources')
    @collection.fetch({success: @render})

  render: =>
    if @collection
      @datagrid = new Backbone.Datagrid({
        collection: @collection,
        columns: @collection.first().attributes.keys,
        paginated: true,
        perPage: 50
      })
      @$el.find("#datagrid").html(@datagrid.el)

    @
