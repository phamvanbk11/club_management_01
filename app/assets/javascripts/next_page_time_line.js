$(document).ready(function(){
  $(window).scroll(function(){
    scrollHeight = $(document).height();
    scrollPosition = $(window).height() + $(window).scrollTop();
    url = $('#load-event-organization');
    if ((scrollHeight - scrollPosition) / scrollHeight == 0 && url.length > 0){
      $(url).click();
    }
  });
});
