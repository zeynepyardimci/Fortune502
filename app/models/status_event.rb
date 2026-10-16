class StatusEvent < ApplicationRecord
  belongs_to :warehouse
  belongs_to :triggered_by, class_name: "User", optional: true

  validates :from_status, presence: true
  validates :to_status, presence: true
  validates :reason, presence: true
end
