module UserRecords

  def self.create!
    users_attributes.each do |attrs|
      User.create(attrs)
    end
  end


  def self.temporal_reference_point
    @temporal_reference_point ||= Time.now
  end


  def self.users_attributes
    [ { id:                 1,
        email:              "paulwall@example.com",
        first_name:         "Paul",
        last_name:          "Wall",
        encrypted_password: "$2a$10$DbRvyFxovWAly4ZCDtcJ6uVhbMGya2iGiLCURhSwM1ZGUyXpM5UiW",
        sign_in_count:      2,
        created_at:         temporal_reference_point,
        updated_at:         temporal_reference_point,
      },
      { id:                 2,
        email:              "gendoarrighetti@example.com",
        first_name:         "Gendo",
        last_name:          "Arrighetti",
        encrypted_password: "$2a$10$DbRvyFxovWAly4ZCDtcJ6uVhbMGya2iGiLCURhSwM1ZGUyXpM5UiW",
        sign_in_count:      0,
        created_at:         temporal_reference_point,
        updated_at:         temporal_reference_point,
      },
    ]
  end

end
