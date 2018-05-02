$(document).ready(function() {
  $('#select_orgzt').on('change', function() {
    user_id = $('#user_id').val()
    var dataform = {
      organization_id: $('.select_custom').val()
    }
    $.ajax('/users/'+user_id+'/club_requests/new',
    {
      type: 'GET',
      data: dataform,
      datatype: 'json',
      success: function(result) {
        $('#members').text('')
        $('#user_club_request').html(result.html_users);
        $('#js-radio-frequencies').html(result.html_frequencies);
        $('#select_club_type').empty();
        $.each(result.club_types, function(){
          $('<option />', {
            val: this.id,
            text: this.name
          }).appendTo('#select_club_type');
        });
      },
      error: function (result) {
        alert(I18n.t('error_load_user_organization'));
      }
    });
  });
});
