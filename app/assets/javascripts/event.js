$(document).ready(function () {
  $('#event_event_category').change(function(){
    var cat = $('#event_event_category').val();
    if (cat === gon.event_money.donate.toString()){
      $('#expense').hide();
      $('.expense_details').hide();
      $('#event_expense').prop('disabled', false);
      $('#label-expense').text($('#subsidy').text());
      $('#money-details').removeClass('form-money');
      $('.input-require').prop('required', false);
    }
    else if (cat === gon.event_money.money.toString()) {
      $('#expense').show();
      $('#label-expense').text($('#subsidy').text());
      $('.expense_details').show();
      $('.get-money-member').hide();
      $('#event_expense').prop('disabled', true);
      $('#label-expense').text($('#money').text());
      $('#money-details').addClass('form-money');
      $('.input-require').prop('required', true);
    }
    else if (cat === gon.event_money.get_money_member.toString()) {
      $('#label-expense').text($('#get_money_member').text());
      $('#expense').show();
      $('.expense_details').hide();
      $('#event_expense').prop('disabled', false);
      $('#money-details').removeClass('form-money');
      $('.input-require').prop('required', false);
    }
    else if (cat === gon.event_money.subsidy.toString()) {
      $('#label-expense').text($('#subsidy').text());
      $('#expense').show();
      $('.expense_details').hide();
      $('#event_expense').prop('disabled', false);
      $('#money-details').removeClass('form-money');
      $('.input-require').prop('required', false);
    }
  });
});
