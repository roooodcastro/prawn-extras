# frozen_string_literal: true
module Prawn
  module Extras
    # Includes helpers to aid bounding_box calculations and its use.
    module Box
      delegate :top_left, :width, :height, to: :bounds

      # Returns the most recent created box which was created using the "box"
      # method. It will be nil if no boxes were created or if they were all
      # created with the :dont_track option set to true.
      def last_created_box
        @last_created_box ||= nil
      end

      # Translates a percentage value to an absolute width value, within the
      # limits of the current bounds (between 0 and "bounds.width").
      #
      # The value parameter must be an integer between 0 and 100. If a value
      # outside these bounds is provided, it will be clamped.
      #
      def percent_w(value)
        bounds.width * (clamp_percentage(value) / 100.0)
      end

      # Translates a percentage value to an absolute width value, within the
      # limits of the current bounds (between "bounds.height" and 0).
      #
      # The value parameter must be an integer between 0 and 100. If a value
      # outside these bounds is provided, it will be clamped.
      #
      def percent_h(value)
        bounds.height * (clamp_percentage(value) / 100.0)
      end

      # Returns the absolute height value remaining to the bottom of the
      # current bounds, relative to the provided base_height.
      #
      # The base_height parameter must be a Prawn::Document::BoundingBox object,
      # and the remaining height is calculated from the bottom side of this
      # object.
      #
      def remaining_height(base_height)
        base_height.anchor[1] - bounds.anchor[1]
      end

      # This method is mostly an alias to Prawn's default bounding_box method.
      # It passes parameters in a differnt way, but also includes the option to
      # define a padding.
      #
      # The padding may be a single integer value applied to all sides, or four
      # separate values passed as an array, applied clockwise starting from top.
      #
      # It also tracks by default which was the last box created (if using this
      # method), so that the next box may be positioned relative to the previous
      # one without the need to assign variables This can be disabled by
      # setting the option :dont_track to any truthy value.
      #
      # The size parameters can be expressed either as points, which is the
      # default, but also in percentages, both "global" and "local". To use
      # percentages, the value must be passed as a String, with the % character
      # at the end. The box will be created using "xx%" of the total available
      # space of the current bounds.
      #
      # There's also the option to specify the width and height in percentages
      # relative to the remaining space left. For example, if a box is created
      # with its left side at 300, and the page is 600 wide, there's only 50% of
      # space left, so width may only be 50% or lower. However, if width is
      # passed as "100%l", with an l at the end, it will occupy "100%" of the
      # remaining available space. This is useful for when a box must fill the
      # remaining of the page but you don't know exactly where is the cursor.
      #
      def box(position, width, height, options = {})
        size = build_size_options(position, width, height)
        box = bounding_box(position, size) do
          padding(options[:padding] || [0, 0, 0, 0]) { yield if block_given? }
        end
        @last_created_box = box unless options[:dont_track]
        box
      end

      # Sets a padding inside the current bounds. It essentially creates a new
      # bounding_box centered on the current one, smaller in size, to simulate
      # padding.
      #
      # "values" may be a single integer value applied to all sides, or four
      # separate values passed as an array, applied clockwise starting from top.
      #
      def padding(values)
        values = build_padding_values(values)
        position = padding_position(values)
        width, height = padding_size(values)
        bounding_box(position, width: width, height: height) { yield }
      end

      # Defines a box directly to the right of "origin_box". The position is
      # calculated relative to "origin_box", all other parameters are the same
      # as in the "box" method above.
      #
      # An additional :gutter option may be set. This will add the specified
      # value as space between "origin_box" and the new box.
      #
      def box_beside(origin_box, width, height, options = {}, &block)
        position = position_beside(origin_box, options[:gutter] || 0)
        box(position, width, height, options, &block)
      end

      # Defines a box directly to the right of the most recent previously
      # created box. The position is calculated relative to it, all other
      # parameters are the same as in the "box" method above.
      #
      # An additional :gutter option may be set. This will add the specified
      # value as space between the previous and the new box.
      #
      def box_beside_previous(width, height, options = {}, &block)
        box_beside(last_created_box, width, height, options, &block)
      end

      # Defines a box directly below "origin_box". The position is calculated
      # relative to "origin_box", all other parameters are the same as in the
      # "box" method above.
      #
      # An additional :gutter option may be set. This will add the specified
      # value as space between "origin_box" and the new box.
      #
      def box_below(origin_box, width, height, options = {}, &block)
        position = position_below(origin_box, options[:gutter] || 0)
        box(position, width, height, options, &block)
      end

      # Defines a box directly below the most recent previously created box.
      # The position is calculated relative to it, all other parameters are the
      # same as in the "box" method above.
      #
      # An additional :gutter option may be set. This will add the specified
      # value as space between the previous and the new box.
      #
      def box_below_previous(width, height, opcoes = {}, &block)
        box_below(last_created_box, width, height, opcoes, &block)
      end

      # Returns a two element array defining a position that is directly to the
      # right of "origin_box". An optional gutter may be passed, and it will
      # be converted to horizontal space between the "origin_box" and this new
      # position.
      #
      def position_beside(origin_box, gutter = 0)
        correct_origin = Array(origin_box).first
        return top_left if origin_box.nil?
        diff = [gutter - bounds.anchor[0], -bounds.anchor[1]]
        sum_dimensions(correct_origin.absolute_top_right, diff)
      end

      # Returns a two element array defining a position that is directly below
      # "origin_box". An optional gutter may be passed, and it will be
      # converted to vertical space between the "origin_box" and this new
      # position.
      #
      def position_below(origin_box, gutter = 0)
        correct_origin = Array(origin_box).first
        return top_left if correct_origin.nil?
        left = correct_origin.absolute_left - bounds.anchor[0]
        bottom = correct_origin.anchor[1] - bounds.anchor[1] - gutter.to_f
        [left, bottom]
      end

      protected

      def t_width(position, width)
        return width unless width.to_s.include? '%'
        valor = percent_w(width.to_f) # Global percentage
        return valor unless width.to_s.include? 'l'
        valor * (1.0 - (position.first / bounds.width)) # Local percentage
      end

      def t_height(position, height)
        return height unless height.to_s.include? '%'
        valor = percent_h(height.to_f) # Global percentage
        return valor unless height.to_s.include? 'l'
        valor * (position.last / bounds.height) # Local percentage
      end

      def build_padding_values(values)
        values = [values.to_i] * 4 unless values.is_a? Array
        values.map(&:to_i)[0..3]
      end

      def padding_position(values)
        [values[3], bounds.top - values[0]]
      end

      def padding_size(values)
        horizontal_padding = values[1] + values[3]
        vertical_padding = values[0] + values[2]
        [bounds.width - horizontal_padding, bounds.height - vertical_padding]
      end

      def sum_dimensions(dim_a, dim_b)
        [dim_a, dim_b].transpose.map { |x| x.reduce(:+) }
      end

      def build_size_options(position, width, height)
        { width: t_width(position, width), height: t_height(position, height) }
      end

      def clamp_percentage(value)
        [0, value.to_i, 100].sort[1]
      end
    end
  end
end

Prawn::Document.include Prawn::Extras::Box
