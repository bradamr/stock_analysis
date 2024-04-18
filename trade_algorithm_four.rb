require_relative 'modules/tradeable'
require_relative 'ticker_history_four'
require_relative 'trade_conductor_four'
require_relative 'account'

class TradeAlgorithmFour
  attr_reader :account, :ticker_history, :trade_conductor

  def initialize(positive, negative)
    @account         = Account.new
    @ticker_history  = TickerHistoryFour.new(positive, negative)
    @trade_conductor = TradeConductorFour.new(@account)
    @initial_balance = account.balance

    puts "Account starting cash / shares owned / balance: #{account.cash} / #{account.shares_owned} / #{account.balance}"
  end

  def analyze(ticker_data)
    ticker_history.add(ticker_data)
    decide
  end

  def decide
    latest_ticker_price = ticker_history.latest_ticker_price
    latest_ticker_id = ticker_history.latest_ticker_id

    if !account.can_purchase?(latest_ticker_price) && ticker_history.recent_positive_trend?
      # Do nothing
    elsif account.can_purchase?(latest_ticker_price) &&
      ticker_history.trend_unknown?
      trade_conductor.purchase_max(latest_ticker_price, latest_ticker_id)
    elsif account.shares_owned? &&
          (ticker_history.latest_ticker_price_decrease? &&
           ticker_history.recent_negative_trend?)
      # Sell current shares
      if account.lost_threshold? && account.lost_from_last_sale?
        #puts "YES"
        #ticker_history.switch_threshold
      end

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