require_relative 'modules/calculations'

class TradeConductorFour
  include Calculations::Stocks

  attr_reader :account

  ACTIONS = {
    'BUY':  :buy,
    'SELL': :sell
  }.freeze


  def initialize(account)
    @account = account
  end

  def purchase_max(price, id = nil)
    shares_purchasable = account.purchasable_shares_at_price?(price)
    purchase(shares_purchasable, price, id)
  end

  def sell_max(price, id = nil)
    shares_count = account.shares_owned
    sell(shares_count, price, id)
  end

  def purchase(shares_count, price, id = nil)
    #puts "Purchase made @ #{price} ID: #{id}"

    account.debit(stocks_value(shares_count, price))
    account.add_shares_count(shares_count, price)
  end

  def sell(shares_count, price, id = nil)
    #puts "Sale made @ #{price} ID: #{id}"

    account.credit(stocks_value(shares_count, price))
    account.remove_shares_count(shares_count)
  end
end