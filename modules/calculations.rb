module Calculations
  module Percentages
    def percent_change_from(current, previous)
      current.to_f / previous.to_f
    end
  end

  module Stocks
    def stocks_purchasable?(cash, stock_price)
      (cash / stock_price).to_i
    end

    def stocks_value(shares_count, stock_price)
      (shares_count * stock_price).to_f
    end

    def average_price(shares)
      (shares.reduce(:+).to_f / shares.size).to_f
    end
  end
end