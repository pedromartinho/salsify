Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :lines, only: %i[show]
  # get '/first_solution_lines/:id', to: 'lines#first_solution
end
