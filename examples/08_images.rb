require 'rrtf'

DIR = File.dirname(__FILE__)

rtf = RRTF::Document.new
rtf.image(DIR+'/resources/images/redshirt.png',
  "width" => "2in",                     # can also set "height"
  "sizing_mode" => "FIX_ASPECT_RATIO",  # can also be "ABSOLUTE"
  "border" => {
    "sides" => "ALL",
    "color" => '#ff0000',
    "line_type" => "DOT",
    "width" => "5pt",
    "spacing" => "12pt"
  }
)
File.open(DIR+'/08.rtf', 'w') { |file| file.write(rtf.to_rtf) }
