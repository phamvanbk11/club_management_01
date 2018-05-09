$(document).ready(function() {
  $(document).on('click', '[data-role="dynamic-fields"] > .form-inline [data-role="remove"]', function(e) {
    e.preventDefault();
    $(this).closest('.form-inline').remove();
    });

  $(document).on('click', '[data-role="dynamic-fields"] > .form-inline [data-role="add"]',function(e) {
    e.preventDefault();
    var container = $(this).closest('[data-role="dynamic-fields"]');
    new_field_group = container.children().filter('.form-inline:first-child').clone();
    new_field_group.find('input').each(function(){
      $(this).val('');
    });
    container.append(new_field_group);
  });
  $( '.datepicker' ).datepicker({dateFormat: 'dd/mm/yy'});

  $('.form-money a.add_fields').data('association-insertion-method', 'after');
  $('#js-expense-details')
  .on('cocoon:after-insert', function(){
  })
  .on('cocoon:after-remove', function() {
    setMoneySponsor();
  });

  $('#js-expense-details').on('change', '.radio-get-money', function(){
    setMoneySponsor();
  });
  $('#js-expense-details').on('change', '.radio-pay-money', function(){
    setMoneySponsor();
  });

  $(document).on('keyup', '.js-input-money', function(){
    setMoneySponsor();
  });
});
function setMoneySponsor(){
  var pay = 0;
  var get = 0;
  var array_id_radio_pay = [];
  var array_id_money = [];
  $('#js-expense-details').find('.radio-pay-money:visible').each(function(){
    array_id_radio_pay.push($(this).attr('id'));
  });

  $('#js-expense-details').find('.js-input-money:visible').each(function(){
    array_id_money.push($(this).attr('id'));
  });

  $.each(array_id_radio_pay, function(index, id){
    if ($('#' + id).is(':checked')){
      pay += parseInt($('#' + array_id_money[index]).val().replace(/,/g, ''));
    }
    else
    {
      get += parseInt($('#' + array_id_money[index]).val().replace(/,/g, ''));
    }
  });

  $('#js-pay-total').html(format(pay) + I18n.t('number.currency.format.unit'));
  $('#js-get-total').html(format(get) + I18n.t('number.currency.format.unit'));
}
