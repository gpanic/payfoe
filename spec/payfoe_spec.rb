require 'spec_helper'

describe PayFoe do

  before :each do
    @pf = PayFoe.new
  end

  describe '#register' do

    let(:test_user) { User.new(nil, "username", "email", "name") }

    def mock_user_mapper
      user_mapper = double("user_mapper")
      @pf.user_mapper = user_mapper 
      user_mapper.should_receive(:insert).with(test_user).and_return(1)
    end

    it 'registers the user' do
      mock_user_mapper
      @pf.register(test_user)
    end

    it 'returns the id of the registered user' do
      mock_user_mapper
      @pf.register(test_user).should eq 1
    end

  end

end
