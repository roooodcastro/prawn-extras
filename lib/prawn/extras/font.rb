# frozen_string_literal: true
module Prawn
  module Extras
    # This module includes helpers to aid font management in Prawn.
    module Font
      # Adds new fonts to the Prawn available fonts. By just passing the font
      # family name, this will try to load all available font styles. The file
      # structure and name format that is required for this is (using a TTF
      # font as example):
      #
      # app/assets/fonts/Family.ttf
      # app/assets/fonts/Family_Bold.ttf
      # app/assets/fonts/Family_Italic.ttf
      # app/assets/fonts/Family_BoldItalic.ttf
      #
      # If the file for one of these styles doesn't exist, it will not be
      # defined, and if someone tries to use it, a Prawn::Errors::UnknownFont
      # error will be raised.
      def create_font_family(family, extension = :ttf)
        family_hash = generate_font_family_hash(family, extension)
        remove_nonexistent_font_styles(family_hash)
        font_families.update(family => family_hash)
      end

      protected

      def generate_font_family_hash(family, ext)
        {
          bold:        external_font_filepath(family, :bold, ext),
          italic:      external_font_filepath(family, :italic, ext),
          bold_italic: external_font_filepath(family, :bold_italic, ext),
          normal:      external_font_filepath(family, :normal, ext)
        }
      end

      def remove_nonexistent_font_styles(fam_hash)
        fam_hash.delete(:bold) unless File.exist?(fam_hash[:bold])
        fam_hash.delete(:italic) unless File.exist?(fam_hash[:italic])
        fam_hash.delete(:bold_italic) unless File.exist?(fam_hash[:bold_italic])
      end

      def external_font_filepath(family, style, extension)
        new_style = '' if style.to_s == 'normal'
        new_style = "_#{style.to_s.camelcase}" if style.to_s != 'normal'
        filename = "#{family}#{new_style}.#{extension}"
        Rails.root.join('app', 'assets', 'fonts', filename)
      end
    end
  end
end

Prawn::Document.include Prawn::Extras::Font
