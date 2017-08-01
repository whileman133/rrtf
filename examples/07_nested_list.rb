require 'rrtf'

DIR = File.dirname(__FILE__)

rtf = RRTF::Document.new
rtf.list do |l|
  l.item do |li|
    li << "Never venture into ominous settings such as:"
  end

  l.list do |l2|
    l2.item{ |li| li << "Dark caves." }
    l2.item{ |li| li << "Abandoned vessels." }
    l2.item{ |li| li << "Misty planets." }
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
File.open(DIR+'/07.rtf', 'w') { |file| file.write(rtf.to_rtf) }
