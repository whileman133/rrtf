_Version 0.0.1:_

- Initial RRTF release based on the ifad-rtf gem with stylesheet support added.

_Version 0.0.2:_

- Simplified style syntax and changed all options hash keys to strings.
- Extract paragraph & character style formatting attributes into modules.

_Version 1.0.0:_

- Migrate DocumentStyle to DocumentProperties since DocumentStyle was not logically a descendent of the Style class (a style can be added to a stylesheet and applied to elements within a document, e.g. paragraphs, characters, tables, but use properties to style an entire document).
- Extract document and page formatting attributes into modules.
- Create Page module and Page::Margin and Page::Size classes to assist in parsing page size and margin from strings.
- Use the FastImage gem to identify image type and dimensions in place of custom byte-level functions.
- Remove character formatting helpers (bold, italic, font, etc.); use apply() with anonymous styles instead.
- Remove crop options from ImageNode; Word 2016 improperly parses them and LibreOffice ignores them.
- Remove x_scaling and y_scaling attributes from ImageNode; the same behavior can be accomplished with display_width & display_height.
- Add sizing_mode attribute to ImageNode to allow absolute sizing and fixed aspect ratio sizing.
- Allow anonymous paragraph and character styles.
- Add AnonymousStyle base class to support other style types (e.g. border styling).
- Add BorderFormatting module and BorderStyle class to allow border definition on paragraphs and images.
- Add ShadingFormatting module and ShadingStyle class to allow paragraph shading.
- Add ShapeNode class to implement basic shapes.

_Version 1.0.1:_

- Allow remote source for images with open-uri.
- Fix issue with setting "text_margin" for text boxes.

_Version 1.1.0:_

- Add support for sections.

_Version 1.2.0:_

- Add support for column breaks.

_Version 1.3.0:_

- Add support for tab stops (`tab` method in `CommandNode` class, "tabs" option for paragraph formatting, and `TabStyle` class).
