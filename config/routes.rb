Rails.application.routes.draw do
  root "home#index"
  get "result", to: "home#result"
end
