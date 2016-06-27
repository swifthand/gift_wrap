class User < ActiveRecord::Base

  def initials
    "#{first_name[0]}#{last_name[0]}"
  end

end
