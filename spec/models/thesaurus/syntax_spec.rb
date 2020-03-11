require 'rails_helper'

describe "Syntax" do

  it "splits string AND" do
    x = Thesaurus::Syntax.new("Clarisa AND Romero")
    expect(x.string_to_sparql).to eq(". FILTER (CONTAINS(?x, 'Clarisa') && CONTAINS(?x, 'Romero')) .")
  end

  it "splits string AND MINUS" do
      x = Thesaurus::Syntax.new("Clarisa AND Romero -Analia")
      expect(x.string_to_sparql).to eq(". FILTER (CONTAINS(?x, 'Clarisa') && CONTAINS(?x, 'Romero') && !CONTAINS(?x, 'Analia')) .")
  end

  it "splits string OR" do
      x = Thesaurus::Syntax.new("Clarisa OR Romero")
      expect(x.string_to_sparql).to eq(". FILTER (CONTAINS(?x, 'Clarisa') || CONTAINS(?x, 'Romero')) .")
  end

  it "splits string OR MINUS" do
      x = Thesaurus::Syntax.new("Clarisa OR Romero -Analia")
      expect(x.string_to_sparql).to eq(". FILTER (CONTAINS(?x, 'Clarisa') || CONTAINS(?x, 'Romero') && !CONTAINS(?x, 'Analia')) .")
  end

  it "splits string MINUS" do
      x = Thesaurus::Syntax.new("Clarisa -Romero")
      expect(x.string_to_sparql).to eq(". FILTER (CONTAINS(?x, 'Clarisa') && !CONTAINS(?x, 'Romero')) .")
  end

  it "splits string MINUS invalid" do
      x = Thesaurus::Syntax.new("Clarisa - Romero")
      expect{x.string_to_sparql}.to raise_error(Errors::ApplicationLogicError, "Invalid syntax")
  end

  it "splits string EXACT MATCH" do
      x = Thesaurus::Syntax.new("\"Clarisa Romero\"")
      expect(x.string_to_sparql).to eq(". FILTER (CONTAINS(UCASE(?x), UCASE('Clarisa Romero'))) .")
  end

  it "splits string EXACT MATCH" do
      x = Thesaurus::Syntax.new("\"Clarisa\"")
      expect(x.string_to_sparql).to eq(". FILTER (CONTAINS(UCASE(?x), UCASE('Clarisa'))) .")
  end

end