# frozen_string_literal: true

class TransactionsController < ApplicationController
  def deposit
    user = User.find_by(identification_number: params[:identification_number])
    return render_error({ "user": ['must exist'] }) if user.nil?

    account = user.accounts.find_by(currency: account_params[:currency])
    if account
      account.deposit(account_params[:amount].to_f)
    else
      account = Account.new(account_params.merge(user: user))
    end

    render_error(account.errors) and return if account.invalid?

    if account.save
      render json: account, status: :created, location: account
    else
      render json: account.errors, status: :unprocessable_entity
    end
  end

  def transfer
    sender = User.find_by(identification_number: params[:sender_identification_number])
    render_error({ "sender": ['must exist'] }) and return if sender.nil?

    recipient = User.find_by(identification_number: params[:recepient_identification_number])
    render_error({ "recipient": ['must exist'] }) and return if recipient.nil?

    sender_account = sender.accounts.find_by(currency: account_params[:currency])
    render_error({ "sender": ['must exist'] }) and return if sender.nil?

    Account.transaction do
      amount = account_params[:amount].to_f

      recepient_account = recipient.accounts.find_by(currency: account_params[:currency])
      recepient_account ||= Account.create(currency: account_params[:currency], user: recipient,
                                           amount: 0)

      [sender_account, recepient_account].sort_by(&:id).each(&:lock!)

      sender_account.withdraw!(amount)
      recepient_account.deposit!(amount)

      render json: { sender_account: sender_account, recepient_account: recepient_account },
             status: :created

    rescue ActiveRecord::RecordInvalid => e
      render_error(error: e.message)
    end
  end

  private

  def account_params
    params.require(:account).permit(:amount, :currency)
  end

  def render_error(error, status: :unprocessable_entity)
    render(json: error, status: status)
  end
end
