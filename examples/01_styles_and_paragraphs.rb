require 'rrtf'
require 'JSON'

DIR = File.dirname(__FILE__)

raw_styles = JSON.parse File.read(DIR+'/resources/json/redshirt_styles.json')

rtf = RRTF::Document.new(
  "stylesheet" => raw_styles,
  "document_properties" => {
    "hyphenate" => true,
    "widow_orphan_ctl" => true,
    "facing_pages" => true,
    "size" => "3.5in,5in",
    "margin" => "0.2in,0.25in",
    "gutter" => "0.25in",
    "tab_width" => "0.1in"
  }
)
styles = rtf.stylesheet.styles

# paragraphs with styles tied to the stylesheet
rtf.geometry(
  "type" => "TEXT_BOX",
  "top" => "0.5in",
  "left" => 0,
  "width" => "3.5in",
  "height" => "1in",
  "horizontal_reference" => "PAGE",
  "vertical_reference" => "PAGE",
  "z_index" => 100
) do |box|
  box.paragraph(styles['TITLE']) << "Redshirt Pocket Guide"
  box.paragraph(styles['SUBTITLE']) do |p|
    p << "3"
    # apply an anonymous character style
    p.apply("superscript" => true) << "rd"
    p << " Edition"
  end
end
rtf.geometry(
  "type" => "RECTANGLE",
  "top" => 0,
  "left" => 0,
  "width" => "3.5in",
  "height" => "5in",
  "fill_color" => '#ff0000',
  "below_text" => true,
  "horizontal_reference" => "PAGE",
  "vertical_reference" => "PAGE",
  "z_index" => 0
)

rtf.page_break

rtf.paragraph(styles['H1']) << "Preface"
# drop caps
rtf.paragraph(styles['DROP_CAPS']) << 'S'
rtf.paragraph(styles['BODY']) do |p|
  p << "hould you ever find yourself on a spacefaring vessel wearing a"
  # apply a character style tied to the stylesheet
  p.apply(styles['EMPH']) << " red "
  p << "shirt, take heed and be on guard, for danger is immanent and you are "
  p << "likely expendable among the crew."
end
rtf.paragraph(styles['BODY']) do |p|
  p << "Study this guide that you might escape your ill fate."
end
# a paragraph with an anonymous style
rtf.paragraph(
  "justification" => "CENTER",
  "position" => {
    "size" => "3.5in,0in",
    "horizontal_position" => 0,
    "vertical_position" => "BOTTOM",
    "horizontal_reference" => "PAGE",
    "vertical_reference" => "PAGE"
  }
) do |p|
  # insert sized image
  p.image(DIR+'/resources/images/redshirt.png',
    "width" => "1.2in", # can also set "height"
    "sizing_mode" => "FIX_ASPECT_RATIO" # can also be "ABSOLUTE"
  )
end

# insert page_break
rtf.page_break

rtf.paragraph(styles['H1']) << "The Danger of Away Missions"
rtf.paragraph(styles['BODY']) do |p|
  p << "If you're ever assigned an away mission, it's almost certain to be your doom. "
  p << "The optimal strategy is to avoid away missions to begin with, but if you're tied "
  p << "into one, follow these guidelines:"
  # insert an unordered list
  p.list do |l|
    l.item{ |li| li << "Never venture into an ominous setting." }
    l.item do |li|
      li << "Never attempt to disable an unknown entity. "
      li << "Get away quickly."
    end
    l.item{ |li| li << "Never stand guard alone. Make certain at least three other redshirts are present." }
  end
end
rtf.geometry(
  "type" => "TEXT_BOX",
  "left" => 0,
  "top" => 0,
  "width" => "0.75in",
  "height" => "1in",
  "z_index" => 0,
  "fill_color" => '#ff0000',
  "horizontal_reference" => 'PAGE',
  "vertical_reference" => 'PAGE'
) do |b|
  b.paragraph(
    "foreground_color" => '#ffffff',
    "font_size" => '56pt',
    "justification" => 'CENTER'
  ) << '1'
end
rtf.geometry(
  "type" => "RIGHT_TRIANGLE",
  "left" => '3in',
  "top" => '4.5in',
  "width" => ".5in",
  "height" => ".5in",
  "z_index" => 0,
  "fill_color" => '#ff0000',
  "flip_horizontal" => true,
  "horizontal_reference" => 'PAGE',
  "vertical_reference" => 'PAGE'
)

rtf.page_break

rtf.paragraph(styles['H1']) << "Avoiding High-Ranking Officers"
rtf.paragraph(styles['BODY']) do |p|
  p << "You're likely to notice an influx of unfortunate outcomes around "
  p << "certain high-ranking officers. It's to your advantage to quickly identify and "
  p << "avoid these officers..."
end
rtf.geometry(
  "type" => "TEXT_BOX",
  "left" => 0,
  "top" => 0,
  "width" => "0.75in",
  "height" => "1in",
  "z_index" => 0,
  "fill_color" => '#ff0000',
  "horizontal_reference" => 'PAGE',
  "vertical_reference" => 'PAGE'
) do |b|
  b.paragraph(
    "foreground_color" => '#ffffff',
    "font_size" => '56pt',
    "justification" => 'CENTER'
  ) << '2'
end
rtf.geometry(
  "type" => "RIGHT_TRIANGLE",
  "left" => '3in',
  "top" => '4.5in',
  "width" => ".5in",
  "height" => ".5in",
  "z_index" => 0,
  "fill_color" => '#ff0000',
  "flip_horizontal" => true,
  "horizontal_reference" => 'PAGE',
  "vertical_reference" => 'PAGE'
)

# save RTF output to file
File.open(DIR+'/01.rtf', 'w') do |file|
   file.write(rtf.to_rtf)
end
