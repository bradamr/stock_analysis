require_relative 'modules/tradeable'
require_relative 'ticker_history_two'
require_relative 'trade_conductor'
require_relative 'account'

class TradeAlgorithmTwo
  attr_reader :account, :ticker_history, :trade_conductor

  def initialize
    @account = Account.new
    @ticker_history = TickerHistoryTwo.new
    @trade_conductor = TradeConductor.new(@account)
  end

  def analyze(ticker_data)
    ticker_history.add(ticker_data)
    puts "Price: #{ticker_data['price']} and Trend type? #{ticker_history.trend_type} and latest change: #{ticker_history.trending_average_change}"
    ticker_history.last_ticker_and_trend
  end
end