$(document).ready(function(){
  $(window).scroll(function(){
    scrollHeight = $(document).height();
    scrollPosition = $(window).height() + $(window).scrollTop();
    next_page = $('#next_page_time_line').val();
    scrollBottom = scrollHeight - scrollPosition;
    if (scrollBottom === 0 && typeof next_page != 'undefined'){
      organization_slug = $('#organization_slug').val();
      club_name = $('#input_search_timeline').val();
      if(club_name === ''){
        data = {id: organization_slug, page: next_page, append: true}
      } else {
        data = {id: organization_slug, page: next_page, q: {name_cont: club_name}, append: true}
      }
      $.ajax({
        url: '/organization_events',
        type: 'GET',
        data: data
      })
    }
  });
});
