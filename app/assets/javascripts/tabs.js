$(document).ready(function(){
  $('ul.tabs li').click(function(){
    var tab_id = $(this).attr('data-tab');
    $('ul.tabs li').removeClass('current');
    $('.tab-content').removeClass('current');
    $(this).addClass('current');
    $('#'+tab_id).addClass('current');
  });

  $('.tab-in-activity li a').click(function(){
    scroll = $(document).scrollTop();
    $('#list-event-show-notification .event-table').hide();
    $('.tab-in-activity li a').removeClass('w3-border-red');
    $(this).addClass('w3-border-red');
    var id = $(this).attr('href');
    if ($(this).attr('href') != id) {
      $(id).show();
      $(document).scrollTop(scroll);
      return false;
    };
  });
})
