require 'rails_helper'

describe MarkdownEngine do
	
  include DataHelpers

  it "handles empty markdown - \"\"" do
    expect(MarkdownEngine.render("")).to eq("&nbsp;")
  end

  it "handles empty markdown - nil" do
    expect(MarkdownEngine.render(nil)).to eq("&nbsp;")
  end

  it "handles empty markdown" do
    result = "<p>This is markdown </p>\n\n" +
      "<ul>\n" +
      "<li>Item 1\n" +
      "\n" +
      "<ul>\n" +
      "<li>Item 2\n" +
      "And some new text</li>\n" +
      "</ul></li>\n" +
      "</ul>\n"
    expect(MarkdownEngine.render("This is markdown \n\n * Item 1\n* Item 2\nAnd some new text")).to eq(result)
  end

end