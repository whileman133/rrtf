require 'rrtf'

DIR = File.dirname(__FILE__)

rtf = RRTF::Document.new
rtf.paragraph do |p|
  p << "Should you ever find yourself on a spacefaring vessel wearing a "
  p.apply(
    "foreground_color" => '#ff0000',
    "underline_color" => '#ff0000',
    "italic" => true,
    "bold" => true,
    "underline" => "SINGLE"
  ) << "red"
  p << " shirt, take heed and be on guard, for danger "
  p << "is immanent and you are likely expendable among the crew."
end
File.open(DIR+'/04.rtf', 'w') { |file| file.write(rtf.to_rtf) }
