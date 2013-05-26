require 'spec_helper'

describe PayFoe::IdentityMap do

  it 'has an identity map for each entity' do
    PayFoe::IdentityMap.class_variables.should eq [:@@users_map, :@@transactions_map]
  end

end
