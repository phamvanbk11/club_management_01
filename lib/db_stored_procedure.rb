class DbStoredProcedure < ActiveRecord::Base
  def self.fetch_db_records proc_name_with_parameters
    connection.select_all proc_name_with_parameters
  end
end
