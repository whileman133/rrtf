require 'rrtf'

DIR = File.dirname(__FILE__)

rtf = RRTF::Document.new
rtf.list do |l|
  l.item do |li|
    li << "Never venture into an ominous setting."
  end

  l.item do |li|
    li << "Never attempt to disable an unknown entity. "
    li << "Get away quickly."
  end

  l.item do |li|
    li << "Never stand guard alone. Make certain at least three "
    li << "other redshirts are present."
  end
end
File.open(DIR+'/06.rtf', 'w') { |file| file.write(rtf.to_rtf) }
