// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require turbolinks
//= require_tree .
//= require jquery
//= require jquery.purr
//= require jquery_ujs
//= require best_in_place
//= require popper
//= require bootstrap-sprockets
//= require bootstrap.js
//= require js.cookie
//= require jstz
//= require browser_timezone_rails/set_time_zone

$(document).on('turbolinks:load', function() {
  /* Activating Best In Place */
  $(".best_in_place").best_in_place();
});

$('#myModal').on('shown.bs.modal', function () {
    $('#myInput').trigger('focus')
})
