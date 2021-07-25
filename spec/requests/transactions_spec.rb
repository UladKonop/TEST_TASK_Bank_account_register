# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/transactions', type: :request do
  let(:user) { create(:user) }
  let(:currency) { 'usd' }
  let(:amount) { 42 }
  let(:account) { Account.create(amount: amount, currency: currency, user: user) }

  describe 'POST /deposit' do
    context 'success' do
      context 'when account exists' do
        it 'deposit amount on account' do
          expect do
            post deposit_transaction_url(user.identification_number),
                 params: { account: { currency: currency, amount: amount } }, as: :json
            account.reload
          end.to change(account, :amount).by(amount)
        end

        it 'renders a JSON response with account' do
          post deposit_transaction_url(user.identification_number),
               params: { account: { currency: currency, amount: amount } }, as: :json
          expect(response).to have_http_status(:created)
          expect(response.content_type).to match(a_string_including('application/json'))
        end
      end

      context 'when account does not exist' do
        it 'creates account' do
          expect do
            post deposit_transaction_url(user.identification_number),
                 params: { account: { currency: currency, amount: amount } }, as: :json
            user.accounts.reload
          end.to change(user.accounts, :count).by(1)
        end

        it 'deposit amount on account' do
          post deposit_transaction_url(user.identification_number),
               params: { account: { currency: currency, amount: amount } }, as: :json
          expect(user.accounts.last.amount).to eq(amount)
        end

        it 'render JSON response with account' do
          post deposit_transaction_url(user.identification_number),
               params: { account: { currency: currency, amount: amount } }, as: :json
          expect(response).to have_http_status(:created)
          expect(response.content_type).to match(a_string_including('application/json'))
        end
      end
    end
  end

  context 'failure' do
    it 'renders error when identification_number is not correct' do
      post deposit_transaction_url('incorrect_identification_number'),
           params: { account: { currency: currency, amount: amount } }, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to eq('{"user":["must exist"]}')
    end
  end

  describe 'POST /transfer' do
    let(:sender_id) { 'sender_id' }
    let(:recepient_id) { 'recepient_id' }
    let(:sender) { create(:user, identification_number: sender_id) }
    let(:recepient) { create(:user, identification_number: recepient_id) }
    let(:sender_account) { Account.create(user: sender, currency: currency, amount: amount) }
    let(:invalid_sender_account) { Account.create(user: sender, currency: currency, amount: 0) }
    let(:recepient_account) { Account.create(user: recepient, currency: currency) }
    let(:valid_params) do
      {
        account: { currency: currency, amount: amount },
        recepient_identification_number: recepient_id,
        sender_identification_number: sender_id
      }
    end

    let(:invalid_params_no_sender) do
      {
        account: { currency: currency, amount: amount },
        recepient_identification_number: recepient_id
      }
    end

    context 'success' do
      context 'when sender and recepient account exists' do
        before do
          sender_account
          recepient_account
        end

        it 'withdraws amount from sender account' do
          expect do
            post transfer_transactions_url, params: valid_params, as: :json
            sender_account.reload
          end.to change(sender_account, :amount).from(amount).to(0)
        end

        it 'deposits amount to recepient account' do
          expect do
            post transfer_transactions_url, params: valid_params, as: :json
            recepient_account.reload
          end.to change(recepient_account, :amount).from(0).to(amount)
        end
      end

      context 'when recepient account does not exist' do
        before do
          sender_account
          recepient
        end

        it 'creates recepient account' do
          expect do
            post transfer_transactions_url, params: valid_params, as: :json
            recepient.accounts.reload
          end.to change(recepient.accounts, :count).by(1)
        end

        it 'deposit amount on recepient account' do
          post transfer_transactions_url,
               params: valid_params, as: :json
          expect(recepient.accounts.last.amount).to eq(amount)
        end

        it 'render JSON response with account' do
          post transfer_transactions_url, params: valid_params, as: :json
          expect(response).to have_http_status(:created)
          expect(response.content_type).to match(a_string_including('application/json'))
        end
      end
    end

    context 'failure' do
      context 'when sender account does not exist' do
        it 'do not transfer amount to recepient account' do
          post transfer_transactions_url, params: invalid_params_no_sender, as: :json
          expect(response.body).to eq('{"sender":["must exist"]}')
        end
      end

      context 'when not enough amount on sender account' do
        before do
          invalid_sender_account
          recepient_account
        end

        it 'do not transfer amount to recepient account' do
          post transfer_transactions_url, params: valid_params, as: :json
          expect(response.body).to eq('{"error":"Validation failed: Amount must be greater than or equal to 0"}')
        end
      end
    end
  end
end
