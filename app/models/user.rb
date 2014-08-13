# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  email           :string(255)
#  password_digest :string(255)
#  registry_number :string(255)
#

class User < ActiveRecord::Base
	before_save { self.email = email.downcase }
    has_many :devices
    validates :name, presence: true
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true,
                      format:     { with: VALID_EMAIL_REGEX },
    				  uniqueness: {case_sensitive: false}

    has_secure_password
    validates :password, length: { minimum: 6 }
    validates :registry_number, presence: true
end
