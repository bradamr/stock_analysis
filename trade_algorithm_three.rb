require_relative 'modules/tradeable'
require_relative 'ticker_history_three'
require_relative 'trade_conductor_three'
require_relative 'account'

class TradeAlgorithmThree
  attr_reader :account, :ticker_history, :trade_conductor

  def initialize(positive, negative)
    @account         = Account.new
    @ticker_history  = TickerHistoryThree.new(positive, negative)
    @trade_conductor = TradeConductorThree.new(@account)
    @initial_balance = account.balance

    puts "Account starting cash / shares owned / balance: #{account.cash} / #{account.shares_owned} / #{account.balance}"
  end

  def analyze(ticker_data)
    ticker_history.add(ticker_data)
    decide
  end

  def full_info(history, account, symbol)
    latest_quote_price = history.latest_ticker_price
    puts "Price[#{latest_quote_price}] / Can?[#{account.can_purchase?(latest_quote_price)}] / Tr[#{history.recent_trend}] / TrUn[#{history.trend_unknown?}] / TrInc[#{history.recent_positive_trend?}] / TrDec[#{history.recent_negative_trend?}] / Own?[#{account.shares_owned}]"
  end

  def decide
    latest_ticker_price = ticker_history.latest_ticker_price
    latest_ticker_id = ticker_history.latest_ticker_id

    #full_info(ticker_history, account, 'ENPH')

    if !account.can_purchase?(latest_ticker_price) && ticker_history.recent_positive_trend?
      # Do nothing
    elsif account.can_purchase?(latest_ticker_price) &&
      ticker_history.trend_unknown?

      trade_conductor.purchase_max(latest_ticker_price, latest_ticker_id)
    elsif account.shares_owned? &&
          (ticker_history.latest_ticker_price_decrease? &&
           ticker_history.recent_negative_trend?)
      # Sell current shares
      trade_conductor.sell_max(latest_ticker_price, latest_ticker_id)
    elsif account.can_purchase?(latest_ticker_price) &&
      ticker_history.latest_ticker_price_increase? &&
      ticker_history.recent_positive_trend?

      trade_conductor.purchase_max(latest_ticker_price, latest_ticker_id)
    end
  end

  def finish
    puts "Account ending cash / shares owned@avg price / balance: #{account.cash} / #{account.shares_owned}@#{account.average_share_price} / #{account.balance}\n\n"
    change_in_cash = account.balance / @initial_balance
    puts "Change in cash: #{change_in_cash}"
    change_in_cash
  end
end