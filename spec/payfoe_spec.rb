require 'spec_helper'

describe PayFoe do

  describe "::pay" do

    it "returns the truth" do
      PayFoe.pay.should eq("Bad decision...")
    end

  end

end
