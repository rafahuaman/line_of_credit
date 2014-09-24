require './line_of_credit.rb'

RSpec.describe LineOfCredit do
  let(:test_time) { DateTime.now }
  let(:clock) { double('ClockService', get_datetime: test_time ) }
  let(:line_of_credit) { LineOfCredit.new(1000,0.35,clock) }
  
  describe "#new" do
    it "returs an instance of LineOfCredit" do
      expect(line_of_credit.max_limit).to eq 1000
      expect(line_of_credit.apr).to eq 0.35
      expect(line_of_credit.balance).to eq 0
      expect(line_of_credit.date_created).to eq test_time.to_date
    end
  end
  
  describe "#draw" do
    it "takes out money" do 
      status = line_of_credit.draw(500) 
      expect(status).to eq "SUCCESS"
      expect(line_of_credit.balance).to eq 500
      expect(line_of_credit.remaining_limit).to eq 500
    end

    it "can't take out more than the remaining credit limit" do
      status = line_of_credit.draw(1500) 
      expect(status).to eq "ERROR CREDIT LIMIT REACHED"
      expect(line_of_credit.balance).to eq 0
      expect(line_of_credit.remaining_limit).to eq 1000
    end

    it "records the transaction" do
      line_of_credit.draw(500) 
      expect(line_of_credit.period_transactions[0][:action]).to eq "W"
      expect(line_of_credit.period_transactions[0][:amount]).to eq 500
      expect(line_of_credit.period_transactions[0][:date_time]).to  eq test_time
    end
  end

  describe "#pay" do
    before do
      line_of_credit.draw(500)
    end
    it "makes a payment" do 
      status = line_of_credit.pay(400) 
      expect(status).to eq "SUCCESS"
      expect(line_of_credit.balance).to eq 100
      expect(line_of_credit.remaining_limit).to eq 900
    end

    it "records the transaction" do
      line_of_credit.pay(500) 
      expect(line_of_credit.period_transactions[1][:action]).to eq "P"
      expect(line_of_credit.period_transactions[1][:amount]).to eq(-500)
      expect(line_of_credit.period_transactions[1][:date_time]).to  eq test_time
    end
  end

  describe "#charge_interest" do
    before do
      line_of_credit.draw(500)
    end

    describe "before 30 day period" do
      it "does not charge interest" do
        status = line_of_credit.charge_interest
        expect(status).to eq "ERROR -  Interest can only be charged at the end of the closing 30 day period."
        expect(line_of_credit.owed_interest).to eq 0
      end
    end

    describe "on 30th day" do
      before do
        allow(clock).to receive(:get_datetime).and_return((Date.today + 30).to_datetime)
      end

      it "charges interest" do
        status = line_of_credit.charge_interest
        expect(status).to eq "SUCCESS"
        expect(line_of_credit.owed_interest.round(2)).to eq 14.38
        expect(line_of_credit.total_payoff.round(2)).to eq 514.38
      end
    end

    describe "with multiple transactions" do
      before do
        allow(clock).to receive(:get_datetime).and_return((Date.today + 15).to_datetime)
        line_of_credit.pay(200)
        allow(clock).to receive(:get_datetime).and_return((Date.today + 25).to_datetime)
        line_of_credit.draw(100)
        allow(clock).to receive(:get_datetime).and_return((Date.today + 30).to_datetime)
      end

      it "charges interest" do
        status = line_of_credit.charge_interest
        expect(status).to eq "SUCCESS"
        expect(line_of_credit.owed_interest.round(2)).to eq 11.99
        expect(line_of_credit.total_payoff.round(2)).to eq 411.99
      end

      describe "over two periods" do
        before do
          line_of_credit.charge_interest
          allow(clock).to receive(:get_datetime).and_return((Date.today + 45).to_datetime)
          line_of_credit.draw(200)
          allow(clock).to receive(:get_datetime).and_return((Date.today + 60).to_datetime)
        end

        it "charges interest" do
          status = line_of_credit.charge_interest
          expect(status).to eq "SUCCESS"
          expect(line_of_credit.owed_interest.round(2)).to eq 26.37
          expect(line_of_credit.total_payoff.round(2)).to eq 626.37
        end
      end
    end
  end
end