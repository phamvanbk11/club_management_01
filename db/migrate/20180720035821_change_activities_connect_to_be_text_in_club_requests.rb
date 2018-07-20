class ChangeActivitiesConnectToBeTextInClubRequests < ActiveRecord::Migration[5.0]
  def change
    change_column :club_requests, :activities_connect, :text
  end
end
