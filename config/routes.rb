SampleApp::Application.routes.draw do
  get "sessions/new"

	resources :users
	resources :sessions, :only => [:new, :create, :destroy]

	get "pages/home"

	get "pages/contact"

	get "pages/about"

	get "pages/help"
	
	root :to => "pages#home"
	
	match '/contact', :to => 'pages#contact'
	
	match '/about', :to => 'pages#about'
	
	match '/help', :to => 'pages#help'
	
	match '/signup', :to => 'users#new'
	
	match '/signin', :to => 'sessions#new'
	
	match '/signout', :to => 'sessions#destroy'
	
end
