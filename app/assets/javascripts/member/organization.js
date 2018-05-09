jQuery(document).ready(function($) {
  $(document).on('keyup', '#organization_club_search', function() {
    $.get($('#organization_club_form').attr('action'),
      $('#organization_club_form').serialize(), null, 'script');
   });
  $(document).on('change', '#type_club_search', function() {
    $.get($('#organization_club_form').attr('action'),
      $('#organization_club_form').serialize(), null, 'script');
   });

  $(document).on('keyup', '#input_search_timeline', function() {
    $.get($('#organization_time_line_search').attr('action'),
      $('#organization_time_line_search').serialize(), null, 'script');
   });
});
