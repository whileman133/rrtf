require 'spec_helper'

describe RRTF::Page::Margin do
  it "parses document-margin strings into margin hashes" do
    expect(RRTF::Page::Margin.parse_string("1.5in, 3cm, 30mm, 10pt")).to eql(
      "left" => 2160,
      "top" => 1701,
      "right" => 1701,
      "bottom" => 200
    )
    expect(RRTF::Page::Margin.parse_string("1.5in, 3cm")).to eql(
      "left" => 2160,
      "top" => 1701,
      "right" => 2160,
      "bottom" => 1701
    )
    expect(RRTF::Page::Margin.parse_string("1.5in")).to eql(
      "left" => 2160,
      "top" => 2160,
      "right" => 2160,
      "bottom" => 2160
    )
  end

  it "builds a margin object from a string" do
    expect(RRTF::Page::Margin.from_string("1.5in, 3cm, 30mm, 10pt")).to eql(
      RRTF::Page::Margin.new(
        "left" => 2160,
        "top" => 1701,
        "right" => 1701,
        "bottom" => 200
      )
    )
  end
end
