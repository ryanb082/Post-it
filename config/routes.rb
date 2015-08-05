PostitTemplate::Application.routes.draw do
  root to: 'posts#index'

  get 'register', to: 'users#new'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  # why did it need to be called sessions instead of session
  get 'logout', to: 'sessions#destroy'
  get '/pin', to: 'sessions#pin'
  post '/pin', to: 'sessions#pin'


  
  resources :posts, except: [:destroy] do
    member do 
      post 'vote' # /post/3/vote  #post is added for semantics
    end

  	resources :comments, only: [:create] do
      member do
        post 'vote'
      end
    end
  end
  resources :categories, only: [:new, :create, :show]
  resources :users, only: [:show, :create, :edit, :update]

end

#POST /votes => votes#create
# - need 2 pieces of info

#POST/posts/3/vote => posts#vote
#POST/comments/3/vote => comments#vote