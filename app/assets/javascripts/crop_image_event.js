$(document).ready(function(){
  $(document).on('change', 'input#js-input-image-event', function(event){
    if ($(this).val() != ''){
      $('#js-image-tag-event').cropper('destroy');
      var input = this;
      var target = $(event.currentTarget);
      var file = target[0].files[0];
      var reader = new FileReader();
      var acceptFileTypes = /^image\/(jpg|png|jpeg|gif)$/i;
      if(file['type'].length && !acceptFileTypes.test(file['type'])) {
        alert(I18n.t('js.file_type'));
        input.value = '';
        return false;
      } else {
        reader.onload = function(e){
          var img = new Image();
          img.src = e.target.result;
          $('#js-image-tag-event').attr('src', img.src);
          $('.cropper-canvas img, .cropper-view-box img').attr('src', img.src);
          cropImage();
        };
        reader.readAsDataURL(file);
      }
    }
  });

  $('#js-collapse-image').on('show.bs.collapse', function(){
    $('#js-icon-open-image').removeClass();
    $('#js-icon-open-image').addClass('fa fa-caret-square-o-up');
  })

  $('#js-collapse-image').on('hide.bs.collapse', function(){
    $('#js-icon-open-image').removeClass();
    $('#js-icon-open-image').addClass('fa fa-caret-square-o-down');
  })
})

function cropImage(){
  var $crop_x = $('input#event_image_crop_x'),
    $crop_y = $('input#event_image_crop_y'),
    $crop_w = $('input#event_image_crop_w'),
    $crop_h = $('input#event_image_crop_h');
  $('#js-image-tag-event').cropper({
    viewMode: 1,
    aspectRatio: 1,
    background: false,
    zoomable: false,
    getData: true,
    aspectRatio: 2.0,
    built: function () {
      var croppedCanvas = $(this).cropper('getCroppedCanvas', {
        width: 100,
        height: 100
      });
      croppedCanvas.toDataURL();
    },
    crop: function(data) {
      $crop_x.val(Math.round(data.x));
      $crop_y.val(Math.round(data.y));
      $crop_h.val(Math.round(data.height));
      $crop_w.val(Math.round(data.width));
    }
  });
}
