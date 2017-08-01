require "spec_helper"

describe RRTF::DocumentProperties do
  it "applies document formatting" do
    prop = RRTF::DocumentProperties.new(
      "facing_pages" => true,
      "mirror_margins" => true,
      "widow_orphan_ctl" => true,
      "tab_width" => "1in",
      "hyphenation_width" => "1in",
      "max_consecutive_hyphenation" => 2,
      "hyphenate" => true
    )
    rtf = prop.to_rtf
    expect(rtf).to match(/\\facingp/)
    expect(rtf).to match(/\\margmirror/)
    expect(rtf).to match(/\\widowctl/)
    expect(rtf).to match(/\\deftab1440/)
    expect(rtf).to match(/\\hyphconsec2/)
    expect(rtf).to match(/\\hyphhotz1440/)
    expect(rtf).to match(/\\hyphauto1/)
  end

  it "applies page formatting" do
    prop = RRTF::DocumentProperties.new(
      "orientation" => "LANDSCAPE",
      "size" => "1in,2in",
      "margin" => "1in,2in,3in,4in",
      "gutter" => "0.5in"
    )
    rtf = prop.to_rtf
    expect(rtf).to match(/\\landscape/)
    expect(rtf).to match(/\\paperw1440/)
    expect(rtf).to match(/\\paperh2880/)
    expect(rtf).to match(/\\margl1440/)
    expect(rtf).to match(/\\margr2880/)
    expect(rtf).to match(/\\margt4320/)
    expect(rtf).to match(/\\margb5760/)
    expect(rtf).to match(/\\gutter720/)
  end
end
