require_relative 'account'
require_relative 'ticker_history'
require_relative 'trade_conductor'

class TradeAlgorithmOne
  attr_reader :account, :trade_conductor, :ticker_history

  def initialize
    @account         = Account.new
    @ticker_history  = TickerHistory.new
    @trade_conductor = TradeConductor.new(@account)

    puts "Starting balance: #{account.balance}"
  end

  def analyze(data)
    setup(data)
    decide
  end

  def decide
    puts "Balance: #{account.balance}, cash: #{account.cash}, owned: #{account.shares_owned}, ticker price: #{ticker_history.latest_price}"
    puts "Historic trend: #{ticker_history.historic_trend}"

    # Decision will be made on these factors:
    # >>> Trend -- positive, negative, neutral
    # 1.) If stocks are owned and trending negative -- sell
    # 2.) If no stocks are owned and cash available, buy
    #     (future will look for current trends)
    case ticker_history.trending?
    when TickerHistory::POSITIVE_TREND > 1
      trade_conductor.purchase(ticker_history.latest_price)
    when TickerHistory::NEGATIVE_TREND < 1
      trade_conductor.sell(ticker_history.latest_price)
    else
      trade_conductor.purchase(ticker_history.latest_price) if !account.shares_owned? || ticker_history.clear?
    end
  end

  def setup(data)
    # First add new ticker to history
    ticker_history.add(data)
  end

  #@TODO: Remove me eventually
  def finish
    puts "Ticker history count: #{ticker_history.tickers.count}"
    puts "Ending balance: #{account.balance}"
  end
end