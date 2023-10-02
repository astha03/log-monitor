Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do 
      root to: "logs#index"
      
      get "/logs", to: "logs#get_log"
    end
  end
end

