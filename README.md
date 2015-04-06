# competitive_list.js [![Build Status](https://travis-ci.org/volontarian/jquery-competitive_list.svg?branch=master)](https://travis-ci.org/volontarian/jqery-competitive_list)

## Demo

You can either watch [this screencast](https://www.youtube.com/watch?v=UlXJoYn_dek) or try it in [this JS Bin](http://jsbin.com/zobaqa/1/).

## Example

```html
<html>
  <head>
    <link href="//netdna.bootstrapcdn.com/twitter-bootstrap/2.3.2/css/bootstrap-combined.min.css" rel="stylesheet" type="text/css" />
  </head>
  <body>
    <div id="bootstrap_modal" class="modal hide fade"></div>
    
    <div id="competitive_list_for_items">    
      <ul class="competitive_list" data-update-all-positions-path="/items/update_all">
        <li id="competitor_1" data-id="1" data-position="1">
          <span class="competitor_position">1</span>
          P1
          <span class="competitor_name hide">
            P1
          </span>
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
        <button type="button" class="btn competitive_list_start_link">Sort by round-robin tournament</button>
        <button type="button" class="btn hide save_match_results_link">
          <span class='icon-warning-sign'></span> Save match results
        </button>
      </p>
    </div>
    
    <script src="//code.jquery.com/jquery.min.js"></script>
    <script src="//netdna.bootstrapcdn.com/twitter-bootstrap/2.3.2/js/bootstrap.min.js"></script>
    <script src="https://raw.githubusercontent.com/gawlista/competitive_list.js/master/competitive_list.min.js"></script>
    <script>
    //<![CDATA[
    
      window.matches = []
    
      $( document ).ready(function() {
        $('#competitive_list_for_items').competitiveList();
      });
      
    //]]>
    </script>
  </body>
</html>
```

## Auto Winner

A winner of a match will be appointed automatically sometimes, what reduces the matches to vote dramatically.
So the winner of the match automatically beats the competitors which have been defeated by the loser of the match and furthermore the defeaters of the match winner also beat the match loser automatically.

## competitor_name_proc

You can pass the constructor of CompetitiveList a proc of which the result will be rendered in the match modal at the place of the competitor.
data-proc-argument of .competitor_name will be passed to this proc.

```html
<div id="competitive_list_for_items">    
  <ul class="competitive_list" data-update-all-positions-path="/items/update_all">
    <li id="competitor_1" data-id="1" data-position="1">
      <span class="competitor_position">1</span>
      P1
      <span class="competitor_name hide" data-proc-argument="value">
        P1
      </span>
    </li>
    
    ...
    
  </ul>
</div>

<script>
//<![CDATA[

  $( document ).ready(function() {
    $('#competitive_list_for_items').competitiveList({
      competitor_name_proc: function(value) {
        return value;
      }
    });
  });
  
//]]>
</script>
```

## @moveCompetitorToPosition(competitorId, position, after_update_request_proc = null)

You can move a competitor to a position without rating all matches which is good for drag & drop.
In that case the competitor loses against all opponents with position <= position - 1 unless position is 1.
Furthermore the competitor wins against all opponents with position >= position if competitor is not yet on this position else the competitor wins against all opponents with position >= position + 1.

## Contribution

Pleae follow this screencast http://railscasts.com/episodes/300-contributing-to-open-source

To change the code of the plugin you should only change the file under app/assets/javascripts/competitive_list.js.coffee
The tests can be run after you started the Rails server and go to http://localhost:3000/specs
Alternatively the tests can be run by this command:

```bash
RAILS_ENV=test bundle exec rake spec:javascript
```

When you're done with that you can release the code as:

* uncompressed vanilla JavaScript: copy & paste http://localhost:3000/assets/competitive_list.js?body=1 to /competitive_list.js in the repository
* minified JavaScript: run RAILS_ENV=production bundle exec rake assets:precompile, copy /public/assets/competitive_list-#{token}.js to /competitive_list.min.js in the repository and run rm -rf public/assets/
