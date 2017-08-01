require 'rrtf'

DIR = File.dirname(__FILE__)

rtf = RRTF::Document.new
rtf.geometry(
  "type" => "RECTANGLE",
  "fill_color" => '#cccccc',
  "top" => 0,
  "left" => 0,
  "width" => "2in",
  "height" => "2in",
  "horizontal_reference" => "PAGE",
  "vertical_reference" => "PAGE"
)
rtf.geometry(
  "type" => "TEXT_BOX",
  "fill_color" => '#ff0000',
  "line_color" => '#000000',
  "line_width" => '3pt',
  "top" => "5in",
  "left" => "2.5in",
  "width" => "3in",
  "height" => "3in",
  "horizontal_reference" => "PAGE",
  "vertical_reference" => "PAGE",
  "text_margin" => "0.5in"
) do |box|
  box.paragraph("foreground_color" => '#ffffff') do |p|
    p << "Should you ever find yourself on a spacefaring vessel wearing a "
    p.apply(
      "italic" => true,
      "bold" => true,
      "underline" => "SINGLE"
    ) << "red"
    p << " shirt, take heed and be on guard, for danger "
    p << "is immanent and you are likely expendable among the crew."
  end
end
rtf.geometry(
  "type" => "CUSTOM",
  "path" => [
    ["START_AT",        [0,0]                                           ],
    ["LINE_TO",         ['2in', 0]                                      ],
    ["CUBIC_BEZIER_TO", ['3in', 0], ['3in', '1.5in'], ['3in', '3in']    ],
    ["LINE_TO",         [0, 0]                                          ],
    ["CLOSE_PATH"                                                       ],
    ["END"                                                              ]
  ],
  "fill_color" => '#00cc00',
  "line_color" => '#000099',
  "top" => 0,
  "left" => "4in",
  "width" => "3in",
  "height" => "3in"
)
File.open(DIR+'/09.rtf', 'w') { |file| file.write(rtf.to_rtf) }
