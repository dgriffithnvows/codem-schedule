class DontAllowNullUploadFields < ActiveRecord::Migration
  def up
    change_column :uploads, :name, :string, :null => false
    change_column :uploads, :video, :string, :null => false
  end

  def down
    change_column :uploads, :name, :string, :null => true
    change_column :uploads, :video, :string, :null => true
  end
end
