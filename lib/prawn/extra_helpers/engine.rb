module Prawn
  module ExtraHelpers
    class Engine < ::Rails::Engine
      isolate_namespace Prawn::ExtraHelpers
    end
  end
end
