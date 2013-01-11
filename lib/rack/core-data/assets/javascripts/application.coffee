#= require ./vendor/jquery
#= require ./vendor/underscore
#= require ./vendor/backbone
#= require ./vendor/backbone.datagrid

#= require ./rcd
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./templates
#= require_tree ./views
#= require_tree ./routers

$ ->
  $('a').live 'click', (event) ->
    href = $(this).attr('href')
    event.preventDefault()
    window.app.navigate(href, {trigger: true})

  RCD.entities = new RCD.Collections.Entities
  RCD.entities.fetch(type: 'OPTIONS', success: RCD.initialize)
