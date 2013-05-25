require 'spec_helper'

describe Transaction do

  let(:instance_variables) { [:@id, :@user_from, :@user_to, :@type, :@amount] }

    it 'has instance variables id, user_form, user_to, type, amount'  do
      transaction = Transaction.new nil, nil, nil, "deposit", 200
      transaction.instance_variables.should eq instance_variables
    end

end
