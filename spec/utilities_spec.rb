require 'spec_helper'

describe RRTF::Utilities do
  it "parses strings into integer values in twips" do
    expect(RRTF::Utilities.value2twips("1.5in")).to eq(2160)
    expect(RRTF::Utilities.value2twips("3cm")).to eq(1701)
    expect(RRTF::Utilities.value2twips("30mm")).to eq(1701)
    expect(RRTF::Utilities.value2twips("10pt")).to eq(200)
  end
end
