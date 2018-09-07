Rails.application.routes.draw do
  get 'page/show_settings'
  post 'page/update_settings'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
   root 'page#show_settings'
end
