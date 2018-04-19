$(document).ready(function() {
  $('#btn-update-settings').on('click', function(){
    var organization_slug = $('#organization_slug').val();
    var date_remind_month = $('#date_remind_month_select').val();
    var date_remind_quarter = $('#date_remind_quarter_select').val();
    var date_deadline_report = $('#date_deadline_report_select').val();
    var date_report = $('#date_report_select').val();
    var data = {settings: {date_remind_month: date_remind_month, date_remind_quarter: date_remind_quarter, date_deadline_report: date_deadline_report, date_report: date_report},
      organization_slug: organization_slug};
    $.ajax(
    {
      url: '/organization_settings/1',
      type: 'PATCH',
      data: data,
    });
  });
});
