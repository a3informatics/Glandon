require 'rails_helper'

describe "Syntax" do

  it "splits string AND" do
    x = Thesaurus::Syntax.new("Harry AND Potter")
    expect(x.array_to_sparql("?x")).to eq(" FILTER (CONTAINS(UCASE(?x), UCASE('Harry')) && CONTAINS(UCASE(?x), UCASE('Potter'))) . \n ")
  end

  it "splits string AND MINUS" do
      x = Thesaurus::Syntax.new("Harry AND Potter -Ron")
      expect(x.array_to_sparql("?x")).to eq(" FILTER (CONTAINS(UCASE(?x), UCASE('Harry')) && CONTAINS(UCASE(?x), UCASE('Potter')) && !CONTAINS(UCASE(?x), UCASE('Ron'))) . \n ")
  end

  it "splits string OR" do
      x = Thesaurus::Syntax.new("Harry OR Potter")
      expect(x.array_to_sparql("?x")).to eq(" FILTER (CONTAINS(UCASE(?x), UCASE('Harry')) || CONTAINS(UCASE(?x), UCASE('Potter'))) . \n ")
  end

  it "splits string OR MINUS" do
      x = Thesaurus::Syntax.new("Harry OR Potter -Ron")
      expect(x.array_to_sparql("?x")).to eq("FILTER (CONTAINS(UCASE(?x), UCASE('Harry')) || CONTAINS(UCASE(?x), UCASE('Potter')) ) .  \n FILTER (!CONTAINS(UCASE(?x), UCASE('Ron')) ) .  \n")
  end

  it "splits string MINUS" do
      x = Thesaurus::Syntax.new("Harry -Potter")
      expect(x.array_to_sparql("?x")).to eq(" FILTER (CONTAINS(UCASE(?x), UCASE('Harry')) && !CONTAINS(UCASE(?x), UCASE('Potter'))) . \n ")
  end

  # it "splits string MINUS invalid" do
  #     x = Thesaurus::Syntax.new("Harry - Potter")
  #     expect{x.array_to_sparql("?x")}.to raise_error(Errors::ApplicationLogicError, "No matches") #EXACT/DEFAULT?
  # end

  it "splits string EXACT MATCH" do
      x = Thesaurus::Syntax.new("\"Harry Potter and The Chamber of Secrets\"")
      expect(x.array_to_sparql("?x")).to eq(" FILTER (CONTAINS(UCASE(?x), UCASE('Harry Potter and The Chamber of Secrets'))) . \n ")
  end

  it "splits string EXACT MATCH" do
      x = Thesaurus::Syntax.new("\"Harry\"")
      expect(x.array_to_sparql("?x")).to eq(" FILTER (CONTAINS(UCASE(?x), UCASE('Harry'))) . \n ")
  end

  it "splits string default" do
      x = Thesaurus::Syntax.new("Harry Potter and the Chamber of Secrets")
      expect(x.array_to_sparql("?x")).to eq(" FILTER (CONTAINS(UCASE(?x), UCASE('Harry Potter and the Chamber of Secrets'))) . \n ")
  end

  it "splits string default" do
      x = Thesaurus::Syntax.new("Harry")
      expect(x.array_to_sparql("?x")).to eq(" FILTER (CONTAINS(UCASE(?x), UCASE('Harry'))) . \n ")
  end

end