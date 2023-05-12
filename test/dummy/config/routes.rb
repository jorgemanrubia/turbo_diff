Rails.application.routes.draw do
  mount TurboDiff::Engine => "/turbo_diff"

  resources :posts
  resource :sandbox
end
