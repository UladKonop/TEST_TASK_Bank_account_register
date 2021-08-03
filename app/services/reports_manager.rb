# frozen_string_literal: true

class ReportsManager
  attr_reader :params

  def call
    case params[:report_type]
    when 'deposits_report'
      [deposits_report, nil]
    when 'measures_report'
      [measures_report, nil]
    when 'total_amount_report'
      [total_amount_report, nil]
    else
      [nil, { errror: 'unknown report type' }]
    end
  end

  private

  def initialize(params)
    @params = params
  end

  def deposits_report
    scoped_transactions.where(deposit: true).pluck('accounts.currency',
                                                   'amount').group_by(&:first)
  end

  def measures_report; end

  def total_amount_report; end

  def scoped_transactions
    @scoped_transactions ||=
      Transaction
      .joins(:account)
      .then { |transactions| params[:user_ids].present? ? transactions.where('accounts.user_id' => params[:user_ids]) : transactions }
      .then do |transactions|
        if params[:date_from].present?
          transactions.where('transactions.created_at > ?', params[:date_from].to_date)
        else
          transactions
        end
      end
      .then do |transactions|
        if params[:date_to].present?
          transactions.where('transactions.created_at < ?', params[:date_to].to_date)
        else
          transactions
        end
      end
  end
end
