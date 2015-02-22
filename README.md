# competitive_list.js

## Demo

You can either watch [this screencast](https://www.youtube.com/watch?v=UlXJoYn_dek) or try it in [this JS Bin](http://jsbin.com/marotixigo).

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
          <span class="competitor_name hide" data-proc-argument="value">
            P1
          </span>
        </li>
        <li id="competitor_2" data-id="2" data-position="2">
          <span class="competitor_position">2</span>
          P2
          <span class="competitor_name hide" data-proc-argument="value">
            P2
          </span>
        </li>
        <li id="competitor_3" data-id="3" data-position="3">
          <span class="competitor_position">3</span>
          P3
          <span class="competitor_name hide" data-proc-argument="value">
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
      
      <script src="//code.jquery.com/jquery.min.js"></script>
      <script src="//netdna.bootstrapcdn.com/twitter-bootstrap/2.3.2/js/bootstrap.min.js"></script>
      
      <script>
      //<![CDATA[
      
        window.matches = []
      
        $( document ).ready(function() {
          window.competitive_list = new CompetitiveList({
            id: '#competitive_list_for_items',
            competitor_name_proc: function(value) {
              return value
            }
          });
        });
        
      //]]>
      </script>
    </div>
  </body>
</html>
```

## Contribution

Pleae follow this screencast http://railscasts.com/episodes/300-contributing-to-open-source

To change the code of the plugin you should only change the file under app/assets/javascripts/competitive_list.js.coffee
The tests can be run after you started the Rails server and go to /jasmine.

When you're done with that you can release the code as:

* vanilla JavaScript: copy & paste http://localhost:3000/assets/competitive_list.js?body=1 to /competitive_list.js in the repository
* minified JavaScript: run RAILS_ENV=production bin/rake assets:precompile, copy /public/assets/competitive_list-#{token}.js to /competitive_list.min.js in the repository and run rm -rf public/assets/
