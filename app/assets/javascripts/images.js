$(function(){ Portfolio.init(); });
  $(document).ready(function() {
    $('.thumb').click(function(){
      $('.modal-body-image').empty();
      var title = $(this).parent('a').attr("title");
      $('.modal-title').html(title);
      $($(this).parents('div').html()).appendTo('.modal-body-image');
      $(".modal-body-image").find('span').remove();
      $('#myModalImage').modal({show:true});
    });
  $('ul.first').bsPhotoGallery({
    "classes" : "col-md-6 col-sm-3 col-xs-4 col-xxs-12",
    "hasModal" : true
  });
  $('.image-club-show').bsPhotoGallery({
    "classes" : "col-md-3 image-club-show col-sm-3 col-xs-3",
    "hasModal" : true
  });
});
$(document).ready(function () {
  baguetteBox.run(".tz-gallery");
  $(document).on('click', '.js-img', function(){
    if ($('.bt-rotate-left').length === 0){
      html = '<button class="btn btn-breez bt-rotate-left">'
      html += '<i class="fa fa-undo"></i></button>'
      $('.full-image').append(html);
    }
    if ($('.bt-rotate-right').length === 0){
      html = '<button class="btn btn-breez bt-rotate-right">'
      html += '<i class="fa fa-repeat"></i></button>'
      $('.full-image').append(html);
    }
  });
  $(document).on('click', '.bt-rotate-left', function(){
    img = $(this).parents('.full-image').find('img');
    rotate = getRotationDegrees(img) - 90;
    $(img).css({transform: 'rotate(' + rotate + 'deg)'})
  });
  $(document).on('click', '.bt-rotate-right', function(){
    img = $(this).parents('.full-image').find('img');
    rotate = getRotationDegrees(img) + 90;
    $(img).css({transform: 'rotate(' + rotate + 'deg)'})
  });
});
function getRotationDegrees(obj) {
  var matrix = obj.css("transform");
  if(matrix !== 'none'){
    var values = matrix.split('(')[1].split(')')[0].split(',');
    var a = values[0];
    var b = values[1];
    var angle = Math.round(Math.atan2(b, a) * (180/Math.PI));
  }
  else{
    var angle = 0;
  }
  return angle;
}
