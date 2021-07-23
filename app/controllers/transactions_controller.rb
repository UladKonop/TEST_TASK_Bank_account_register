# frozen_string_literal: true

class TransactionsController < ApplicationController
  def deposit
    user = User.find_by(identification_number: params[:identification_number])
    render_error({ "user": ['must exist'] }) and return if user.nil?

    account = find_or_build_account(user)
    render_error(account.errors) and return if account.invalid?

    account.deposit(account_params[:amount].to_f)
    if account.save
      render json: account, status: :created, location: account
    else
      render json: account.errors, status: :unprocessable_entity
    end
  end

  def transfer
    sender = User.find_by(identification_number: params[:sender_identification_number])
    render_error({ "sender": ['must exist'] }) and return if sender.nil?

    recipient = User.find_by(identification_number: params[:recipient_identification_number])
    render_error({ "recipient": ['must exist'] }) and return if recipient.nil?

    sender_account = sender.accounts.find_by(currency: account_params[:currency])
    render_error({ "sender": ['must exist'] }) and return if sender.nil?

    Account.transaction do
      amount = account_params[:amount].to_f
      recipient_account = find_or_create_account(recipient)

      [sender_account, recipient_account].sort_by(&:id).each(&:lock!)

      sender_account.withdraw!(amount)
      recipient_account.deposit!(amount)

      head :ok
    rescue ActiveRecord::RecordInvalid => e
      render_error(error: e.message)
    end
  end

  private

  def find_or_create_account(user)
    return nil unless user

    account = user.accounts.find_by(currency: account_params[:currency])
    account || Account.create(account_params.merge(user: user))
  end

  def find_or_build_account(user)
    return nil unless user

    account = user.accounts.find_by(currency: account_params[:currency])
    account || Account.new(account_params.merge(user: user))
  end

  def account_params
    params.require(:account).permit(:amount, :currency)
  end

  def render_error(error, status: :unprocessable_entity)
    render(json: error, status: status) and return
  end
end
