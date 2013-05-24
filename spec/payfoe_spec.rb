require 'spec_helper'

describe PayFoe do

  let(:pf) { PayFoe.new }
  let(:user_mapper) { double "user_mapper" }
  let(:test_user) { User.new(nil, "username", "email", "name") }

  before :each do
    pf.instance_variable_set :@user_mapper, user_mapper
  end

  describe '#register' do

    it 'registers the user' do
      user_mapper.should_receive(:insert).with(test_user)
      pf.register(test_user)
    end

    it 'returns the id of the registered user' do
      user_mapper.should_receive(:insert).with(test_user).and_return(1)
      pf.register(test_user).should eq 1
    end

  end

  describe '#users' do

    it 'returns an array of all the registered users' do
      user_mapper.should_receive(:find_all).and_return([test_user, test_user])
      pf.users.should eq [test_user, test_user]
    end

  end

end
