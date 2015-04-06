this.CompetitiveListExtension = (function() {
  function CompetitiveListExtension() {
    $('#competitive_list_example').competitiveList();
    
    $(document.body).on("click", "#save_data_button", (function(_this) {
      return function(event) {
        event.preventDefault();
        return _this.saveData();
      };
    })(this));
    $(document.body).on("click", "#load_data_button", (function(_this) {
      return function(event) {
        event.preventDefault();
        return _this.loadData();
      };
    })(this));
    $(document.body).on("click", "#add_competitor_link", (function(_this) {
      return function(event) {
        event.preventDefault();
        return _this.addCompetitor(null, null, prompt('Enter a competitor name!'));
      };
    })(this));
  }

  CompetitiveListExtension.prototype.addCompetitor = function(id, position, name) {
    var html, ids;
    if (id === null) {
      window.competitors = jQuery.map($('.competitive_list li'), function(c) {
        return parseInt($(c).data('id'));
      });
      ids = window.competitors.sort();
      id = 1;
      if (ids.length > 0) {
        id = ids[ids.length - 1] + 1;
      }
      position = window.competitors.length + 1;
    }
    html = '<li id="competitor_' + id + '" data-id="' + id + '" data-position="' + position + '" data-name="' + name + '">';
    html += '<span class="competitor_name hide">' + name + '</span>';
    html += '<span class="competitor_position">' + position + '</span> ' + name + '</li>';
    return $('.competitive_list').append(html);
  };

  CompetitiveListExtension.prototype.saveData = function() {
    var competitorRecords;
    competitorRecords = jQuery.map($('.competitive_list li'), function(c) {
      return {
        id: $(c).data('id'),
        position: $(c).data('position'),
        name: $(c).data('name')
      };
    });
    $('#competitors_text').val(JSON.stringify(competitorRecords));
    return $('#matches_text').val(JSON.stringify(window.matches));
  };

  CompetitiveListExtension.prototype.loadData = function() {
    var competitorRecords;
    competitorRecords = JSON.parse($('#competitors_text').val());
    window.matches = JSON.parse($('#matches_text').val());
    $('.competitive_list').empty();
    $.each(competitorRecords, (function(_this) {
      return function(index, competitor) {
        return _this.addCompetitor(competitor['id'], competitor['position'], competitor['name']);
      };
    })(this));
    $('#competitors_text').val('');
    return $('#matches_text').val('');
  };

  return CompetitiveListExtension;

})();

$( document ).ready(function() {
  new CompetitiveListExtension();
});