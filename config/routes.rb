Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users, only: [:index, :create]
  resources :messages, only: [:create] do
    collection do
      get ':current_user_id/:target_user_id', to: 'messages#index'
    end
  end

end
