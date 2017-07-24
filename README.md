# RRTF: Ruby Rich-Text-Format Document Generator

RRTF enables programatic creation of Rich Text Format (RTF) documents in Ruby, focusing on simplifying RTF document assembly and generating clean RTF source code. This gem is founded on the [ifad-rtf gem](https://github.com/clbustos/rtf), but differs in several respects:

- The syntax for creating documents and styles is simpler.
- Paragraph styles can take on character formatting attributes (in accord to the RTF specification).
- Document stylesheets can be defined, enabling the end user to easily modify the look larger RTF documents.

The gem was created with reference to the [Microsoft Office RTF Specification (v1.9.1)](https://www.microsoft.com/en-us/download/details.aspx?id=10725).

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

Define the paragraph and character styles your document is to leverage in
a hashmap array or JSON file:

```json
[
  {
    "type": "paragraph",
    "id": "TITLE",
    "name": "Title",
    "primary": true,
    "next_style": "BODY",
    "justification": "CENTER",
    "space_after": 100,
    "bold": true,
    "underline": "DOUBLE",
    "uppercase": true,
    "font_size": 36,
    "underline_color": "#ff0000"
  },
  {
    "type": "paragraph",
    "id": "BODY",
    "name": "Body",
    "primary": true,
    "justification": "LEFT",
    "font_size": 24,
    "hyphenate": true
  },
  {
    "type": "character",
    "id": "EMPH",
    "name": "Emphasis",
    "additive": true,
    "italic": true,
    "bold": true,
    "foreground_color": "#ff0000"
  }
]
```

(Note that font size is given in _half points_ and spacing in _twentieth points_, or "twips" using the somewhat disagreeable abbreviation, in accord with the RTF specification.)

Create a RTF document object using the settings needed for your document, then build your document and save it in an RTF file:

```ruby
require 'rrtf'
require 'JSON'

raw_styles = JSON.parse File.read('styles.json')

rtf = RRTF::Document.new("stylesheet" => raw_styles)
styles = rtf.stylesheet.styles

rtf.paragraph(styles['TITLE']) << "RedShirts 101"
rtf.paragraph(styles['BODY']) do |p|
  p << "Should you ever find yourself on a spacefaring vessel wearing a"
  p.apply(styles['EMPH']) << " red "
  p << "shirt, take heed and be on guard, for danger is immanent and you are "
  p << "likely expendable among the crew..."
end

File.open('01.rtf', 'w') do |file|
   file.write(rtf.to_rtf)
end
```

![Opened in Word 2016](examples/01_mac_word15_36.png "Opened in Word 2016")

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/whileman133/rrtf.


## License

Just like ifad-rtf, this gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
