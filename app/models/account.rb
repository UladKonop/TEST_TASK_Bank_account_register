# frozen_string_literal: true

class Account < ApplicationRecord
  belongs_to :user
  has_many :transactions

  before_validation :set_amount

  validates :currency, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validate :check_currency_uniqueness, on: :create

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

  def check_currency_uniqueness
    errors.add(:currency, 'currency must be unique') if user.accounts.find_by(currency: currency)
  end
end
