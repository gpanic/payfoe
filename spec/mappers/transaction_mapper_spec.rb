require 'spec_helper'

describe TransactionMapper do

  it_behaves_like DataMapper
  include_context "DataMapperContext"

  def delete_all_stm
    "DELETE FROM transactions"
  end

  let(:mapper) { TransactionMapper.new @db_path }
  let(:test_entity) { Transaction.new(nil, nil, nil, "type", 100) }
  let(:test_entity2) { Transaction.new(nil, nil, nil, "type2", 100) }
  let(:updated_entity) { Transaction.new @inserted_id, nil, nil, "type3", 200 }

  def entity_to_a(entity)
    array = []
    vars = entity.instance_variables
    vars.each do |var|
      method = var.to_s[1..-1]
      array.push(entity.send(method.to_sym))
    end
    return array
  end

end
