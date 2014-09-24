require './transaction_repo.rb'

RSpec.describe TransactionRepo do
  #let(:test_time) { DateTime.now }
  #let(:clock) { double('ClockService', get_datetime: test_time ) }
  let(:repo) { TransactionRepo.new() }
  
  describe "#new" do
    it "returs an instance of TransactionRepo" do
      expect(repo).to be_a TransactionRepo
      expect(repo.transactions).to eq []
    end
  end
  
end