require 'spec_helper'

describe User do

  let(:instance_variables) { [:@id, :@username, :@email, :@name] }

    it 'has instance variables id, username, email, name'  do
      user = User.new nil, "username", "email", "name"
      user.instance_variables.should eq instance_variables
    end

end
