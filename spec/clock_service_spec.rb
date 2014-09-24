require './clock_service.rb'

RSpec.describe ClockService do
  let(:clock) { ClockService.new() }
  describe "#new" do
    it "returs an instance of ClockService" do
      expect(clock).to be_a ClockService
    end
  end
  
  describe "#get_datetime" do
    it "generates current datetime" do 
      pre_test_datetime  = DateTime.now
      test_datetime = clock.get_datetime() 
      post_test_datetime  = DateTime.now
      expect(test_datetime).to be > pre_test_datetime
      expect(test_datetime).to be < post_test_datetime
    end
  end
end