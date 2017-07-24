require 'rrtf'
require 'JSON'

DIR = File.dirname(__FILE__)

raw_styles = JSON.parse File.read(DIR+'/resources/json/redshirt_styles.json')

rtf = RRTF::Document.new("stylesheet" => raw_styles)
styles = rtf.stylesheet.styles

rtf.paragraph(styles['TITLE']) << "RedShirts 101"
rtf.paragraph(styles['BODY']) do |p|
  p << "Should you ever find yourself on a spacefaring vessel wearing a"
  p.apply(styles['EMPH']) << " red "
  p << "shirt, take heed and be on guard, for danger is immanent and you are "
  p << "likely expendable among the crew..."
end
rtf.paragraph(styles['H1']) << "1. The Danger of Away Missions"
rtf.paragraph(styles['BODY']) do |p|
  p << "If you're ever assigned an away mission, its almost certian to be your doom. "
  p << "The optimal stategy is to avoid away missions to begin with..."
end
rtf.paragraph(styles['H1']) << "2. Avoiding High-Ranking Officers"
rtf.paragraph(styles['BODY']) do |p|
  p << "You're likely to notice an influx of unfortunate outcomes around "
  p << "certian high-ranking officers. Its to your advantage to quickly identify and "
  p << "avoid these officers..."
end


File.open(DIR+'/01.rtf', 'w') do |file|
   file.write(rtf.to_rtf)
end
