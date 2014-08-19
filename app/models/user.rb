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

  # Relations
  has_many :devices, dependent: :destroy

  # Validations
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name,
    presence: true

  validates :email,
    presence:   true,
    format:     { with: VALID_EMAIL_REGEX },
  	uniqueness: { case_sensitive: false }

  has_secure_password
  validates :password,
    length: { minimum: 6 }

  validates :registry_number,
    presence: true

  # Callbacks
	before_save do
    self.email = email.downcase
  end

end
