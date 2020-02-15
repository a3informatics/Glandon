require 'rails_helper'

describe "Thesaurus::Extensions" do

  include DataHelpers

  describe Thesaurus::Extensions do

    it "can extend unextensible, true" do
      local_configuration = {can_extend_unextensible: true}
      expect(Thesaurus::ManagedConcept).to receive(:extensions_configuration).and_return(local_configuration)
      expect(Thesaurus::ManagedConcept.can_extend_unextensible?).to eq(true)
    end

    it "can extend unextensible, false" do
      local_configuration = {can_extend_unextensible: false}
      expect(Thesaurus::ManagedConcept).to receive(:extensions_configuration).and_return(local_configuration)
      expect(Thesaurus::ManagedConcept.can_extend_unextensible?).to eq(false)
    end

  end

end
