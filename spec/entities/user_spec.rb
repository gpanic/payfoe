require 'spec_helper'

describe User do

  let(:instance_variables) { [:@id, :@username, :@email, :@name, :@balance] }

    it 'has instance variables id, username, email, name'  do
      user = User.new nil, "username", "email", "name", 0
      user.instance_variables.should eq instance_variables
    end

end
