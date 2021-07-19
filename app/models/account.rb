# frozen_string_literal: true

class Account < ApplicationRecord
  belongs_to :user
  
  before_validation :set_amount

  validates :currency, presence: true, uniqueness: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }

  private

  def set_amount
    self.amount ||= 0
  end

end
