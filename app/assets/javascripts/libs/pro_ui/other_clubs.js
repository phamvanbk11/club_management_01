jQuery(document).ready(function($) {
  $('.form-search-other-clubs').on('keyup',function(e) {
    SearchOtherClub();
  });

  $('.stype-other-clubs').on('change',function(e) {
    SearchOtherClub();
  });

  $('.range-slider-demo').on('change',function(e) {
    SearchOtherClub();
  });

  $('.stype-organizations-other-clubs').on('change',function(e) {
    SearchOtherClub();
  });

  $('.sort-other-clubs').on('change',function(e) {
    SearchOtherClub();
  });

  $('.active_clubs').on('change',function(e) {
    SearchOtherClub();
  });
});

function SearchOtherClub() {
  var sort_club = $('.sort-other-clubs').val();
  var sort_params = LoadSortParam(sort_club);
  var search = $('.form-search-other-clubs').val();
  var stype_clubs = $('.stype-other-clubs').val();
  var active_clubs = $('.active_clubs').val();
  var rate_value = $( ".range-slider-demo" ).val();
  var rate = rate_value.split(",");
  var rate_gteq = rate[0];
  var rate_lteq = rate[1];
  var stype_organizations = $('.stype-organizations-other-clubs').val();
  var data = {q: {s: [sort_params, sort_club], name_or_content_cont: search,
    club_type_id_eq: stype_clubs,organization_id_eq: stype_organizations,
    rating_gteq: rate_gteq, rating_lteq: rate_lteq, is_active_eq: active_clubs}}
  $.get('/clubs', data , null, 'script');
  return false;
}

function LoadSortParam(sort_club) {
  var sort_params = '';
  if(sort_club == 'name asc'){
    sort_params = 'name asc';
  } else if (sort_club == 'rating desc'){
    sort_params = "rating desc";
  } else if (sort_club == 'created_at desc'){
    sort_params = 'created_at asc';
  }
  return sort_params;
}
