jQuery(document).ready(function($) {
  $('.tab_detail_club .ui-block:not(:first)').hide();
  $('.tab_list_detail_club li a').click(function(){
    $('.tab_detail_club .ui-block').hide('slow');
    $('.tab_list_detail_club li a').removeClass('active');
    $(this).addClass('active');
    var id=$(this).attr('href');
    if ($(this).attr('href') != id) {
      $(id).show('slow');
      return false;
    };
  });
});
