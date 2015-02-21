describe 'CompetitiveList', ->
  beforeEach ->
    loadFixtures 'competitive_list_with_3_competitors.html'
    window.competitive_list_example = new CompetitiveList(id: '#competitive_list_example')
    
  describe '#start', ->
    it 'loads the competitors from the DOM and sets how many matches are left', ->
      $(document).ready ->
        window.competitive_list_example.start()
        expect(window.competitive_list_example.competitors).toEqual [1, 2, 3]
        expect(window.competitive_list_example.matchesLeft).toEqual 3
        
  describe '#generateMatches', ->
    it 'generates matches between all competitors', ->
      window.competitive_list_example.competitors = [1, 2, 3]
      window.matches = []
      window.competitive_list_example.generateMatches()
      expect(window.matches).toEqual [
        { competitors: [1, 2] }
        { competitors: [1, 3] }
        { competitors: [2, 3] }
      ]
      
  describe '#removeMatchesOfNonExistingCompetitors', ->
    it 'does what the name says', ->
      window.competitive_list_example.competitors = [1, 2, 4]
      window.matches = [
        { competitors: [1, 2] }
        { competitors: [1, 3] }
        { competitors: [2, 3] }
      ]
      window.competitive_list_example.removeMatchesOfNonExistingCompetitors()
      expect(window.matches).toEqual [ { competitors: [1, 2] } ]
      
  describe '#nextMatch', ->
    context 'matches to rate left', ->
      it 'sets the current match to next match in matches list and shows form to appoint winner', ->
        window.matches = [ { competitors: [1, 2] } ]
        
        $(document).ready ->
          expect(window.competitive_list_example.nextMatch(false)).toEqual true
          expect(window.competitive_list_example.currentMatch).toEqual window.matches[0]
          expect($('#competitive_list_example .save_match_results_link').css('display')).toEqual 'inline-block'
          expect($('.modal-header:contains(\'Appoint Winner\')').length).toEqual 1
          
    context 'no matches to rate left', ->
      beforeEach ->
        window.matches = [ { competitors: [1, 2], winner: 1} ]
        
      context 'called from start', ->
        it 'alerts a message, ', ->
          spyOn window, 'alert'
          
          $(document).ready ->
            expect(window.competitive_list_example.nextMatch(true)).toEqual false
            expect(window.competitive_list_example.currentMatch).toEqual null
            expect(window.alert).toHaveBeenCalledWith 'No matches to rate left.'
            
      context 'called not from start', ->
        it 'shows a modal saying that no matches to rate are left', ->
          $(document).ready ->
            expect(window.competitive_list_example.nextMatch(false)).toEqual true
            expect(window.competitive_list_example.currentMatch).toEqual null
            expect($('.modal-header:contains(\'No matches to rate left.\')').length).toEqual 1
            
  describe '#otherCompetitorOfMatch', ->
    it 'returns the id of the match competitor other than the given one', ->
      expect(window.competitive_list_example.otherCompetitorOfMatch({ competitors: [1, 2] }, 1)).toEqual 2
      
  describe '#nameOfCompetitor', ->
    context 'don\'t consider proc', ->
      it 'returns the HTML of .competitor_name', ->
        expect(window.competitive_list_example.nameOfCompetitor(1, false)).toEqual 'P1'
        
    context 'consider proc', ->
      it 'passes $(\'.competitor_name\').data(\'proc-argument\') to the proc', ->
        window.competitive_list_example = new CompetitiveList id: '#competitive_list_example', competitor_name_proc: (value) ->
          return 'Player:' + value
        
        expect(window.competitive_list_example.nameOfCompetitor(1, true)).toEqual 'Player:Dummy'
        
  describe '#cancelTournament', ->
    it 'hides the save match results link', ->
      spyOn window.competitive_list_example, 'sortByMostWins'
      
      window.competitive_list_example.cancelTournament()
      
      expect($('#competitive_list_example .save_match_results_link').css('display')).toEqual 'none'
      expect(window.competitive_list_example.sortByMostWins).toHaveBeenCalled()
      
  describe '#appointWinnerOfMatchByInput', ->
    it 'passes winner and loser to @appointWinnerOfMatch', ->
      spyOn window.competitive_list_example, 'appointWinnerOfMatch'
      window.matches = [ { competitors: [1, 2] } ]
      window.competitive_list_example.nextMatch false
      
      window.competitive_list_example.appointWinnerOfMatchByInput()
      
      expect(window.competitive_list_example.appointWinnerOfMatch).toHaveBeenCalledWith 0, 1, 2, true
      
  describe '#appointWinnerOfMatch', ->
    beforeEach ->
      window.matches = [ { competitors: [1, 2] } ]
      window.competitive_list_example.nextMatch false
      
    context 'decrementMatchesLeft is true', ->
      it 'decrements the matches left', ->
        window.competitive_list_example.matchesLeft = 1
        window.competitive_list_example.appointWinnerOfMatch 0, 1, 2, true
        expect(window.competitive_list_example.matchesLeft).toEqual 0
        
    context 'decrementMatchesLeft is false', ->
      it 'does not decrement the matches left', ->
        window.competitive_list_example.matchesLeft = 1
        window.competitive_list_example.appointWinnerOfMatch 0, 1, 2, false
        expect(window.competitive_list_example.matchesLeft).toEqual 1
        
    it 'calls some instance methods properly', ->
      spyOn window.competitive_list_example, 'updateDefeatedAndOutmatchedCompetitorsByCompetitor'
      spyOn window.competitive_list_example, 'letWinnerWinMatchesAgainstCompetitorsWhichLoseAgainstLoser'
      spyOn window.competitive_list_example, 'letOutMatchedCompetitorsOfWinnerWinAgainstLoser'
      
      window.competitive_list_example.appointWinnerOfMatch 0, 1, 2, true
      
      expect(window.competitive_list_example.updateDefeatedAndOutmatchedCompetitorsByCompetitor).toHaveBeenCalledWith 1, 2
      expect(window.competitive_list_example.letWinnerWinMatchesAgainstCompetitorsWhichLoseAgainstLoser).toHaveBeenCalledWith 1, 2
      expect(window.competitive_list_example.letOutMatchedCompetitorsOfWinnerWinAgainstLoser).toHaveBeenCalledWith 1, 2
      
  describe '#updateDefeatedAndOutmatchedCompetitorsByCompetitor', ->
    it 'updates the maps defeatedCompetitorsByCompetitor and outmatchedCompetitorsByCompetitor', ->
      window.competitive_list_example.defeatedCompetitorsByCompetitor = {}
      window.competitive_list_example.outmatchedCompetitorsByCompetitor = {}
      
      window.competitive_list_example.updateDefeatedAndOutmatchedCompetitorsByCompetitor 1, 2
      
      expect(window.competitive_list_example.defeatedCompetitorsByCompetitor[1]).toEqual [ 2 ]
      expect(window.competitive_list_example.defeatedCompetitorsByCompetitor[2]).toEqual undefined
      expect(window.competitive_list_example.outmatchedCompetitorsByCompetitor[1]).toEqual undefined
      expect(window.competitive_list_example.outmatchedCompetitorsByCompetitor[2]).toEqual [ 1 ]
      
  describe '#letWinnerWinMatchesAgainstCompetitorsWhichLoseAgainstLoser', ->
    beforeEach ->
      window.matches = [
        { competitors: [1, 2], winner: 1 },
        { competitors: [1, 3] },
        { competitors: [2, 3], winner: 2 }
      ]
      window.competitive_list_example.defeatedCompetitorsByCompetitor = { 1: [2], 2: [3] }
      window.competitive_list_example.outmatchedCompetitorsByCompetitor = { 2: [1], 3: [ 2 ] }
      window.competitive_list_example.currentMatch = window.matches[0]
      
    context 'match has no winner yet', ->
      it 'let winner win matches against competitors which have lost against loser', ->
        window.competitive_list_example.letWinnerWinMatchesAgainstCompetitorsWhichLoseAgainstLoser 1, 2
        
        expect(window.matches[1]).toEqual { 
          competitors: [1, 3], winner: 1, auto_winner: true, manual_winner_changed: false, foot_note_competitor: 2, 
          auto_winner_type: 0, auto_winner_recursion: false,
          auto_winner_reason: 'loser has been defeated because he loses against the loser <sup>[1]</sup> of last match'
        }
      
    context 'match has already a different winner', ->
      it 'changes the winner of the match', ->
        window.matches[1]['winner'] = 3
        window.competitive_list_example.defeatedCompetitorsByCompetitor[3] = [1]
        window.competitive_list_example.outmatchedCompetitorsByCompetitor[1] = [3]
        
        window.competitive_list_example.letWinnerWinMatchesAgainstCompetitorsWhichLoseAgainstLoser 1, 2
        
        expect(window.matches[1]).toEqual {
          competitors: [1, 3], winner: 1, auto_winner: true, manual_winner_changed: true, foot_note_competitor: 2,
          auto_winner_type: 0, auto_winner_recursion: false,
          auto_winner_reason: 'loser has been defeated because he loses against the loser <sup>[1]</sup> of last match'
        }
        
  describe '#removeCompetitorsComparisonResult', ->
    it 'does what the name says', ->
      window.competitive_list_example.outmatchedCompetitorsByCompetitor = 2: [1]
      window.competitive_list_example.defeatedCompetitorsByCompetitor = 1: [2]
      
      window.competitive_list_example.removeCompetitorsComparisonResult 2, 1
      
      expect(window.competitive_list_example.outmatchedCompetitorsByCompetitor).toEqual 2: []
      expect(window.competitive_list_example.defeatedCompetitorsByCompetitor).toEqual 1: []
      
  describe '#letOutMatchedCompetitorsOfWinnerWinAgainstLoser', ->
    beforeEach ->
      window.matches = [
        { competitors: [1, 2], winner: 1 },
        { competitors: [1, 3], winner: 3 },
        { competitors: [1, 4] },
        { competitors: [2, 3] },
        { competitors: [2, 4] },
        { competitors: [3, 4] }
      ]
      window.competitive_list_example.defeatedCompetitorsByCompetitor = { 1: [ 2 ], 3: [ 1 ] }
      window.competitive_list_example.outmatchedCompetitorsByCompetitor = { 2: [ 1 ], 1: [ 3 ] }
      window.competitive_list_example.currentMatch = window.matches[0]
      
    context 'match has no winner yet', ->
      it 'does what the name says', ->
        window.competitive_list_example.letOutMatchedCompetitorsOfWinnerWinAgainstLoser 1, 2
        
        expect(window.matches[3]).toEqual { 
          competitors: [2, 3], winner: 3, auto_winner: true, manual_winner_changed: false, foot_note_competitor: 1,
          auto_winner_type: 1, auto_winner_recursion: false,
          auto_winner_reason: 'loser of last match has been defeated by outmatched competitor of<br/>winner <sup>[1]</sup>'
        }
        
    context 'match has already a different winner', ->
      it 'changes the winner of the match', ->
        window.matches[3]['winner'] = 2
        window.competitive_list_example.defeatedCompetitorsByCompetitor[2] = [ 3 ]
        window.competitive_list_example.outmatchedCompetitorsByCompetitor[3] = [ 2 ]
        
        window.competitive_list_example.letOutMatchedCompetitorsOfWinnerWinAgainstLoser 1, 2
        
        expect(window.matches[3]).toEqual {
          competitors: [2, 3], winner: 3, auto_winner: true, manual_winner_changed: true, foot_note_competitor: 1,
          auto_winner_type: 1, auto_winner_recursion: false,
          auto_winner_reason: 'loser of last match has been defeated by outmatched competitor of<br/>winner <sup>[1]</sup>'
        }
        
  describe '#moveCompetitorToPosition', ->
    context 'position is not available', ->
      it 'alerts a message', ->
        spyOn window, 'alert'
        
        window.competitive_list_example.moveCompetitorToPosition 3, 4
        
        expect(window.alert).toHaveBeenCalledWith 'This position is not available!'
        
    context 'position is 1', ->
      context 'competitor is already on this positon', ->
        it 'lets the competitor win against competitor with position 2', ->
          window.matches = [
            { competitors: [1, 2], winner: 2 },
            { competitors: [1, 3], winner: 3 },
            { competitors: [2, 3], winner: 2 }
          ]
          window.competitive_list_example.outmatchedCompetitorsByCompetitor = { 1: [2, 3], 2: [], 3: [ 2 ] }
          window.competitive_list_example.defeatedCompetitorsByCompetitor = { 1: [], 2: [1, 3], 3: [ 1 ] }
          
          window.competitive_list_example.moveCompetitorToPosition 1, 1
          
          expect(window.matches).toEqual [
            { competitors: [1, 2], winner: 1 },
            { competitors: [1, 3], winner: 1, manual_winner_changed: false },
            { competitors: [2, 3], winner: 2 }
          ]
          
      context 'competitor is not yet on this positon', ->
        it 'lets the competitor win against competitor with position 1', ->
          window.matches = [
            { competitors: [1, 2], winner: 1 },
            { competitors: [1, 3], winner: 1 },
            { competitors: [2, 3], winner: 2 }
          ]
          window.competitive_list_example.outmatchedCompetitorsByCompetitor = { 1: [], 2: [1], 3: [1, 2] }
          window.competitive_list_example.defeatedCompetitorsByCompetitor = { 1: [2, 3], 2: [3], 3: [] }
          
          window.competitive_list_example.moveCompetitorToPosition 3, 1
          
          expect(window.matches).toEqual [
            { competitors: [1, 2], winner: 1 },
            { competitors: [1, 3], winner: 3 },
            { competitors: [2, 3], winner: 3, manual_winner_changed: false }
          ]
    context 'position is greater than 1', ->
      context 'competitor is already on this positon', ->
        it 'lets the competitor lose against competitor with position - 1 and win against competitor with position + 1', ->
          window.matches = [
            { competitors: [1, 2], winner: 1 },
            { competitors: [1, 3, ], winner: 1 },
            { competitors: [2, 3], winner: 3 }
          ]
          window.competitive_list_example.outmatchedCompetitorsByCompetitor = { 1: [], 2: [1, 3], 3: [1] }
          window.competitive_list_example.defeatedCompetitorsByCompetitor = { 1: [2, 3], 2: [], 3: [2] }
          spyOn(window.competitive_list_example, 'getPositions').and.returnValue { 1: 1, 2: 3, 3: 2 }
          
          window.competitive_list_example.moveCompetitorToPosition 2, 2
          
          expect(window.matches).toEqual [
            { competitors: [1, 2], winner: 1 },
            { competitors: [1, 3], winner: 1 },
            { competitors: [2, 3], winner: 2 }
          ]
      context 'competitor is not yet on this positon', ->
        it 'lets the competitor lose against competitor with position - 1 and win against competitor with position', ->
          window.matches = [
            { competitors: [1, 2], winner: 1 },
            { competitors: [1, 3], winner: 1 },
            { competitors: [2, 3], winner: 2 }
          ]
          window.competitive_list_example.outmatchedCompetitorsByCompetitor = { 1: [], 2: [1], 3: [1, 2] }
          window.competitive_list_example.defeatedCompetitorsByCompetitor = { 1: [2, 3], 2: [3], 3: [] }
          
          window.competitive_list_example.moveCompetitorToPosition 3, 2
          
          expect(window.matches).toEqual [
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
      window.competitive_list_example.competitors = [1, 2, 3]
      window.matches = [
        { competitors: [1, 2], winner: 2 },
        { competitors: [1, 3], winner: 1 },
        { competitors: [2, 3], winner: 2 }
      ]
      
      $(document).ready ->
        window.competitive_list_example.sortByMostWins()
        
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
          matches: [ JSON.stringify(window.matches) ]
        }