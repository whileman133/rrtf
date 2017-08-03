require 'rrtf'

DIR = File.dirname(__FILE__)

rtf = RRTF::Document.new

rtf.paragraph("tabs" => {
    "leader" => "DOT",
    "type" => "FLUSH_RIGHT",
    "position" => "2in"
}) do |p|
  p << "Engineers"
  p.tab
  p << "10"
  p.line_break
  p << "Redshirts"
  p.tab
  p << "100"
end

File.open(DIR+'/12.rtf', 'w') { |file| file.write(rtf.to_rtf) }
