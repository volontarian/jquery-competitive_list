(($, window) ->
  CompetitiveList = class CompetitiveList
    jqueryInstanceMethodName: 'competitiveList'
    defaults: {}
    id: null
    competitors: []
    competitorsOfCompetitor: {}
    defeatedCompetitorsByCompetitor: {}
    outmatchedCompetitorsByCompetitor: {}
    matches: []
    matchesLeft: 0
    currentMatch: null
    currentMatchIndex: 0
    currentAutoWinnerMatches: []
    movingCompetitorToPosition: false
    
    constructor: (el, options) ->
      @init el, options if el
  
    init: (el, options) ->
      @options = $.extend({}, @defaults, options)
      @$el = $(el)
      @id = @$el.attr('id')
      $.data el, @constructor::jqueryInstanceMethodName, this
      
      @$el.find('.competitive_list_start_link').on 'click', (event) =>
        event.preventDefault()
        @start()
      
      @$el.find('.save_match_results_link').on 'click', (event) =>
        event.preventDefault()
        @sortByMostWins()
        @$el.find('.save_match_results_link').hide()
      
      $(document.body).on 'click', '#bootstrap_modal .cancel_tournament_button', (event) =>
        event.preventDefault()
        @cancelTournament()   
      
      $(document.body).on 'click', '#bootstrap_modal .select_winner_button', (event) =>
        event.preventDefault()
        @appointWinnerOfMatchByInput()
        
    start: () ->     
      matchesAlreadyExist = false
      @matches ||= []
      
      if @matches.length > 0
        matchesAlreadyExist = true
        
      @setCompetitors()  
      @competitorsOfCompetitor = {}
      @defeatedCompetitorsByCompetitor = {}
      @outmatchedCompetitorsByCompetitor = {}
      
      if matchesAlreadyExist
        if confirm('Remove previous results and start over?')
          @matches = []
        else
          @removeMatchesOfNonExistingCompetitors() 
      
      @generateMatches()
      
      matchesWithoutWinner = jQuery.map(@matches, (m) ->
        if m['winner'] == undefined
          return m
      )
      
      @matchesLeft = matchesWithoutWinner.length
      
      if @nextMatch(true)
        $('#bootstrap_modal').modal('show')
    
    setCompetitors: ->
      @competitors = jQuery.map(@$el.find('.competitive_list li'), (c) ->
        return $(c).data('id')
      )
        
    removeMatchesOfNonExistingCompetitors: () ->
      $.each @matches, (index, match) =>
        notExistingCompetitors = jQuery.map(match['competitors'], (c) =>
          if $.inArray(c, @competitors) == -1
            return c
        )
        
        if notExistingCompetitors.length > 0
          @matches = @removeItemFromArray(@matches, match)
        else
          @competitorsOfCompetitor[match['competitors'][0]] ||= []
          @competitorsOfCompetitor[match['competitors'][0]].push match['competitors'][1]
          @competitorsOfCompetitor[match['competitors'][1]] ||= []
          @competitorsOfCompetitor[match['competitors'][1]].push match['competitors'][0]
          
          unless match['winner'] == undefined
            loserId = @otherCompetitorOfMatch(match, match['winner'])
            @updateDefeatedAndOutmatchedCompetitorsByCompetitor(match['winner'], loserId)
    
    removeItemFromArray: (array, item) ->
      list = []
      
      jQuery.each array, (index, workingItem) ->
        unless JSON.stringify(workingItem) == JSON.stringify(item)
          list.push workingItem
          
      return list
            
    generateMatches: () ->
      $.each @competitors, (index, competitorId) =>
        @competitorsOfCompetitor[competitorId] ||= []
          
        $.each @competitors, (index, otherCompetitorId) =>
          @competitorsOfCompetitor[otherCompetitorId] ||= []
          
          if competitorId != otherCompetitorId && $.inArray(otherCompetitorId, @competitorsOfCompetitor[competitorId]) == -1
            @matches.push { competitors: [competitorId, otherCompetitorId] }
            @competitorsOfCompetitor[competitorId].push otherCompetitorId
            @competitorsOfCompetitor[otherCompetitorId].push competitorId
            
    nextMatch: (from_start) ->
      autoWinnerMatchesHtml = ''
  
      if @currentAutoWinnerMatches.length > 0
        @currentMatch = @matches[@currentMatchIndex]
        rows = ""
        
        $.each @currentAutoWinnerMatches, (index, match) =>
          even_or_odd = ''
          
          if index % 2 == 0
            even_or_odd = 'even'
          else
            even_or_odd = 'odd'
          
          manualWinnerChangedHtml = ''
          
          if match['manual_winner_changed'] == true
            manualWinnerChangedHtml = """
  <a class="bootstrap_tooltip" href="#" data-toggle="tooltip" title="The winner you once have set has been changed automatically!">
    <i class='icon-warning-sign'/>
  </a>
  """ 
          
          rows += """
  <tr class="#{even_or_odd}">
    <td>
      #{manualWinnerChangedHtml}
    </td>
    <td style="width:200px">#{@nameOfCompetitor(match['winner'], false)}</td>
    <td><input type="radio" checked="checked" disabled="disabled"/></td>
    <td>&nbsp;&nbsp;VS.&nbsp;&nbsp;&nbsp;</td>
    <td><input type="radio" disabled="disabled"/></td>
    <td>&nbsp;&nbsp;&nbsp;</td>
    <td style="width:200px">#{@nameOfCompetitor(@otherCompetitorOfMatch(match, match['winner']), false)}</td>
    <td style="text-align:center">
      <a class="bootstrap_tooltip" href="#" data-toggle="tooltip" data-html="true" title="#{match['auto_winner_reason']}">
        <i class="icon-question-sign"/>
      </a>
    </td>
    <td style="width:200px">#{@nameOfCompetitor(match['foot_note_competitor'], false)}</td>
  </tr>        
  """     
          
        autoWinnerMatchesHtml = """  
  <h4>Auto Winners due to Result of last Match</h4>
  <table>
    <tr>
      <td><strong>Last Match was:&nbsp;&nbsp;</strong></td>
      <td>#{@nameOfCompetitor(@currentMatch['winner'], false)}</td>
      <td>&nbsp;&nbsp;<input type="radio" checked="checked" disabled="disabled"/></td>
      <td>&nbsp;&nbsp;VS.&nbsp;&nbsp;&nbsp;</td>
      <td><input type="radio" disabled="disabled"/></td>
      <td>&nbsp;&nbsp;&nbsp;</td>
      <td>#{@nameOfCompetitor(@otherCompetitorOfMatch(@currentMatch, @currentMatch['winner']), false)}</td>
    </tr>
  </table>
  <table class="table table-striped">
    <thead>
      <tr class="odd">
        <th></th>
        <th>Winner</th>
        <th></th>
        <th></th>
        <th></th>
        <th></th>
        <th>Loser</th>
        <th>Reason</th>
        <th>[1]</th>
      </tr>
    </thead>
    <tbody>
      #{rows}
    </tbody>
  </table>   
  """
        
      @currentMatch = null
      
      $.each @matches, (index, match) =>
        if match['winner'] == undefined
          @currentMatch = match
          @currentMatchIndex = index
          
          return false
      
      if from_start == true && @currentMatch == null 
        alert 'No matches to rate left.'
        
        return false
      else
        @$el.find('.save_match_results_link').show()
        
      modalBodyHtml = ''
      modalTitle = ''
      modalFooterHtml = ''
      
      if @currentMatch == null 
        modalTitle = 'No matches to rate left.' 
        modalFooterHtml = """
  <p>
    <button type="button" class="cancel_tournament_button btn btn-default">Save match results and close window</button>
  </p>      
  """      
      else
        modalTitle = "Appoint Winner (#{@matchesLeft} matches left)"
        radioButtons = []
        competitorStrings = []
        i = 0
        
        $.each @currentMatch['competitors'], (index, competitorId) =>
          checked = ' checked="checked"'
          checked = '' if i == 1
          radioButtons.push ('<input type="radio" ' + checked + ' name="winner" value="' + competitorId + '" style="position:relative; top:-5px "/>')
          competitorStrings.push @nameOfCompetitor(competitorId, true)  
            
          i += 1
        modalBodyHtml += """  
  <div class="controls" style="margin-left:50px">
    <table>
      <tr>      
        <td style="width:325px; text-align:right;">
          #{competitorStrings[0]}
        </td>
        <td>&nbsp;&nbsp;&nbsp;</td>
        <td>#{radioButtons[0]}</td>
        <td>&nbsp;&nbsp;VS.&nbsp;&nbsp;&nbsp;</td>
        <td>#{radioButtons[1]}</td>
        <td>
          &nbsp;&nbsp;&nbsp;
        </td>
        <td style="width:325px">
          #{competitorStrings[1]}
        </td>
      </tr>
    </table>
  </div>     
  """
        modalFooterHtml = """
  <p>
    <button type="button" class="cancel_tournament_button btn btn-default">Save match results and close window</button> &nbsp;&nbsp;&nbsp;&nbsp;
    <button type="button" class="select_winner_button btn btn-primary">Submit</button>
  </p>
  """
        
      modalBodyHtml += autoWinnerMatchesHtml
         
      html = """
  <div class="modal-dialog">
    <div class="modal-content">    
      <form class="form-inline" style="margin:0px;">
        <div class="modal-header">
          <button type="button" id="close_bootstrap_modal_button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
          <h3>#{modalTitle}</h3>
        </div>
        <div class="modal-body" style="overflow-y:auto;">
          #{modalBodyHtml}
        </div>
        <div class="modal-footer" style="text-align:left;">
          #{modalFooterHtml}
        </div>
      </form>
    </div>
  </div>
  """
  
      $('#bootstrap_modal').html(html)
      $('.bootstrap_tooltip').tooltip()
      @currentAutoWinnerMatches = []
      
      return true
      
    otherCompetitorOfMatch: (match, competitorId) ->
      otherCompetitors = jQuery.map(match['competitors'], (c) ->
        if c != competitorId
          return c
      )
      return otherCompetitors[0]
  
    nameOfCompetitor: (competitorId, considerProc) ->
      competitorDomElement = $('#competitor_' + competitorId)
      
      if considerProc == false || @options['competitor_name_proc'] == undefined || $(competitorDomElement).find('.competitor_name').data('proc-argument') == undefined
        return $(competitorDomElement).find('.competitor_name').html()  
      else
        return @options['competitor_name_proc']($(competitorDomElement).find('.competitor_name').data('proc-argument'))
    
    cancelTournament: ->
      @sortByMostWins()
      @$el.find('.save_match_results_link').hide()
      $('#bootstrap_modal').modal('hide')   
       
    appointWinnerOfMatchByInput: () ->
      winnerId = parseInt($("input[name='winner']:checked").val())
      loserId = @otherCompetitorOfMatch(@currentMatch, winnerId)
      
      @appointWinnerOfMatch(@currentMatchIndex, winnerId, loserId, true)
      
      @nextMatch(false)
        
    appointWinnerOfMatch: (matchIndex, winnerId, loserId, decrementMatchesLeft) ->
      if @movingCompetitorToPosition == true
        delete @matches[matchIndex]['manual_winner_changed']
        delete @matches[matchIndex]['auto_winner']
        delete @matches[matchIndex]['foot_note_competitor']
        delete @matches[matchIndex]['auto_winner_type']
        delete @matches[matchIndex]['auto_winner_recursion']
        delete @matches[matchIndex]['auto_winner_reason']
        
      @matches[matchIndex]['winner'] = winnerId
      @matchesLeft = @matchesLeft - 1 if decrementMatchesLeft
      
      @updateDefeatedAndOutmatchedCompetitorsByCompetitor(winnerId, loserId)
      @letWinnerWinMatchesAgainstCompetitorsWhichLoseAgainstLoser(winnerId, loserId)
      @letOutMatchedCompetitorsOfWinnerWinAgainstLoser(winnerId, loserId)  
      
    updateDefeatedAndOutmatchedCompetitorsByCompetitor: (winnerId, loserId) ->
      @defeatedCompetitorsByCompetitor[winnerId] ||= []
      @defeatedCompetitorsByCompetitor[winnerId].push loserId  
       
      @outmatchedCompetitorsByCompetitor[loserId] ||= []
      @outmatchedCompetitorsByCompetitor[loserId].push winnerId  
      
    letWinnerWinMatchesAgainstCompetitorsWhichLoseAgainstLoser: (winnerId, loserId) ->
      @defeatedCompetitorsByCompetitor[loserId] ||= []
      
      $.each @matches, (index, match) =>  
        return true if match['winner'] == winnerId || $.inArray(winnerId, match['competitors']) == -1
        
        matchCompetitorsWhichHaveBeenDefeatedByLoser = jQuery.map(match['competitors'], (c) =>
          if $.inArray(c, @defeatedCompetitorsByCompetitor[loserId]) > -1
            return c
        )
          
        return true if matchCompetitorsWhichHaveBeenDefeatedByLoser.length == 0
          
        otherLoserId = @otherCompetitorOfMatch(match, winnerId)
        manual_winner_changed = false
        
        unless match['winner'] == undefined
          @removeCompetitorsComparisonResult(winnerId, otherLoserId) 
          manual_winner_changed = true unless @movingCompetitorToPosition == true || match['auto_winner'] == true
        
        @appointWinnerOfMatch(index, winnerId, otherLoserId, match['winner'] == undefined)
        
        return true if @movingCompetitorToPosition == true
        
        @matches[index]['manual_winner_changed'] = manual_winner_changed  
        @matches[index]['auto_winner'] = true
        @matches[index]['foot_note_competitor'] = loserId
        @matches[index]['auto_winner_type'] = 0
        
        if winnerId == @currentMatch['winner'] && loserId == @otherCompetitorOfMatch(@currentMatch, @currentMatch['winner'])
          @matches[index]['auto_winner_recursion'] = false
          @matches[index]['auto_winner_reason'] = 'loser has been defeated because he loses against the loser <sup>[1]</sup> of last match'
        else
          @matches[index]['auto_winner_recursion'] = true
          @matches[index]['auto_winner_reason'] = 'loser has been defeated because he loses against the loser <sup>[1]</sup> of last auto winner match'
          
        @currentAutoWinnerMatches.push @matches[index]
        
    removeCompetitorsComparisonResult: (winnerId, loserId) ->
      @outmatchedCompetitorsByCompetitor[winnerId] ||= []
      @outmatchedCompetitorsByCompetitor[winnerId] = @removeItemFromArray(@outmatchedCompetitorsByCompetitor[winnerId], loserId)
      @defeatedCompetitorsByCompetitor[loserId] = @removeItemFromArray(@defeatedCompetitorsByCompetitor[loserId], winnerId)
      
    letOutMatchedCompetitorsOfWinnerWinAgainstLoser: (winnerId, loserId) ->
      @outmatchedCompetitorsByCompetitor[winnerId] ||= []
      
      $.each @outmatchedCompetitorsByCompetitor[winnerId], (index, competitorId) =>
        $.each @matches, (index, match) =>
          if $.inArray(competitorId, match['competitors']) > -1 && $.inArray(loserId, match['competitors']) > -1 && match['winner'] != competitorId
            manual_winner_changed = false
            
            unless match['winner']  == undefined
              @removeCompetitorsComparisonResult(competitorId, loserId)
              manual_winner_changed = true unless @movingCompetitorToPosition == true || match['auto_winner'] == true
            
            @appointWinnerOfMatch(index, competitorId, loserId, match['winner']  == undefined)
            
            return true if @movingCompetitorToPosition == true
            
            @matches[index]['manual_winner_changed'] = manual_winner_changed 
            @matches[index]['auto_winner'] = true
            @matches[index]['auto_winner_type'] = 1
            @matches[index]['foot_note_competitor'] = winnerId
            
            if winnerId == @currentMatch['winner'] && loserId == @otherCompetitorOfMatch(@currentMatch, @currentMatch['winner'])
              @matches[index]['auto_winner_recursion'] = false
              @matches[index]['auto_winner_reason'] = "loser of last match has been defeated by outmatched competitor of<br/>winner <sup>[1]</sup>"
            else
              @matches[index]['auto_winner_recursion'] = true
              @matches[index]['auto_winner_reason'] = "loser of last auto winner match has been defeated by outmatched competitor of winner <sup>[1]</sup>"
              
            @currentAutoWinnerMatches.push match
            
            return false
       
    moveCompetitorToPosition: (competitorId, position, after_update_request_proc = null) ->   
      @movingCompetitorToPosition = true
      @setCompetitors()
      @competitorsOfCompetitor = {}
      @removeMatchesOfNonExistingCompetitors() 
      @generateMatches()
      positions = @getPositions()
      outmatchedCompetitor = null
      defeatedCompetitor = null
      positionOfdefeatedCompetitor = if positions[position] == competitorId then (position + 1) else position
      
      if position > Object.keys(positions).length
        alert 'This position is not available!'
        after_update_request_proc() unless after_update_request_proc == null
        @movingCompetitorToPosition = false
        return
      
      unless position == 1 || (position - 1) > Object.keys(positions).length
        outmatchedCompetitor = positions[position - 1]
      
      unless positionOfdefeatedCompetitor > Object.keys(positions).length
        defeatedCompetitor = positions[positionOfdefeatedCompetitor]
        
      $.each @matches, (index, match) =>
        return true if $.inArray(competitorId, match['competitors']) == -1
        
        winnerId = null
        loserId = null
        otherCompetitorId = @otherCompetitorOfMatch(match, competitorId)
        
        if otherCompetitorId == outmatchedCompetitor && match['winner'] != otherCompetitorId
          winnerId = otherCompetitorId
          loserId = competitorId
          outmatchedCompetitor = null
        else if otherCompetitorId == defeatedCompetitor && match['winner'] != competitorId
          winnerId = competitorId
          loserId = otherCompetitorId
          defeatedCompetitor = null
          
        return true if winnerId == null
        
        unless match['winner'] == undefined
          @removeCompetitorsComparisonResult(winnerId, loserId) 
          
        @currentMatch = match
        @currentMatchIndex = index  
        @appointWinnerOfMatch(index, winnerId, loserId, false)
        
        return false if outmatchedCompetitor == null && defeatedCompetitor == null
        
      @sortByMostWins(after_update_request_proc)
      @movingCompetitorToPosition = false
          
    sortByMostWins: (after_update_request_proc = null) ->
      winsByCompetitor = {}
      
      $.each @competitors, (index, competitorId) =>
        winsByCompetitor[competitorId] = 0
  
      $.each @matches, (index, match) =>
        delete @matches[index]['auto_winner_reason']
        
        winsByCompetitor[match['winner']] += 1
      
      $.each Object.keys(winsByCompetitor), (index, competitorId) ->
        $('#competitor_' + competitorId).data 'wins', winsByCompetitor[competitorId]
        
      $wrapper = @$el.find('.competitive_list')
      
      $wrapper.find('li').sort((a, b) ->
        +parseInt($(b).data('wins')) - +parseInt($(a).data('wins'))
      ).appendTo $wrapper
      positions = @getPositions()  
        
      unless $wrapper.data('update-all-positions-path') == undefined  
        data = { _method: 'put', positions: positions, matches: JSON.stringify(@matches) }  
        $.post($wrapper.data('update-all-positions-path'), data).always(=>
          after_update_request_proc() unless after_update_request_proc == null
        )       
      
    getPositions: ->
      positions = {}
      currentPosition = 1
      
      $.each @$el.find('.competitive_list li'), (index, element) ->
        positions[currentPosition] = $(element).data('id')
        $(element).data('position', currentPosition)  
        $(element).find('.competitor_position').html(currentPosition)
        currentPosition += 1  
        
      return positions
      
  # Original source from: http://blog.bitovi.com/writing-the-perfect-jquery-plugin/      
  $.pluginFactory = (plugin) ->
    $.fn[plugin::jqueryInstanceMethodName] = (options) ->
      args = $.makeArray(arguments)
      after = args.slice(1)
      
      @each ->
        instance = $.data(this, plugin::jqueryInstanceMethodName)
        
        if instance
          # call a method on the instance
          if typeof options == 'string'
            instance[options].apply instance, after
          else if instance.update
            # call update on the instance
            instance.update.apply instance, args
        else
          # create the plugin
          new plugin(this, options)        

  $.pluginFactory CompetitiveList 
) window.jQuery, window