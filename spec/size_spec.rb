require 'spec_helper'

describe RRTF::Page::Size do
  it "parses strings into width and height" do
    expect(RRTF::Page::Size.parse_string("LETTER")).to eql("width" => 12247, "height" => 15819)
    expect(RRTF::Page::Size.parse_string("8.5in, 11in")).to eql("width" => 12240, "height" => 15840)
  end

  it "parses strings into size objects" do
    expect(RRTF::Page::Size.from_string("LETTER")).to eql(RRTF::Page::Size.new("width" => 12247, "height" => 15819))
    expect(RRTF::Page::Size.from_string("100pt,100pt")).to eql(RRTF::Page::Size.new("width" => 2000, "height" => 2000))
  end
end
