require_relative 'modules/calculations'

class TradeConductorTwo
  include Calculations::Stocks

  ACTIONS = {
    'BUY':  :buy,
    'SELL': :sell
  }.freeze

  attr_reader :account

  def initialize(account)
    @account = account
  end

  def purchase(price)
    return unless account.should_purchase?(price)

    puts "Purchase made @ #{price}"

    shares_count = account.can_purchase_at_price?(price)
    account.debit(stocks_value(shares_count, price))
    account.add_shares_count(shares_count, price)
  end

  def sell(price)
    return unless account.should_sell?(price)

    puts "Sell made @ #{price}"

    account.credit(stocks_value(account.shares_owned, price))
    account.remove_shares
  end
end