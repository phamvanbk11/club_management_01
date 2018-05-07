$(document).ready(function(){
  $(document).on('keypress', '#js-list-money-supports td', function(e){
    if (e.which == 13){
      e.preventDefault();
      post_data(this);
    }
  })

  $(document).on('change', '#js-list-money-supports td', function(e){
    post_data(this);
  })
})

function post_data(input){
  id = $(input).attr('data-id');
  organization_slug = $('#organization_slug').val();
  point_id = $(input).attr('data-point');
  member_id = $(input).attr('data-member');
  money = $(input).html();
  data = {id: id, money: money, arr_range: [member_id, point_id], organization_id: organization_slug}
  $.ajax({
    url: '/money_supports',
    type: 'POST',
    data: data
  });
}
