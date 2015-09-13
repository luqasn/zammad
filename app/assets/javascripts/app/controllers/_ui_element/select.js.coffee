class App.UiElement.select extends App.UiElement.ApplicationUiElement
  @render: (attribute, params, form_controller) ->

    # set multible option
    if attribute.multiple
      attribute.multiple = 'multiple'
    else
      attribute.multiple = ''

    # build options list based on config
    @getConfigOptionList( attribute, params )

    # build options list based on relation
    @getRelationOptionList( attribute, params )

    # add null selection if needed
    @addNullOption( attribute, params )

    # sort attribute.options
    @sortOptions( attribute, params )

    # finde selected/checked item of list
    @selectedOptions( attribute, params )

    # disable item of list
    @disabledOptions( attribute, params )

    # filter attributes
    @filterOption( attribute, params )

    # return item
    $( App.view('generic/select')( attribute: attribute ) )