class AddJobsIdToLots < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :job_id_in_process, :string, null: true
    add_column :lots, :job_id_closed, :string, null: true
  end
end
