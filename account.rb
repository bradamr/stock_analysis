require_relative 'modules/calculations'

class Account
  include Calculations::Stocks

  attr_accessor :cash, :tax_lots

  def initialize
    @initial_value = 50000
    @cash     = 50000
    @tax_lots = [] # Tax Lots of Owned Shares
    @last_cash_value = 0
  end

  def lost_threshold?
    shares_owned? && ((cash / @initial_value) < 0.99)
  end

  def lost_from_last_sale?
    return false if @last_cash_value == 0

    @last_cash_value > @cash
  end

  def purchasable_shares_at_price?(price)
    stocks_purchasable?(cash, price)
  end

  def can_purchase?(price)
    cash > price
  end

  def can_sell?
    shares_owned?
  end

  def should_purchase?(price)
    can_purchase?(price)
  end

  def should_sell?(price)
    can_sell?
  end

  def shares_owned?
    tax_lots.count > 0
  end

  def credit(value)
    @last_cash_value = @cash
    @cash += value
  end

  def debit(value)
    @cash -= value
  end

  def balance
    cash + stocks_value(shares_owned, average_share_price)
  end

  def add_shares_count(shares_count, price)
    shares_count.times { tax_lots << price }
  end

  def remove_shares_count(shares_count)
    removed_shares = @tax_lots.last(shares_count)
    @tax_lots     -= removed_shares
  end

  def shares_owned
    tax_lots.count
  end

  def average_share_price
    return 0 unless shares_owned?

    average_price(tax_lots)
  end
end