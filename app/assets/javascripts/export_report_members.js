$(document).ready(function(){
  $(document).on('click', '.btn-export-report', function(e){
    e.preventDefault();
    var organization_id = $('#organization_id').val();
    var style = $('#style_reports').val();
    if (style === "1"){
      var time = $('#month_reports').val();
    }
    else {
      var time = $('#quarter_report').val();
    }
    var year = $('#year_report').val();
    url = '/export_report_members.xlsx?organization_id=' + organization_id;
    url += '&time=' + time;
    url += '&year=' + year;
    url += '&style=' + style;
    window.location.replace(url);
  });
});
