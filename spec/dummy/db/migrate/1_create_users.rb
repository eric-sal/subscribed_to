class CreateUsers< ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.string    :first_name
      t.string    :last_name
      t.string    :email
      t.boolean   :subscribed_to_list
      t.string    :password
    end
  end

  def self.down
    drop_table :users
  end
end
