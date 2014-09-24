class TransactionRepo
  attr_reader :transactions
  WITHDRAWAL = "W"
  PAYMENT = "P"
  BEGINNING_PERIOD_BALANCE = "B"
  
  def initialize
    @transactions = []
  end

  def record_withdrawal(amount, datetime)
    @transactions  << record_activity(WITHDRAWAL, amount, datetime)
  end

  def record_payment(amount, datetime)
    @transactions  << record_activity(PAYMENT, -amount, datetime)
  end

  def record_beginning_balance(amount, datetime)
    @transactions << record_activity(BEGINNING_PERIOD_BALANCE,amount, datetime)
  end

  def record_activity(activity,amount, datetime)
    record = {}
    record[:action] = activity
    record[:amount] = amount
    record[:date_time] = datetime
    record
  end
  def reset
    @transactions.clear
  end
end