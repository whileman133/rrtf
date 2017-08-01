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
  ) do |emphasis|
    emphasis.link(
      "https://en.wikipedia.org/wiki/Redshirt_(character)", "red shirt")
  end
  p << ", take heed and be on guard, for danger "
  p << "is immanent and you are likely expendable among the crew."
end
File.open(DIR+'/05.rtf', 'w') { |file| file.write(rtf.to_rtf) }
