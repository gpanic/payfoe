require 'spec_helper'

describe Transaction do

  let(:instance_variables) { [:@id, :@user_from, :@user_to, :@type, :@amount, :@user_mapper] }

  it 'has instance variables id, user_form, user_to, type, amount'  do
    transaction = Transaction.new nil, nil, nil, "deposit", 200
    transaction.instance_variables.should eq instance_variables
  end

  let(:transaction) { Transaction.new nil, LazyObject.new(1), LazyObject.new(2), "deposit", 200 }
  let(:user_mapper) { double("user_mapper") }

  before :each do
    transaction.instance_variable_set :@user_mapper, user_mapper
  end

  describe '#user_from' do

    it 'loads user_from from the db' do
      user_mapper.should_receive(:find).with(1)
      transaction.user_from
    end

    it 'returns the correct user' do
      user = User.new 1, nil, nil, nil
      user_mapper.stub(:find).with(1).and_return(user)
      transaction.user_from.should eq user
    end

  end

  describe '#user_to' do

    it 'loads user_to from the db' do
      user_mapper.should_receive(:find).with(2)
      transaction.user_to
    end

    it 'returns the correct user' do
      user = User.new 1, nil, nil, nil
      user_mapper.stub(:find).with(2).and_return(user)
      transaction.user_to.should eq user
    end

  end

end
