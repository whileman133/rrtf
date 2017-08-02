require 'rrtf'

DIR = File.dirname(__FILE__)

rtf = RRTF::Document.new

rtf.paragraph << "Redshirt Pocket Guide"
rtf.section("columns" => 2)
rtf.paragraph << "Section Text"

File.open(DIR+'/11.rtf', 'w') { |file| file.write(rtf.to_rtf) }
