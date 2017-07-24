require "spec_helper"

describe RRTF::ParagraphStyle do
  it "is a paragraph style" do
    ps = RRTF::ParagraphStyle.new
    expect(ps.is_paragraph_style?).to be true
    expect(ps.is_character_style?).to be false
    expect(ps.is_document_style?).to be false
    expect(ps.is_table_style?).to be false
  end

  it "liquifies to RTF" do
    doc = RRTF::Document.new
    style = RRTF::ParagraphStyle.new(
      "name" => "Style1",
      "handle" => 1,
      "next_style_handle" => 2,
      "primary" => true
    )
    expect(style.to_rtf(doc)).to match(/\{\\s1([\\\w\s]*)(\\snext2)([\s]*)(\\sqformat)([\s]*)([\\\w\s]*)Style1([\s]*);\}/)
    expect(style.to_rtf(doc, "uglify" => true)).to match(/\{\\s1([\\\w\s]*)(\\snext2)([\s]*)(\\sqformat)([\s]*)([\\\w\s]*)Style1([\s]*);\}/)
  end

  it "applies paragraph formatting" do
    doc = RRTF::Document.new
    style = RRTF::ParagraphStyle.new(
      "handle" => 0,
      "justification" => "CENTER",
      "left_indent" => 10,
      "right_indent" => 25,
      "first_line_indent" => 50,
      "space_before" => 20,
      "space_after" => 35,
      "line_spacing" => 75
    )
    rtf = style.to_rtf(doc)
    expect(rtf).to match(/\\qc/)
    expect(rtf).to match(/\\li10/)
    expect(rtf).to match(/\\ri25/)
    expect(rtf).to match(/\\sb20/)
    expect(rtf).to match(/\\sa35/)
    expect(rtf).to match(/\\sl75/)
  end

  it "applies character formatting" do
    doc = RRTF::Document.new
    style = RRTF::ParagraphStyle.new(
      "handle" => 0,
      "bold" => true,
      "italic" => true,
      "underline" => true,
      "superscript" => true,
      "subscript" => true,
      "uppercase" => true,
      "strike" => true,
      "hidden" => true,
      "foreground_color" => '#ff0000',
      "background_color" => '#0000ff',
      "font" => "SWISS:Helvetica",
      "font_size" => 12
    )
    style.push_colours(doc.colours)
    style.push_fonts(doc.fonts)
    rtf = style.to_rtf(doc)
    expect(rtf).to match(/\\b/)
    expect(rtf).to match(/\\i/)
    expect(rtf).to match(/\\ul/)
    expect(rtf).to match(/\\super/)
    expect(rtf).to match(/\\sub/)
    expect(rtf).to match(/\\caps/)
    expect(rtf).to match(/\\strike/)
    expect(rtf).to match(/\\v/)
    expect(rtf).to match(/\\cf1/)
    expect(rtf).to match(/\\cb2/)
    expect(rtf).to match(/\\f0/)
    expect(rtf).to match(/\\fs12/)
  end

  it "removes character formatting" do
    doc = RRTF::Document.new
    style = RRTF::ParagraphStyle.new(
      "handle" => 0,
      "bold" => false,
      "italic" => false,
      "underline" => false,
      "superscript" => false,
      "subscript" => false,
      "uppercase" => false,
      "strike" => false
    )
    rtf = style.to_rtf(doc)
    expect(rtf).to match(/\\b0/)
    expect(rtf).to match(/\\i0/)
    expect(rtf).to match(/\\ulnone/)
    expect(rtf).to match(/\\super0/)
    expect(rtf).to match(/\\sub0/)
    expect(rtf).to match(/\\caps0/)
    expect(rtf).to match(/\\strike0/)
  end
end
