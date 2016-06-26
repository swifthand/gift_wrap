ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, :force => true do |t|
    t.string  :email
    t.string  :first_name
    t.string  :last_name
    t.string  :encrypted_password
    t.integer :sign_in_count

    t.timestamps null: false
  end

end
