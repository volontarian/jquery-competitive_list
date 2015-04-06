describe 'CompetitiveList', ->
  beforeEach ->
    html = """
      <div id="testFixture">
        <div id="bootstrap_modal" class="modal hide fade"></div>
    
        <div id="competitive_list_example">    
          <ul class="competitive_list" data-update-all-positions-path="/items/update_all">
            <li id="competitor_1" data-id="1" data-position="1">
              <span class="competitor_position">1</span>
              P1
              <span class="competitor_name hide" data-proc-argument="Dummy">P1</span>
            </li>
            <li id="competitor_2" data-id="2" data-position="2">
              <span class="competitor_position">2</span>
              P2
              <span class="competitor_name hide">
                P2
              </span>
            </li>
            <li id="competitor_3" data-id="3" data-position="3">
              <span class="competitor_position">3</span>
              P3
              <span class="competitor_name hide">
                P3
              </span>
            </li>
          </ul>
          
          <p>
            <button type="button" class="btn hide save_match_results_link">
              <span class='icon-warning-sign'></span> Save match results
            </button>
          </p>
        </div>
      </div>
    """
    $('body').append html
    
    $('#competitive_list_example').competitiveList()

  afterEach ->
    $('#testFixture').remove()
    
  describe '#start', ->
    it 'loads the competitors from the DOM and sets how many matches are left', ->
      $(document).ready ->
        $('#competitive_list_example').competitiveList('start')
        expect($('#competitive_list_example').data('competitiveList').competitors).toEqual [1, 2, 3]
        expect($('#competitive_list_example').data('competitiveList').matchesLeft).toEqual 3
        
  describe '#generateMatches', ->
    it 'generates matches between all competitors', ->
      $('#competitive_list_example').data('competitiveList').competitors = [1, 2, 3]
      $('#competitive_list_example').data('competitiveList').matches = []
      $('#competitive_list_example').competitiveList('generateMatches')
      expect($('#competitive_list_example').data('competitiveList').matches).toEqual [
        { competitors: [1, 2] }
        { competitors: [1, 3] }
        { competitors: [2, 3] }
      ]
      
  describe '#removeMatchesOfNonExistingCompetitors', ->
    it 'does what the name says', ->
      $('#competitive_list_example').data('competitiveList').competitors = [1, 2, 4]
      $('#competitive_list_example').data('competitiveList').matches = [
        { competitors: [1, 2] }
        { competitors: [1, 3] }
        { competitors: [2, 3] }
      ]
      $('#competitive_list_example').competitiveList('removeMatchesOfNonExistingCompetitors')
      expect($('#competitive_list_example').data('competitiveList').matches).toEqual [ { competitors: [1, 2] } ]
      
  describe '#nextMatch', ->
    context 'matches to rate left', ->
      it 'sets the current match to next match in matches list and shows form to appoint winner', ->
        $('#competitive_list_example').data('competitiveList').matches = [ { competitors: [1, 2] } ]
        
        $(document).ready ->
          expect($('#competitive_list_example').data('competitiveList').nextMatch(false)).toEqual true
          expect($('#competitive_list_example').data('competitiveList').currentMatch).toEqual(
            $('#competitive_list_example').data('competitiveList').matches[0]
          )
          expect($('#competitive_list_example .save_match_results_link').css('display')).toEqual 'inline-block'
          expect($('.modal-header:contains(\'Appoint Winner\')').length).toEqual 1
          
    context 'no matches to rate left', ->
      beforeEach ->
        $('#competitive_list_example').data('competitiveList').matches = [ { competitors: [1, 2], winner: 1} ]
        
      context 'called from start', ->
        it 'alerts a message, ', ->
          spyOn window, 'alert'
          
          $(document).ready ->
            expect($('#competitive_list_example').data('competitiveList').nextMatch(true)).toEqual false
            expect($('#competitive_list_example').data('competitiveList').currentMatch).toEqual null
            expect(window.alert).toHaveBeenCalledWith 'No matches to rate left.'
            
      context 'called not from start', ->
        it 'shows a modal saying that no matches to rate are left', ->
          $(document).ready ->
            expect($('#competitive_list_example').data('competitiveList').nextMatch(false)).toEqual true
            expect($('#competitive_list_example').data('competitiveList').currentMatch).toEqual null
            expect($('.modal-header:contains(\'No matches to rate left.\')').length).toEqual 1
            
  describe '#otherCompetitorOfMatch', ->
    it 'returns the id of the match competitor other than the given one', ->
      expect($('#competitive_list_example').data('competitiveList').otherCompetitorOfMatch({ competitors: [1, 2] }, 1)).toEqual 2
      
  describe '#nameOfCompetitor', ->
    context 'don\'t consider proc', ->
      it 'returns the HTML of .competitor_name', ->
        expect($('#competitive_list_example').data('competitiveList').nameOfCompetitor(1, false)).toEqual 'P1'
        
    context 'consider proc', ->
      it 'passes $(\'.competitor_name\').data(\'proc-argument\') to the proc', ->
        $('#competitive_list_example').data('competitiveList', null)
        $('#competitive_list_example').competitiveList
          competitor_name_proc: (value) ->
            return 'Player:' + value
        
        expect($('#competitive_list_example').data('competitiveList').nameOfCompetitor(1, true)).toEqual 'Player:Dummy'
        
  describe '#cancelTournament', ->
    it 'hides the save match results link', ->
      spyOn $('#competitive_list_example').data('competitiveList'), 'sortByMostWins'
      
      $('#competitive_list_example').competitiveList('cancelTournament')
      
      expect($('#competitive_list_example .save_match_results_link').css('display')).toEqual 'none'
      expect($('#competitive_list_example').data('competitiveList').sortByMostWins).toHaveBeenCalled()
      
  describe '#appointWinnerOfMatchByInput', ->
    it 'passes winner and loser to @appointWinnerOfMatch', ->
      spyOn $('#competitive_list_example').data('competitiveList'), 'appointWinnerOfMatch'
      $('#competitive_list_example').data('competitiveList').matches = [ { competitors: [1, 2] } ]
      $('#competitive_list_example').competitiveList('nextMatch', false)
      
      $('#competitive_list_example').competitiveList('appointWinnerOfMatchByInput')
      
      expect($('#competitive_list_example').data('competitiveList').appointWinnerOfMatch).toHaveBeenCalledWith 0, 1, 2, true
      
  describe '#appointWinnerOfMatch', ->
    beforeEach ->
      $('#competitive_list_example').data('competitiveList').matches = [ { competitors: [1, 2] } ]
      $('#competitive_list_example').competitiveList('nextMatch', false)
      
    context 'decrementMatchesLeft is true', ->
      it 'decrements the matches left', ->
        $('#competitive_list_example').data('competitiveList').matchesLeft = 1
        $('#competitive_list_example').competitiveList('appointWinnerOfMatch', 0, 1, 2, true)
        expect($('#competitive_list_example').data('competitiveList').matchesLeft).toEqual 0
        
    context 'decrementMatchesLeft is false', ->
      it 'does not decrement the matches left', ->
        $('#competitive_list_example').data('competitiveList').matchesLeft = 1
        $('#competitive_list_example').competitiveList('appointWinnerOfMatch', 0, 1, 2, false)
        expect($('#competitive_list_example').data('competitiveList').matchesLeft).toEqual 1
        
    it 'calls some instance methods properly', ->
      spyOn $('#competitive_list_example').data('competitiveList'), 'updateDefeatedAndOutmatchedCompetitorsByCompetitor'
      spyOn $('#competitive_list_example').data('competitiveList'), 'letWinnerWinMatchesAgainstCompetitorsWhichLoseAgainstLoser'
      spyOn $('#competitive_list_example').data('competitiveList'), 'letOutMatchedCompetitorsOfWinnerWinAgainstLoser'
      
      $('#competitive_list_example').competitiveList('appointWinnerOfMatch', 0, 1, 2, true)
      
      expect($('#competitive_list_example').data('competitiveList').updateDefeatedAndOutmatchedCompetitorsByCompetitor).toHaveBeenCalledWith 1, 2
      expect($('#competitive_list_example').data('competitiveList').letWinnerWinMatchesAgainstCompetitorsWhichLoseAgainstLoser).toHaveBeenCalledWith 1, 2
      expect($('#competitive_list_example').data('competitiveList').letOutMatchedCompetitorsOfWinnerWinAgainstLoser).toHaveBeenCalledWith 1, 2
      
  describe '#updateDefeatedAndOutmatchedCompetitorsByCompetitor', ->
    it 'updates the maps defeatedCompetitorsByCompetitor and outmatchedCompetitorsByCompetitor', ->
      $('#competitive_list_example').data('competitiveList').defeatedCompetitorsByCompetitor = {}
      $('#competitive_list_example').data('competitiveList').outmatchedCompetitorsByCompetitor = {}
      
      $('#competitive_list_example').competitiveList('updateDefeatedAndOutmatchedCompetitorsByCompetitor', 1, 2)
      
      expect($('#competitive_list_example').data('competitiveList').defeatedCompetitorsByCompetitor[1]).toEqual [ 2 ]
      expect($('#competitive_list_example').data('competitiveList').defeatedCompetitorsByCompetitor[2]).toEqual undefined
      expect($('#competitive_list_example').data('competitiveList').outmatchedCompetitorsByCompetitor[1]).toEqual undefined
      expect($('#competitive_list_example').data('competitiveList').outmatchedCompetitorsByCompetitor[2]).toEqual [ 1 ]
      
  describe '#letWinnerWinMatchesAgainstCompetitorsWhichLoseAgainstLoser', ->
    beforeEach ->
      $('#competitive_list_example').data('competitiveList').matches = [
        { competitors: [1, 2], winner: 1 },
        { competitors: [1, 3] },
        { competitors: [2, 3], winner: 2 }
      ]
      $('#competitive_list_example').data('competitiveList').defeatedCompetitorsByCompetitor = { 1: [2], 2: [3] }
      $('#competitive_list_example').data('competitiveList').outmatchedCompetitorsByCompetitor = { 2: [1], 3: [ 2 ] }
      $('#competitive_list_example').data('competitiveList').currentMatch = $('#competitive_list_example').data('competitiveList').matches[0]
      
    context 'match has no winner yet', ->
      it 'let winner win matches against competitors which have lost against loser', ->
        $('#competitive_list_example').competitiveList('letWinnerWinMatchesAgainstCompetitorsWhichLoseAgainstLoser', 1, 2)
        
        expect($('#competitive_list_example').data('competitiveList').matches[1]).toEqual { 
          competitors: [1, 3], winner: 1, auto_winner: true, manual_winner_changed: false, foot_note_competitor: 2, 
          auto_winner_type: 0, auto_winner_recursion: false,
          auto_winner_reason: 'loser has been defeated because he loses against the loser <sup>[1]</sup> of last match'
        }
      
    context 'match has already a different winner', ->
      it 'changes the winner of the match', ->
        $('#competitive_list_example').data('competitiveList').matches[1]['winner'] = 3
        $('#competitive_list_example').data('competitiveList').defeatedCompetitorsByCompetitor[3] = [1]
        $('#competitive_list_example').data('competitiveList').outmatchedCompetitorsByCompetitor[1] = [3]
        
        $('#competitive_list_example').competitiveList('letWinnerWinMatchesAgainstCompetitorsWhichLoseAgainstLoser', 1, 2)
        
        expect($('#competitive_list_example').data('competitiveList').matches[1]).toEqual {
          competitors: [1, 3], winner: 1, auto_winner: true, manual_winner_changed: true, foot_note_competitor: 2,
          auto_winner_type: 0, auto_winner_recursion: false,
          auto_winner_reason: 'loser has been defeated because he loses against the loser <sup>[1]</sup> of last match'
        }
        
  describe '#removeCompetitorsComparisonResult', ->
    it 'does what the name says', ->
      $('#competitive_list_example').data('competitiveList').outmatchedCompetitorsByCompetitor = 2: [1]
      $('#competitive_list_example').data('competitiveList').defeatedCompetitorsByCompetitor = 1: [2]
      
      $('#competitive_list_example').competitiveList('removeCompetitorsComparisonResult', 2, 1)
      
      expect($('#competitive_list_example').data('competitiveList').outmatchedCompetitorsByCompetitor).toEqual 2: []
      expect($('#competitive_list_example').data('competitiveList').defeatedCompetitorsByCompetitor).toEqual 1: []
      
  describe '#letOutMatchedCompetitorsOfWinnerWinAgainstLoser', ->
    beforeEach ->
      $('#competitive_list_example').data('competitiveList').matches = [
        { competitors: [1, 2], winner: 1 },
        { competitors: [1, 3], winner: 3 },
        { competitors: [1, 4] },
        { competitors: [2, 3] },
        { competitors: [2, 4] },
        { competitors: [3, 4] }
      ]
      $('#competitive_list_example').data('competitiveList').defeatedCompetitorsByCompetitor = { 1: [ 2 ], 3: [ 1 ] }
      $('#competitive_list_example').data('competitiveList').outmatchedCompetitorsByCompetitor = { 2: [ 1 ], 1: [ 3 ] }
      $('#competitive_list_example').data('competitiveList').currentMatch = $('#competitive_list_example').data('competitiveList').matches[0]
      
    context 'match has no winner yet', ->
      it 'does what the name says', ->
        $('#competitive_list_example').competitiveList('letOutMatchedCompetitorsOfWinnerWinAgainstLoser', 1, 2)
        
        expect($('#competitive_list_example').data('competitiveList').matches[3]).toEqual { 
          competitors: [2, 3], winner: 3, auto_winner: true, manual_winner_changed: false, foot_note_competitor: 1,
          auto_winner_type: 1, auto_winner_recursion: false,
          auto_winner_reason: 'loser of last match has been defeated by outmatched competitor of<br/>winner <sup>[1]</sup>'
        }
        
    context 'match has already a different winner', ->
      it 'changes the winner of the match', ->
        $('#competitive_list_example').data('competitiveList').matches[3]['winner'] = 2
        $('#competitive_list_example').data('competitiveList').defeatedCompetitorsByCompetitor[2] = [ 3 ]
        $('#competitive_list_example').data('competitiveList').outmatchedCompetitorsByCompetitor[3] = [ 2 ]
        
        $('#competitive_list_example').competitiveList('letOutMatchedCompetitorsOfWinnerWinAgainstLoser', 1, 2)
        
        expect($('#competitive_list_example').data('competitiveList').matches[3]).toEqual {
          competitors: [2, 3], winner: 3, auto_winner: true, manual_winner_changed: true, foot_note_competitor: 1,
          auto_winner_type: 1, auto_winner_recursion: false,
          auto_winner_reason: 'loser of last match has been defeated by outmatched competitor of<br/>winner <sup>[1]</sup>'
        }
        
  describe '#moveCompetitorToPosition', ->
    context 'position is not available', ->
      it 'alerts a message', ->
        spyOn window, 'alert'
        
        $('#competitive_list_example').competitiveList('moveCompetitorToPosition', 3, 4)
        
        expect(window.alert).toHaveBeenCalledWith 'This position is not available!'
        
    context 'position is 1', ->
      context 'competitor is already on this positon', ->
        it 'lets the competitor win against competitor with position 2', ->
          $('#competitive_list_example').data('competitiveList').matches = [
            { competitors: [1, 2], winner: 2 },
            { competitors: [1, 3], winner: 3 },
            { competitors: [2, 3], winner: 2 }
          ]
          $('#competitive_list_example').data('competitiveList').outmatchedCompetitorsByCompetitor = { 1: [2, 3], 2: [], 3: [ 2 ] }
          $('#competitive_list_example').data('competitiveList').defeatedCompetitorsByCompetitor = { 1: [], 2: [1, 3], 3: [ 1 ] }
          
          $('#competitive_list_example').competitiveList('moveCompetitorToPosition', 1, 1)
          
          expect($('#competitive_list_example').data('competitiveList').matches).toEqual [
            { competitors: [1, 2], winner: 1 },
            { competitors: [1, 3], winner: 1 },
            { competitors: [2, 3], winner: 2 }
          ]
          
      context 'competitor is not yet on this positon', ->
        it 'lets the competitor win against competitor with position 1', ->
          $('#competitive_list_example').data('competitiveList').matches = [
            { competitors: [1, 2], winner: 1 },
            { competitors: [1, 3], winner: 1 },
            { competitors: [2, 3], winner: 2 }
          ]
          $('#competitive_list_example').data('competitiveList').outmatchedCompetitorsByCompetitor = { 1: [], 2: [1], 3: [1, 2] }
          $('#competitive_list_example').data('competitiveList').defeatedCompetitorsByCompetitor = { 1: [2, 3], 2: [3], 3: [] }
          
          $('#competitive_list_example').competitiveList('moveCompetitorToPosition', 3, 1)
          
          expect($('#competitive_list_example').data('competitiveList').matches).toEqual [
            { competitors: [1, 2], winner: 1 },
            { competitors: [1, 3], winner: 3 },
            { competitors: [2, 3], winner: 3 }
          ]
    context 'position is greater than 1', ->
      context 'competitor is already on this positon', ->
        it 'lets the competitor lose against competitor with position - 1 and win against competitor with position + 1', ->
          $('#competitive_list_example').data('competitiveList').matches = [
            { competitors: [1, 2], winner: 1 },
            { competitors: [1, 3, ], winner: 1 },
            { competitors: [2, 3], winner: 3 }
          ]
          $('#competitive_list_example').data('competitiveList').outmatchedCompetitorsByCompetitor = { 1: [], 2: [1, 3], 3: [1] }
          $('#competitive_list_example').data('competitiveList').defeatedCompetitorsByCompetitor = { 1: [2, 3], 2: [], 3: [2] }
          spyOn($('#competitive_list_example').data('competitiveList'), 'getPositions').and.returnValue { 1: 1, 2: 3, 3: 2 }
          
          $('#competitive_list_example').competitiveList('moveCompetitorToPosition', 2, 2)
          
          expect($('#competitive_list_example').data('competitiveList').matches).toEqual [
            { competitors: [1, 2], winner: 1 },
            { competitors: [1, 3], winner: 1 },
            { competitors: [2, 3], winner: 2 }
          ]
      context 'competitor is not yet on this positon', ->
        it 'lets the competitor lose against competitor with position - 1 and win against competitor with position', ->
          $('#competitive_list_example').data('competitiveList').matches = [
            { competitors: [1, 2], winner: 1 },
            { competitors: [1, 3], winner: 1 },
            { competitors: [2, 3], winner: 2 }
          ]
          $('#competitive_list_example').data('competitiveList').outmatchedCompetitorsByCompetitor = { 1: [], 2: [1], 3: [1, 2] }
          $('#competitive_list_example').data('competitiveList').defeatedCompetitorsByCompetitor = { 1: [2, 3], 2: [3], 3: [] }
          
          $('#competitive_list_example').competitiveList('moveCompetitorToPosition', 3, 2)
          
          expect($('#competitive_list_example').data('competitiveList').matches).toEqual [
            { competitors: [1, 2], winner: 1 },
            { competitors: [1, 3], winner: 1 },
            { competitors: [2, 3], winner: 3 }
          ]
          
  describe '#sortByMostWins', ->
    beforeEach ->
      jasmine.Ajax.install()
      
    afterEach ->
      jasmine.Ajax.uninstall()
      
    it 'sorts list with competitors by most wins descending and puts data to $(\'.competitive_list\').data(\'update-all-positions-path\')', ->
      $('#competitive_list_example').data('competitiveList').competitors = [1, 2, 3]
      $('#competitive_list_example').data('competitiveList').matches = [
        { competitors: [1, 2], winner: 2 },
        { competitors: [1, 3], winner: 1 },
        { competitors: [2, 3], winner: 2 }
      ]
      
      $(document).ready ->
        $('#competitive_list_example').competitiveList('sortByMostWins')
        
        positions = {}
        currentPosition = 1
        
        $.each $('.competitive_list li'), (index, element) ->
          positions[currentPosition] = $(element).data('id')
          currentPosition += 1
          
        expect(positions).toEqual { 1: 2, 2: 1, 3: 3 }
        request = jasmine.Ajax.requests.mostRecent()
        expect(request.url).toBe '/items/update_all'
        
        expect(request.data()).toEqual {
          _method: [ 'put' ]
          'positions[1]': [ '2' ]
          'positions[2]': [ '1' ]
          'positions[3]': [ '3' ]
          matches: [ JSON.stringify($('#competitive_list_example').data('competitiveList').matches) ]
        }