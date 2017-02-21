module Prawn
  module Extras
    module Text
      # Changes the font family, style, size and leading. When a block is used,
      # the font is applied transactionally and is rolled back when the block
      # exits.
      #
      # The accepted options are:
      #
      # family: A string that can be one of the 14 built-in fonts supported by
      # PDF, or the location of a TTF file. The Font::AFM::BUILT_INS array
      # specifies the valid built in font values.
      #
      # leading: A number that sets the document-wide text leading.
      #
      # size: A number indicating the font size, in points.
      #
      # style: The font style. To use the :style option you need to map those
      # font styles to their respective font files. See font_families for
      # more information.
      #
      def switch_font(options)
        return font_and_leading(options) unless block_given?
        save_leading { font_and_leading(options) { yield } }
      end

      # Sets the font to the same as before, but removing italic or bold style.
      # All options from set_font may also be used here.
      def regular_font(options = {}, &block)
        switch_font(options.merge(style: :normal), &block)
      end

      # Sets the font to the same as before, but applying the bold style.
      # All options from set_font may also be used here.
      def bold_font(options = {}, &block)
        switch_font(options.merge(style: :bold), &block)
      end

      # Sets the font to the same as before, but applying the italic style.
      # All options from set_font may also be used here.
      def italic_font(options = {}, &block)
        switch_font(options.merge(style: :italic), &block)
      end

      # Transactionally changes the fill color, rolling back the previous color
      # when the block exits.
      def save_color(new_color)
        current_color = fill_color
        fill_color(new_color)
        yield
        fill_color current_color
      end

      # Outputs a horizontal line, similar to the HMTL equivalent <hr>, at the
      # current cursor position.
      #
      # The padding parameter is optional, and when specified sets a
      # horizontal padding before and after the sides of the line with the
      # corresponding size in points. This reduces the width of the line by a
      # factor of 2 * padding.
      #
      # This method returns the Document, and therefore is chainable with other
      # Document methods.
      #
      def horizontal_line(padding = 0)
        left_position = [padding, cursor]
        right_position = [bounds.width - padding, cursor]
        stroke_line(left_position, right_position)
        self
      end

      # Outputs one or more vertical lines, at the specified horizontal
      # position, going all the way from the top to the bottom of the current
      # bounds object.
      #
      # This method returns the Document, and therefore is chainable with other
      # Document methods.
      #
      def vertical_line(*horizontal_positions)
        horizontal_positions.each do |horiz_pos|
          stroke_line([horiz_pos, percent_h(100)], [horiz_pos, 0])
        end
        self
      end

      # Outputs the text prepended with a bold title. It is possible to change
      # the title to italic by specifying the appropriate :styles option.
      #
      # Example:
      #
      # titled_text('Name', 'John') => "Name: John", where "Name" is bold
      #
      def titled_text(title, text, options = {})
        style = options.delete(:styles) || [:bold]
        title_options = { styles: style, text: "#{t(title)}: " }
        title_options[:color] = options.delete(:color)
        formatted_text_box([title_options, { text: t(text) }], options)
      end

      # Alias to the corresponding i18n method, with the additional caveat that,
      # if a String is passed, the same string will be returned. It will only
      # try to translate the text if text_or_key parameter is a Symbol.
      #
      # It also namespaces the i18n context to the @i18n_scope variable.
      #
      def t(text_or_key, options = {})
        return text_or_key.to_s unless text_or_key.is_a?(Symbol)
        I18n.t(text_or_key, { scope: @i18n_scope }.merge(options))
      end

      protected

      def save_leading(new_leading = nil)
        leading = default_leading
        default_leading(new_leading) if new_leading.present?
        yield
        default_leading(leading)
      end

      def font_and_leading(options, &block)
        default_leading(options.delete(:leading)) if options[:leading]
        font(options[:family] || 'Helvetica', options, &block)
      end
    end
  end
end

Prawn::Document.include Prawn::Extras::Text
