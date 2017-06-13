# frozen_string_literal: true
module Prawn
  module Extras
    # ==========================================================================
    #
    # This module contains helpers that alleviate the problem of inserting
    # dynamic content (content that changes on each page) inside dynamic
    # repeaters. This is needed because dynamic repeaters are only evaluated
    # after all pages are generated, so you cannot assign a value to a variable
    # on each page and use this same value in the repeater (it will only give
    # you the value for the last page).
    #
    # The 2 methods below use a hash that maps custom values to each
    # page_number, so you can fill this hash during pages generation, and then
    # later read the values during repeater evaluation.
    #
    # As an example, suppose you have the models Post and Comment for a blog.
    # You now need to generate a PDF that lists all comments for each post,
    # printing the post title in a header that repeats on every page.
    # Each post may have hundreds of comments, so you don't know beforehand how
    # many pages each post will use, and thus cannot know in which pages you
    # need to print the title for post X or post Y. To solve this, simply use:
    #
    # When you first iterate over the posts:
    #
    #   posts.each_with_index do |post, index|
    #     start_new_page unless index == 0
    #     store_value_in_page('post_title', post.title)
    #     print_list_of_comments_that_may_span_more_than_one_page
    #   end
    #
    # And finally, when you're inside a dynamic repeater and need to print the
    # post's title (we use the page_number helper provided by Prawn::Document):
    #
    #   repeater(dynamic: true) do
    #     print_static_header_stuff
    #     text(value_in_page('post_title', page_number))
    #   end
    #
    # ==========================================================================
    module DynamicRepeater
      # Saves a named value for a specific page of the generated PDF. This will
      # save the value for the specified page and also fill any page gaps with
      # the latest previous value submitted.
      #
      # Example:
      #
      # store_value_in_page(:name, 'John', 3)
      #
      # This will save the value "John" at the :name key for the pages 1, 2
      # and 3. Any subsequent calls to this method (for the same key) will not
      # override these values.
      #
      def store_value_in_page(key, value, page = page_number)
        latest_value = value_in_page(key, page) # Gets the last value submitted
        (page - 1).downto(max_index(key)).each do |page_index|
          repeater_values(key)[page_index] = latest_value
        end
        repeater_values(key)[page] = value
      end

      # Returns the value for a key at a specific page. If the page is greater
      # than the highest saved page, the highest value is returned.
      #
      # Examples:
      #
      # save_repeater_value(:name, 'John', 3)
      # save_repeater_value(:name, 'Jane', 5)
      #
      # value_in_page(:name, 1) => "John"
      # value_in_page(:name, 2) => "John"
      # value_in_page(:name, 3) => "John"
      # value_in_page(:name, 4) => "Jane"
      # value_in_page(:name, 5) => "Jane"
      # value_in_page(:name, 6) => "Jane"
      # value_in_page(:name, -1) => ""
      #
      def value_in_page(key, page, default_value = '')
        repeater_values(key)[[page, max_index(key)].min] || default_value
      end

      private

      def max_index(key)
        repeater_values(key).keys.max.to_i
      end

      def repeater_values(key)
        @repeater_values ||= {}
        @repeater_values[key] ||= {}
        @repeater_values[key]
      end
    end
  end
end

Prawn::Document.include Prawn::Extras::DynamicRepeater
