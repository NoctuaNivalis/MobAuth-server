class Device < ActiveRecord::Base
  has_many :certificates
  has_many :users, through: :certificate
end
