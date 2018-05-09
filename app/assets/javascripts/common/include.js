jQuery(document).ready(function($) {
  $(document).on('change', '#file-upload', function(e) {
    var input = this;
    var preview = document.getElementById("img-upload");
    var file    = document.querySelector('input[type=file]').files[0];
    var acceptFileTypes = /^image\/(jpg|png|jpeg|gif)$/i;
    if(file['type'].length && !acceptFileTypes.test(file['type'])) {
      alert(I18n.t('js.file_type'));
      input.value = '';
      return false;
    }
    else if (preview != null){
      var reader  = new FileReader();
      reader.onloadend = function () {
        preview.src = reader.result;
      }
      if (file) {
        reader.readAsDataURL(file);
      } else {
        preview.src = '';
      }
    }
  });

  App.init();

  turbolink_app();

  $('.select-select2').select2();

  $('.input-slider').slider();

  $(document).on('keyup', '.js-input-money', function(e){
    convert_to_money(e, this);
  });

  $(document).on('click', '.datepicker', function(){
    $(this).datepicker({dateFormat: 'dd/mm/yy'});
    $(this).datepicker("show");
  });

  $(document).on('keypress', '.datepicker', function(e){
    e.preventDefault();
  });
});

var turbolink_app = function(){
  $(document).ready(function() {
    $('.notify').slideDown(300, function() {
      window.setTimeout(function() {
        $('.notify').slideUp(300, function() {
          $('.notify').hide();
        });
      }, 4000);
    });
    $(document).on('click', '.close-message',function(){
      $('.notify').slideUp(300, function() {
        $('.notify').hide();
      });
    });

    $('.join-club-button').click(function(){
      $('#new_user_club').submit();
    });

    $('.btn-comment').click(function(){
      $('.form-comment-'+$(this).attr('id')).slideDown();
    });

    $(function () {
      var find_list = $('.load-more-toggle');
      for(i = 0; i < find_list.length; i++){
        $('.' + find_list[i].id + ' li').slice(0, 5).show();
      }
      $('.load-more-toggle').on('click', function(e) {
        e.preventDefault();
        var list = e.target.id;
        $('.' + list + ' li:hidden').slice(0, 5).slideDown();
        $('html,body').animate({
          scrollTop: $(this).offset().top
        }, 500);
      });
    });

    $(function () {
      var find_list = $('.load-more-comment');
      for(i = 0; i < find_list.length; i++){
        $('.' + find_list[i].id + ' dt').slice(0, 2).show();
      }
      $('.load-more-comment').on('click', function(e) {
        e.preventDefault();
        var list = e.target.id;
        $('.' + list + ' dt:hidden').slice(0, 5).slideDown();
      });
    });

    var count_notify = function(){
      $('.notification_count').text($('.notification-un_read').length)
      if($('.notification_count').text() == '0'){
        $('.notification_count').fadeOut('slow');
      }
    }

    $('.notifiglobe').click(function(){
      count_notify();
      $('.notificationContainer').fadeToggle(300);
      return false;
    });

    $(document).click(function(){
      count_notify();
      $('.notificationContainer').hide();
    });

    $('.hide-notification').click(function(){
      count_notify();
      $('.notificationContainer').hide();
    });

    $('.notificationContainer').click(function(){
      count_notify();
      return false
    });

    $('#notificationsBody').on('click', '.notifyBody', function(){
      $.post('/activities', {id: $(this).attr('data-id')}, function(data){});
      window.open($(this).attr('data-link'), '_self');
    });

    $('.notifyReport').click(function(){
      var id = $(this).attr('data-id');
      $.ajax({
        url: '/warning_reports/' + id,
        type: 'PATCH',
        success: function(result) {
          location.reload();
        },
      });
    });

    $('.notificationsBody').slimScroll({
      wheelStep: 20
    });
    $(document).ready(function(){
      CKEDITOR.config.height = 150;
    });
  });
};
var format = function(num){
  var str = num.toString().replace('$', ''), parts = false, output = [], i = 1, formatted = null;
  if(str.indexOf('.') > 0) {
    parts = str.split('.');
    str = parts[0];
  }
  str = str.split('').reverse();
  for(var j = 0, len = str.length; j < len; j++) {
    if(str[j] != ',') {
      output.push(str[j]);
      if(i%3 == 0 && j < (len - 1)) {
          output.push(',');
      }
      i++;
    }
  }
  formatted = output.reverse().join('');
  money = formatted + ((parts) ? '.' + parts[1].substr(0, 2) : '');
  if (money.charAt(0) === '-' && money.charAt(1) === ',')
  {
    money = money.replace('-,', '-');
  }
  return(money);
};
function setSelectionRange(input, selectionStart, selectionEnd) {
  if (input.setSelectionRange) {
    input.focus();
    input.setSelectionRange(selectionStart, selectionEnd);
  } else if (input.createTextRange) {
    var range = input.createTextRange();
    range.collapse(true);
    range.moveEnd('character', selectionEnd);
    range.moveStart('character', selectionStart);
    range.select();
  }
}

function setCaretToPos(input, pos) {
  setSelectionRange(input, pos, pos);
}

function convert_to_money(e, input) {
  if ((e.keyCode <= 90 && e.keyCode >= 46) ||
    (e.keyCode <= 123 && e.keyCode >= 96) || (e.keyCode === 8)){
    $(input).val($(input).val().replace(/^0+/, ''));
    var current_cusor = $(input).caret().begin;
    var before_val = $(input).val();
    $(input).val($(input).val().replace(/[^0-9\,]/g,''));
    var money = $(input).val();
    if (money.length > 3) {
      $(input).val(format(money.slice(0, -4)));
    }
    else {
      $(input).val(format($(input).val()));
    }
    if ($(input).val().length > 0) {
      $(input).val($(input).val() + ',000');
    }
    if (before_val.length > 3 && before_val.length < $(input).val().length){
      setCaretToPos($(input)[0], current_cusor + 1);
    }
    else{
      setCaretToPos($(input)[0], current_cusor);
    }
  }
}
