class User < ActiveRecord::Base
    has_many :certificates
    has_many :devices, through: :certificate
end
