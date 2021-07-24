# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/accounts/', type: :request do
  let(:valid_attributes) do
    {
      currency: 'byn',
      amount: 0.0
    }
  end

  let(:user_attributes) do
    {
      first_name: 'first_name',
      last_name: 'last_name',
      patronimic: 'patronimic',
      identification_number: 1
    }
  end

  let(:user) do
    User.create! user_attributes
  end

  let(:invalid_attributes) do
    {
      name: 'first_name',
      name2: 'last_name',
      identification_number: 'foobar'
    }
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      account = user.accounts.create valid_attributes
      get account_url(account), as: :json
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Account' do
        expect do
          post accounts_url,
               params: { account: valid_attributes, identification_number: user.identification_number }, as: :json
        end.to change(Account, :count).by(1)
      end

      it 'renders a JSON response with the new user' do
        post accounts_url,
             params: { account: valid_attributes, identification_number: user.identification_number }, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Account' do
        expect do
          post accounts_url,
               params: { account: invalid_attributes, identification_number: user.identification_number }, as: :json
        end.to change(Account, :count).by(0)
      end

      it 'renders a JSON response with errors for the new user' do
        post users_url,
             params: { user: invalid_attributes, identification_number: user.identification_number }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested Account' do
      account = user.accounts.create valid_attributes
      expect do
        delete account_url(account), as: :json
      end.to change(Account, :count).by(-1)
    end
  end
end
