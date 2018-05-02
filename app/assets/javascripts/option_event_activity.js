$(document).ready(function () {
  var val = $('#event_event_details_attributes_0_description').val();
  if (val === ''){
    $('.input-require').prop('required', false);
  }
  $('#event_event_category').change(function(){
    var cat = $('#event_event_category').val();
    if (cat === gon.notification.toString()){
      $('#collapse-money').hide();
      $('#money-details').collapse('hide');
      $('.input-require').prop('required', false);
      $('#js-lb-name').text($('#js-lb-name-notification').text());
      $('#js-text-name').attr('placeholder', $('#js-lb-name-notification').text());
      $('#js-auto-create').show();
      $('.images_album').hide();
    }
    else if (cat === gon.activity_money.toString()) {
      $('#collapse-money').show();
      $('#js-lb-name').text($('#js-lb-name-activity').text());
      $('#js-text-name').attr('placeholder', $('#js-lb-name-activity').text());
      $('.images_album').show();
    }
  });

  $("#money-details").on("hide.bs.collapse", function(){
    $('#money-details').removeClass('form-money');
    $('#icon-open').removeClass('fa-caret-square-o-up').addClass('fa-caret-square-o-down');
    $('.input-require').prop('required', false);
    $('#js-auto-create').show();
    $('.description-input').val('');
  });

  $("#money-details").on("show.bs.collapse", function(){
    $('#money-details').addClass('form-money');
    $('#icon-open').removeClass('fa-caret-square-o-down').addClass('fa-caret-square-o-up');
    $('.input-require').prop('required', true);
    $('#js-auto-create').hide();
  });
});
