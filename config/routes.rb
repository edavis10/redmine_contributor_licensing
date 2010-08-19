ActionController::Routing::Routes.draw do |map|
  map.resources :contributor_licenses, :collection => {:sign => :get, :upload => :get, :report => :get}, :member => {:approve => :put}
end
