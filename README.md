# Prawn::Extras

Provides general extra functionalities to PrawnPDF.

## Usage

This gem currently includes these additional modules that are all included in
`Prawn::Document`:

### Box

This module implements methods to extend Prawn's `bounding_box` method.
Its main features are:

* Adds a shorter syntax to define bounding boxes
* Allows percentages to be passed as arguments for the width and height of boxes
* Allows placement of boxes relative to another (to the right side or below)
* Adds a `padding` method, which simply creates a nested `bounding_box` with an
added padding.

### DynamicRepeater

Did you ever run into trouble when trying to use data that changes on a per-page
basis inside Prawn's dynamic repeaters? Cry no more, this module adds two
new methods to solve this issue:

* `store_value_in_page`: Remembers that a given value is related to a given page
of the document.
* `value_in_page`: Can be used inside a `repeater(dynamic: true)` to retrieve
the values previously bound to certain pages with the above method.

### Font

Adds a single method to help add external fonts to Prawn. Default Prawn syntax
for this is:

    pdf.font_families.update(
      "MyTrueTypeFamily" => { :bold        => "foo-bold.ttf",
                              :italic      => "foo-italic.ttf",
                              :bold_italic => "foo-bold-italic.ttf",
                              :normal      => "foo.ttf" })
                              
The method `create_font_family` turns that into this:

    pdf.create_font_family('MyTrueTypeFamily')
    
This will try to load the font files from the following paths on the host
application:

    app/assets/fonts/MyTrueTypeFont.ttf
    app/assets/fonts/MyTrueTypeFont_Bold.ttf
    app/assets/fonts/MyTrueTypeFont_Italic.ttf
    app/assets/fonts/MyTrueTypeFont_BoldItalic.ttf
    
If not all styles exist, they will simply not be loaded and created.

### Grid

TODO: This helper is currently not refactored and not documented. I still need
to define if it should even be included in this gem.

### Text

Includes several helper methods to switch between fonts and also to create
styled text. Its main features are:

* `switch_font`: Change multiple font attributes with a single method. It
accepts the same arguments as the default `font` method from Prawn as well as
an argument defining the text leading. Can be used with a block, in which case
will restore the font to the previous font after the block executed. 
* `regular_font`, `bold_font`, `italic_font`, `bold_italic_font`: Accepts the
same arguments as `switch_font`, but as their names imply, also sets the style.
* `save_color`: Sets a text color, executes a block and then returns to the
previous color.
* `vertical_line`, `horizontal_line`: Prints a vertical or horizontal line at
at the specified points.
* `titled_text`: Simply prints the text with a bold label to the left. Can
optionally define the label color.

## Installation
This gem depends on the [prawn gem](https://github.com/prawnpdf/prawn).

Add this line to your application's Gemfile:

```ruby
gem 'prawn-extras'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install prawn-extras
```

## Contributing

All contributions are welcome, please raise an issue for any problems or
suggestions.

Please raise an issue along with any pull request that you wish to merge.

## License

Written by Rodrigo Castro.

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
