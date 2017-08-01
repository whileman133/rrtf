require 'rrtf'

DIR = File.dirname(__FILE__)

rtf = RRTF::Document.new
rtf.paragraph(
  "justification" => "RIGHT",
  "foreground_color" => '#ff0000',
  "font" => "ROMAN:Times"
) << \
  "Should you ever find yourself on a spacefaring vessel "\
  "wearing RED shirt, take heed and be on guard, for danger "\
  "is immanent and you are likely expendable among the crew."
File.open(DIR+'/03.rtf', 'w') { |file| file.write(rtf.to_rtf) }
