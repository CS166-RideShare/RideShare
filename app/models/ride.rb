class Ride < ApplicationRecord

  belongs_to :rider, class_name: "User", foreign_key: :rider_id
  belongs_to :driver, class_name: "User", foreign_key: :driver_id, optional: true
  has_one :review

  validates_presence_of :starting_id, :starting_address,
                        :starting_lat, :starting_lng,
                        :destination_id, :destination_address,
                        :destination_lat, :destination_lng

  validates_presence_of :pickup_start, :pickup_end

  validate :time_cannot_be_in_the_past, :start_cannot_be_later_than_end

  attr_accessor :scheduled_time, :duration

  def status
    if driver_id.nil?
      return :available
    else
      if !canceled_by.nil?
        return :canceled
      elsif finished
        return :finished
      end
      return :accepted
    end
  end

  def short_starting
    unless starting_address.nil?
      return starting_address.split(/,\s*/)[0]
    end
  end

  def short_destination
    unless destination_address.nil?
      return destination_address.split(/,\s*/)[0]
    end
  end

  def validate_drive
    validate
    errors.delete(:rider)
    errors.delete(:pickup_start)
    errors.delete(:pickup_end)
    errors.add(:scheduled_time, :blank, message: "cannot be blank") if scheduled_time.nil?
    errors.empty?
  end

  def validate_ride
    validate
    errors.empty?
  end

  def time_cannot_be_in_the_past
    if scheduled_time.present? && scheduled_time < DateTime.now
      errors.add(:scheduled_time, "can't be in the past")
    end
    if pickup_end.present? && pickup_end < DateTime.now
      errors.add(:pickup_end, "can't be in the past")
    end
  end

  def start_cannot_be_later_than_end
    if pickup_start.present? && pickup_end.present? && pickup_end<=pickup_start
      errors.add(:pickup_start, "can't be later than pickup end")
    end
  end

  scope :available, -> { where(driver_id: nil) }
  scope :unfinished, -> { where.not(driver_id: nil)
                          .where(finished: false, canceled_by: nil) }
end
