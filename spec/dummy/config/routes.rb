Rails.application.routes.draw do
  mount Prawn::ExtraHelpers::Engine => '/prawn-extra_helpers'
end
