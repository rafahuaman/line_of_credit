class LineOfCredit
  attr_reader :apr, :max_limit, :balance, :clock, :datetime_created, :transaction_repo, :owed_interest
  SUCCESS_MESSAGE = "SUCCESS"
  ERROR_MESSAGE_MAX_CREDIT_REACHED = "ERROR CREDIT LIMIT REACHED"
  ERROR_CANNOT_CHARGE_BEFORE_30_DAY_PERIOD = "ERROR -  Interest can only be charged at the end of the closing 30 day period."

  def initialize(limit, apr, clock)
    @max_limit = limit
    @apr = apr
    @balance = 0
    @clock = clock
    @datetime_created = @clock.get_datetime
    @transaction_repo = TransactionRepo.new
    @owed_interest = 0 
  end

  def draw(amount)
    if has_enough_funds? (amount)
      ERROR_MESSAGE_MAX_CREDIT_REACHED
    else
      @balance += amount
      @transaction_repo.record_withdrawal(amount, @clock.get_datetime)
      SUCCESS_MESSAGE
    end
  end

  def pay(amount)
    @balance -= amount
    @transaction_repo.record_payment(amount, @clock.get_datetime)
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
    calculated_interest = 0
    last_transaction_date = clock.get_datetime.to_date 
    @transaction_repo.transactions.reverse_each do |transaction|
      days_with_balance = last_transaction_date - transaction[:date_time].to_date
      calculated_interest+= balance_tracker*@apr/365*days_with_balance
      balance_tracker -= transaction[:amount]
      last_transaction_date = transaction[:date_time].to_date
    end
    @owed_interest += calculated_interest
    @transaction_repo.reset
    @transaction_repo.record_beginning_balance(balance, @clock.get_datetime)
  end

  def total_payoff
    @balance + @owed_interest 
  end

  private
    def has_enough_funds? (amount)
      amount > remaining_limit
    end
end