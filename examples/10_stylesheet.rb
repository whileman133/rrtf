require 'rrtf'

DIR = File.dirname(__FILE__)

raw_styles = JSON.parse File.read(DIR+'/resources/json/redshirt_styles.json')
rtf = RRTF::Document.new("stylesheet" => raw_styles)
styles = rtf.stylesheet.styles

rtf.paragraph(styles['TITLE']) << "Redshirt Pocket Guide"
rtf.paragraph(styles['SUBTITLE']) do |p|
  p << "3"
  # apply an anonymous character style
  p.apply("superscript" => true) << "rd"
  p << " Edition"
end

File.open(DIR+'/10.rtf', 'w') { |file| file.write(rtf.to_rtf) }
