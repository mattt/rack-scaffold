class RCD.Collections.Resources extends Backbone.Collection
  model: RCD.Models.Resource

  parse: (response, options) ->
    if _.isArray(response)
      response
    else
      @total = response.total
      @page = response.page
      _.detect response, (value, key) ->
        _.isArray(value)
