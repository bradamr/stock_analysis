require_relative 'modules/calculations'
require_relative 'account'

class TradeConductor
  include Calculations::Stocks

  attr_reader :account

  ACTIONS = {
    'BUY':  :buy,
    'SELL': :sell
  }.freeze

  def initialize(account)
    @account = account
  end

  def purchase_max(price)
    shares_purchasable = purchasable_shares_at_price?(price)
    purchase(shares_purchasable, price)
  end

  # Purchase # shares @ $price
  def purchase(shares, price)
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