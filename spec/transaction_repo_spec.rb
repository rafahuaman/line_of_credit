require './transaction_repo.rb'

RSpec.describe TransactionRepo do
  let(:repo) { TransactionRepo.new() }
  
  describe "#new" do
    it "returs an instance of TransactionRepo" do
      expect(repo).to be_a TransactionRepo
      expect(repo.transactions).to eq []
    end
  end
  
end