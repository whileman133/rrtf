require "spec_helper"
require "JSON"

describe RRTF::Stylesheet do
  it "rejects invalid styles" do
    doc = RRTF::Document.new

    styles = [
      # invalid style object
      {
        "id" => "S1",
        "style" => Object.new
      },
      # invalid ID
      {
        "id" => "",
        "style" => RRTF::ParagraphStyle.new(
          "name" => "Ps 1",
          "primary" => true,
          "justification" => "RRTF::ParagraphStyle::RIGHT_JUSTIFY",
          "strike" => true,
          "italic" => true
        )
      },
      # neither style object nor type specified
      {
        "id" => "S3",
        "default" => true
      }
    ]

    styles.each do |style|
      expect{ RRTF::Stylesheet.new(doc, "styles" => [style]) }.to raise_error(RRTF::RTFError)
    end # each
  end

  it "assigns handles to styles" do
    doc = RRTF::Document.new
    styles = JSON.parse File.read('spec/resources/stylesheet/styles.json')
    stylesheet = RRTF::Stylesheet.new(doc, "styles" => styles, "base_style_handle" => 5)
    parsed_styles = stylesheet.styles
    handles = parsed_styles.values.collect(&:handle)
    # defualt style takes on the '0' handle
    expect(handles).to eq([5,6,7,0,8])
  end

  it "assigns priority to styles" do
    doc = RRTF::Document.new
    styles = JSON.parse File.read('spec/resources/stylesheet/styles.json')
    stylesheet = RRTF::Stylesheet.new(doc, "styles" => styles, "base_style_priority" => 3)
    parsed_styles = stylesheet.styles
    priorities = parsed_styles.values.collect(&:priority)
    expect(priorities).to eq([3,4,5,6,7])
  end

  it "assigns next-style handles to styles" do
    doc = RRTF::Document.new
    styles = JSON.parse File.read('spec/resources/stylesheet/styles.json')
    stylesheet = RRTF::Stylesheet.new(doc, "styles" => styles)
    parsed_styles = stylesheet.styles
    # calling to_rtf causes the next styles to be updated (to_rtf "commits" the
    # stylesheet)
    stylesheet.to_rtf

    expect(parsed_styles['PAR_1'].next_style_handle).to eq(parsed_styles['PAR_2'].handle)
  end

  it "liquifies to rtf" do
    doc = RRTF::Document.new
    styles = JSON.parse File.read('spec/resources/stylesheet/styles.json')
    stylesheet = RRTF::Stylesheet.new(doc, "styles" => styles)
    expect(stylesheet.to_rtf).to match(/\{\\stylesheet([\s]*)(\{(.*)\;([\s]*)})*([\s]*)\}/m)
    expect(stylesheet.to_rtf("uglify" => true)).to match(/\{\\stylesheet([\s]*)(\{(.*)\;([\s]*)})*([\s]*)\}/)
  end
end
