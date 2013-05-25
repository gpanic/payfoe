require 'spec_helper'

describe IdentityMap do

  it 'has an identity map for each entity' do
    IdentityMap.class_variables.should eq [:@@user_map]
  end

end
