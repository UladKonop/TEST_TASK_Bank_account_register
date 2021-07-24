# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account, type: :model do
  let(:user_attributes) do
    {
      first_name: 'first_name',
      last_name: 'last_name',
      patronimic: 'patronimic',
      identification_number: 1
    }
  end

  let(:account_attributes) do
    {
      currency: 'usd',
      amount: '0.0'
    }
  end

  let(:user) do
    User.create! user_attributes
  end

  let(:account) do
    user.accounts.create account_attributes
  end

  describe 'Validations' do
    it 'is valid with valid attributes' do
      expect(account).to be_valid
    end

    it 'is not valid without a currency' do
      account.currency = nil
      expect(account).not_to be_valid
    end

    it 'is not valid without a amount' do
      account.amount = -1
      expect(account).not_to be_valid
    end
  end
end
