class @CompetitiveListExtension
  constructor: ->
    window.competitive_list = new CompetitiveList(id: '#competitive_list_example')
  
    $(document.body).on "click", "#save_data_button", (event) =>
      event.preventDefault()
      @saveData()
  
    $(document.body).on "click", "#load_data_button", (event) =>
      event.preventDefault()
      @loadData()
        
    $(document.body).on "click", "#add_competitor_link", (event) =>
      event.preventDefault()
      @addCompetitor(null, null, prompt('Enter a competitor name!'))
    
  addCompetitor: (id, position, name) -> 
    if id == null
      window.competitors = jQuery.map($('.competitive_list li'), (c) ->
        return parseInt($(c).data('id'))
      )
      ids = window.competitors.sort()
      id = 1
      
      if ids.length > 0
        id = ids[ids.length - 1] + 1
        
      position = (window.competitors.length + 1)
        
    html = '<li id="competitor_' + id + '" data-id="' + id + '" data-position="' + position + '" data-name="' + name + '">'
    html += '<span class="competitor_name hide">' + name + '</span>'
    html += '<span class="competitor_position">' + position + '</span> ' + name + '</li>'
    $('.competitive_list').append(html)  
    
  saveData: ->
    competitorRecords = jQuery.map($('.competitive_list li'), (c) ->
      return { id: $(c).data('id'), position: $(c).data('position'), name: $(c).data('name') }
    )
    $('#competitors_text').val(JSON.stringify(competitorRecords))
    $('#matches_text').val(JSON.stringify(window.matches))  
    
  loadData: ->
    competitorRecords = JSON.parse($('#competitors_text').val())
    window.matches = JSON.parse($('#matches_text').val())
    $('.competitive_list').empty()
    
    $.each competitorRecords, (index, competitor) =>
      @addCompetitor(competitor['id'], competitor['position'], competitor['name'])
      
    $('#competitors_text').val('')
    $('#matches_text').val('')
        
jQuery ->
  new CompetitiveListExtension()
  