$(document).ready(function () {
  $('#modal-add-user-event').on('change', '#checkall', function(){
    $('.checkbox').prop('checked', $(this).prop('checked'));
  });

  $('#modal-add-user-event').on('click', '#detail-members', function(e){
    e.preventDefault();
    $('#modal-list-member').hide();
    $('#modal-add-member').show();
  });

  $('#modal-add-user-event').on('click', '#add-member-join', function(e){
    e.preventDefault();
    $('#modal-list-member').show();
    $('#modal-add-member').hide();
  });

  $(document).on('click', '#js-btn-delete-members', function(){
    $('#form-delete-member-event').submit();
  })
});
