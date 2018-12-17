class User < ApplicationRecord
  has_one_attached :profile_image
  has_one_attached :vehicle_image
  attr_accessor :remember_token
  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :phone_number, presence: true
  validates :emergency_contact, presence: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  has_many :rides, class_name: "Ride", foreign_key: :rider_id
  has_many :drives, class_name: "Ride", foreign_key: :driver_id
  has_many :notices

  def trip_history page=0
    if page==0
      return Ride.where(rider_id: self.id).or(Ride.where(driver_id: self.id))
                 .where(finished: true).or(Ride.where(canceled_by: [0, 1]))
    else
      return Ride.where(rider_id: self.id).or(Ride.where(driver_id: self.id))
                 .where(finished: true).or(Ride.where(canceled_by: [0, 1]))
                 .limit(8).offset((page-1)*8)
    end
  end

  def requests
    self.rides.where(finished: false, canceled_by: nil)
  end

  def drivings
    self.drives.where(finished: false, canceled_by: nil)
  end

  # Returns the hash digest of the given string. by csy
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest.
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

end
