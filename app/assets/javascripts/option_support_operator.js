$(document).ready(function(){
  $(document).on('change', '.operator', function(){
    if($(this) .val() === gon.operators.range.toString()){
      $('.value_from').addClass('col-md-5');
      $('.value_to').removeClass('hide-div');
      $('.value_to').prop('required', true);
      $('.span-icon').removeClass('hide-div');
    }
    else {
      $('.value_from').removeClass('col-md-5');
      $('.value_to').addClass('hide-div');
      $('.value_to').prop('required', false)
      $('.span-icon').addClass('hide-div');
    }
  })
})
