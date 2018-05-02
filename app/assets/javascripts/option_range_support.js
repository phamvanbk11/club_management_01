$(document).ready(function(){
  $(document).on('change', '#range_support_operator', function(){
    if($('#range_support_operator') .val() === gon.operators.range.toString()){
      $('#range_support_value_from').addClass("col-md-5");
      $('#range_support_value_to').show();
      $('#range_support_value_to').prop('required', true);
      $('#span-icon').show();
    } 
    else {
      $('#range_support_value_from').removeClass("col-md-5");
      $('#range_support_value_to').hide();
      $('#range_support_value_to').prop('required', false)
      $('#span-icon').hide();
    }
  })
})
