# RRTF: Ruby Rich-Text-Format Document Generator

RRTF enables programatic creation of Rich Text Format (RTF) documents in Ruby, focusing on simplifying RTF document assembly and generating clean RTF source code. This gem is founded on the [ifad-rtf gem](https://github.com/clbustos/rtf), but has simpler syntax and supports more RTF constructs.

- __Document__: Page orientation, size, margin, and gutter; mirror margins, tab width, enable/disable hyphenation, hyphenation width, maximum consecutive hyphenations, and enable/disable widow-and-orphan control.
- __Text__: Bold, italic, underline, underline color, uppercase, subscript, superscript, strike, emboss, imprint, foreground color, background color, hidden, kerning, character spacing, highlight, font, font size.
- __Paragraphs__: Justification, left indent, right indent, first line indent, space before, space after, line spacing, indentation, drop caps, keep-on-page, keep-with-next, enable/disable hyphenation, enable/disable widow-and-orphan control, absolute positioning (frames), borders, and shading.
- __Hyperlinks__: Insert hyperlinks in text runs.
- __Lists__: Basic unordered (bullet) lists.
- __Images__: Embed, size, and define borders for PNG, JPEG, and BMP images.
- __Shapes__: Draw basic shapes, custom shapes, and text boxes.
- __Stylesheets__: Define paragraph and character styles, enabling the end user to easily modify the look of RTF documents.
- __Sections__: Add sections to a document with custom page and column formatting.
- __Tabs__: Define tab stops with optional leaders for paragraphs.

The gem was created with reference to the [Microsoft Office RTF Specification (v1.9.1)](https://www.microsoft.com/en-us/download/details.aspx?id=10725). The syntax for custom shapes was determined by reverse engineering the RTF output from Word 2016 and reference to [Microsoft's Binary Format Specification (pp. 32-33)](https://www.loc.gov/preservation/digital/formats/digformatspecs/OfficeDrawing97-2007BinaryFormatSpecification.pdf).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rrtf'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rrtf

## Usage

```ruby
require 'rrtf'

# Construct an object representing the RTF document
rtf = RRTF::Document.new

# ...
# Call methods on `rtf` to generate content
# ...

# Convert document into RTF string
rtf.to_rtf
```

#### Paragraphs

- __Plain paragraph__

   ```ruby
    rtf.paragraph << \
      "Should you ever find yourself on a spacefaring vessel "\
      "wearing RED shirt, take heed and be on guard, for danger "\
      "is immanent and you are likely expendable among the crew."
    ```

- __Paragraph with inline styling__

    ```ruby
    rtf.paragraph(
      "justification" => "RIGHT",
      "foreground_color" => '#ff0000',
      "font" => "ROMAN:Times"
    ) << \
      "Should you ever find yourself on a spacefaring vessel "\
      "wearing RED shirt, take heed and be on guard, for danger "\
      "is immanent and you are likely expendable among the crew."
    ```

- __Paragraph with inline character styling__

    ```ruby
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
    ```

#### Hyperlinks

```ruby
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
```

#### Lists

```ruby
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
```

#### Images

```ruby
rtf.image(DIR+'/resources/images/redshirt.png',
  "width" => "2in",                     # can also set "height"
  "sizing_mode" => "FIX_ASPECT_RATIO",  # can also be "ABSOLUTE"
  "border" => {
    "sides" => "ALL",
    "color" => '#ff0000',
    "line_type" => "DOT",
    "width" => "5pt",
    "spacing" => "12pt"
  }
)
```

#### Shapes

- __Basic shapes__

    ```ruby
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
    ```

- __Text boxes__

    ```ruby
    rtf.geometry(
      "type" => "TEXT_BOX",
      "line_color" => '#000000',
      "line_width" => '3pt',
      "top" => "5in",
      "left" => "2.5in",
      "width" => "3in",
      "height" => "3in",
      "horizontal_reference" => "PAGE",
      "vertical_reference" => "PAGE"
    ) do |box|
      box.paragraph do |p|
        p << "Should you ever find yourself on a spacefaring vessel wearing a "
        p << "RED"
        p << " shirt, take heed and be on guard, for danger "
        p << "is immanent and you are likely expendable among the crew."
      end
    end
    ```

- __Custom shapes__

    ```ruby
    rtf.geometry(
      "type" => "CUSTOM",
      "top" => 0,
      "left" => "4in",
      "width" => "3in",
      "height" => "3in",
      "path" => [
        # points are relative to the upper left corner of the shape as
        # determined by "top"/"left"/"bottom"/"right"/"width"/"height"
        ["START_AT",        [0,0]                                           ],
        ["LINE_TO",         ['2in', 0]                                      ],
        ["CUBIC_BEZIER_TO", ['3in', 0], ['3in', '1.5in'], ['3in', '3in']    ],
        ["LINE_TO",         [0, 0]                                          ],
        ["CLOSE_PATH"                                                       ],
        ["END"                                                              ]
      ],
      "fill_color" => '#00cc00',
      "line_color" => '#000099'
    )
    ```

#### Stylesheet

```ruby
raw_styles = JSON.parse File.read(DIR+'/resources/json/redshirt_styles.json')
rtf = RRTF::Document.new("stylesheet" => raw_styles)
styles = rtf.stylesheet.styles

rtf.paragraph(styles['TITLE']) << "Redshirt Pocket Guide"
rtf.paragraph(styles['SUBTITLE']) do |p|
  p << "3"
  p.apply("superscript" => true) << "rd"
  p << " Edition"
end
```

#### Sections

```ruby
rtf.paragraph << "Redshirt Pocket Guide"
# start a new section with the prescribed styling
rtf.section("columns" => 2)
rtf.paragraph << "Section Text"
```

#### Tabs

```ruby
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
```

## TODO

- Develop rspec examples to replace the unit tests for the classes in the original ifad-rtf gem.
- Make existing comments yard friendly.
- Refactor interface between styles and colour/font tables: right now AnonymousStyle defines push_colours and push_fonts methods that are called by CommandNode#paragraph, CommandNode#apply, and ImageNode#initialize (these actions should rather be taken when a style is created or updated).
- Fix list and nested list formatting issues (alignment).
- Add support for tables.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/whileman133/rrtf.

## License

Just like ifad-rtf, this gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
