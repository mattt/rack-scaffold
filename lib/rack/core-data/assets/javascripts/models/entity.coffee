class RCD.Models.Entity extends Backbone.Model
  idAttribute: "name"
  url: ->
    @get('resources').url.replace(/^\//, 'data/')

  parse: (response) ->
    response.resources = new RCD.Collections.Resources()
    response.resources.url = response.url
    response