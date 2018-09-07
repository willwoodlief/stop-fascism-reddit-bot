class Setting < ApplicationRecord
  scope :only_row, -> { where(id: 1).first }
end
