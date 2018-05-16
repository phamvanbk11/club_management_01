$(document).ready(function () {
  $('#user_tag_ids').chosen({
    allow_single_deselect: true,
    width: '100%'
  });

  $(document).on('click', '#select-tag', function(){
    $('.my_settings').click();
    $('.chosen-container input').focus();
  });
});
