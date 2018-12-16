class Notice < ApplicationRecord
  belongs_to :user
  belongs_to :ride

  scope :for_driving, -> { where(target: 'driving') }
  scope :for_request, -> { where(target: 'request') }
end
