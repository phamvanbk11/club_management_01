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

  $(document).on('keyup', '.js-input-money', function(){
    $(this).val(format($(this).val()));
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
