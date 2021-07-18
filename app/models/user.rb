# frozen_string_literal: true

class User < ApplicationRecord
  has_many :tags, dependent: :destroy
  has_many :accounts, dependent: :destroy
  
  validates :first_name, :last_name, :patronimic, :identification_number, presence: true
  validates :identification_number, uniqueness: true
end
