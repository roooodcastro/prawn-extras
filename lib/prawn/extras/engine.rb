# frozen_string_literal: true
module Prawn
  module Extras
    # Main Rails Engine
    class Engine < ::Rails::Engine
      isolate_namespace Prawn::Extras
    end
  end
end
