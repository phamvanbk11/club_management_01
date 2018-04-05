$(function(){ TablesDatatables.init(); });
$(document).ready(function () {
  $('#export-budgets').click(function(){
    var first_date = $('#date_first').val();
    var second_date = $('#date_end').val();
    var club_id = $('#club_id').val();
    this.href = "/club_manager/export_history_budgets.xlsx?" +
      $.param({first_date: first_date, second_date: second_date, club_id: club_id});
  });
});
