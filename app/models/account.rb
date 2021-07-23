# frozen_string_literal: true

class Account < ApplicationRecord
  belongs_to :user

  before_validation :set_amount

  validates :currency, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }

  def deposit(amount)
    self.amount += amount
    true
  end

  def deposit!(amount)
    deposit(amount)
    save!    
  end

  def withdraw(amount)
    self.amount -= amount
    true
  end

  def withdraw!(amount)
    withdraw(amount)
    save!
  end

  private

  def set_amount
    self.amount ||= 0
  end
end
