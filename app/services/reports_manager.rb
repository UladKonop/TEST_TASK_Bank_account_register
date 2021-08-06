# frozen_string_literal: true

class ReportsManager
  DEPOSIT_REPORT_COLUMNS = %i[currency amount user].freeze
  DEPOSIT_REPORT_COLUMNS_SQL = ['accounts.currency', 'amount', 'users.last_name'].freeze
  MEASURES_REPORT_COLUMNS = %i[avg max min tag].freeze
  MEASURES_REPORT_COLUMNS_SQL = [
    Arel.sql('avg(transactions.amount)'),
    Arel.sql('max(transactions.amount)'),
    Arel.sql('min(transactions.amount)'),
    'tags.name'
  ].freeze
  TOTAL_AMOUNT_REPORT_COLUMNS = %i[currency amount].freeze

  attr_reader :params

  def initialize(params)
    @params = params
  end

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

  def deposits_report
    scoped_transactions
      .where(deposit: true)
      .pluck(DEPOSIT_REPORT_COLUMNS_SQL)
      .map { |row| DEPOSIT_REPORT_COLUMNS.zip(row).to_h }
      .group_by { |row| row.delete(:currency) }
  end

  def measures_report
    scoped_transactions
      .group('tags.name')
      .pluck(*MEASURES_REPORT_COLUMNS_SQL)
      .map { |row| MEASURES_REPORT_COLUMNS.zip(row).to_h }
      .group_by { |row| row.delete(:tag) }
  end

  def total_amount_report
    scoped_transactions
      .group('currency')
      .pluck('currency', Arel.sql('sum(accounts.amount)'))
      .map { |row| TOTAL_AMOUNT_REPORT_COLUMNS.zip(row).to_h }
      .group_by { |row| row.delete(:currency) }
  end

  def scoped_transactions
    @scoped_transactions ||=
    Transaction
    .joins(:account)
    .joins(account: :user)
    .joins(account: [user: :tags])
    .then { |transactions| params[:user_ids].present? ? transactions.where('accounts.user_id' => params[:user_ids]) : transactions }
    .then { |transactions| params[:date_from].present? ? transactions.where('transactions.created_at > ?', params[:date_from].to_date) : transactions }
    .then { |transactions| params[:date_to].present? ? transactions.where('transactions.created_at < ?', params[:date_to].to_date) : transactions}
    .then { |transactions| params[:tags].present? ? transactions.where('tags.name' => params[:tags]) : transactions }
  end
end
