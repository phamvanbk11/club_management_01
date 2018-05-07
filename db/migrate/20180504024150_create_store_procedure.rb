class CreateStoreProcedure < ActiveRecord::Migration[5.0]
  def up
     execute <<-SQL
        CREATE PROCEDURE user_events(
          event_ids nvarchar(500),
          user_ids nvarchar(500),
          frequence nvarchar(10))
        BEGIN
          SELECT * FROM user_events as a where FIND_IN_SET(
            event_id, event_ids) and FIND_IN_SET(user_id, user_ids)
            AND (SELECT count(*) FROM user_events as b where
            FIND_IN_SET(b.event_id, event_ids)
            and a.user_id = b.user_id group by user_id) >= frequence;
        END
      SQL
  end
end
