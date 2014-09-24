class LineOfCredit
  attr_reader :apr, :max_limit, :balance, :clock, :datetime_created, :period_transactions, :owed_interest
  SUCCESS_MESSAGE = "SUCCESS"
  ERROR_MESSAGE_MAX_CREDIT_REACHED = "ERROR CREDIT LIMIT REACHED"
  ERROR_CANNOT_CHARGE_BEFORE_30_DAY_PERIOD = "ERROR -  Interest can only be charged at the end of the closing 30 day period."
  WITHDRAWAL = "W"
  PAYMENT = "P"
  BEGINNING_PERIOD_BALANCE = "B"

  def initialize(limit, apr, clock)
    @max_limit = limit
    @apr = apr
    @balance = 0
    @clock = clock
    @datetime_created = @clock.get_datetime
    @period_transactions = []
    @owed_interest = 0 
  end

  def draw(amount)
    if has_enough_funds? (amount)
      ERROR_MESSAGE_MAX_CREDIT_REACHED
    else
      @balance += amount
      @period_transactions << record_withdrawal(amount)
      SUCCESS_MESSAGE
    end
  end

  def pay(amount)
    @balance -= amount
    @period_transactions << record_payment(amount)
    SUCCESS_MESSAGE
  end

  def remaining_limit
    @max_limit - @balance
  end

  def date_created
    @datetime_created.to_date
  end

  def charge_interest
    if (clock.get_datetime.to_date - date_created)%30 == 0 and clock.get_datetime.to_date - date_created !=0
      calculate_interest
      SUCCESS_MESSAGE
    else
      ERROR_CANNOT_CHARGE_BEFORE_30_DAY_PERIOD
    end
  end

  def calculate_interest
    balance_tracker = balance
    interest = 0
    last_transaction_date = clock.get_datetime.to_date 
    @period_transactions.reverse_each do |transaction|
      days_with_balance = last_transaction_date - transaction[:date_time].to_date
      interest+= balance_tracker*@apr/365*days_with_balance
      balance_tracker -= transaction[:amount]
      last_transaction_date = transaction[:date_time].to_date
    end
    @owed_interest += interest
    @period_transactions.clear
    @period_transactions << record_beginning_balance(balance)
  end

  def total_payoff
    @balance + @owed_interest 
  end

  private
    def has_enough_funds? (amount)
      amount > remaining_limit
    end

    def record_withdrawal(amount)
      record_activity(WITHDRAWAL, amount)
    end

    def record_payment(amount)
      record_activity(PAYMENT, -amount)
    end

    def record_beginning_balance(amount)
      record_activity(BEGINNING_PERIOD_BALANCE,amount)
    end

    def record_activity(activity,amount)
      record = {}
      record[:action] = activity
      record[:amount] = amount
      record[:date_time] = @clock.get_datetime
      record
    end
end