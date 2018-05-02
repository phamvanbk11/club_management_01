$(document).ready(function(){
  $(document).on('change', '.select-month', function(){
    ajax_request_list_member();
  });

  $(document).on('change', '.select-year', function(){
    ajax_request_list_member();
  })
})
function ajax_request_list_member(){
  month = $('.select-month').val();
  year = $('.select-year').val();
  slug_club = $('#club_slug').val();
  $.ajax({
    url: '/setting_clubs/' + slug_club,
    data: {time: month, year: year},
    type: 'GET'
  })
}
