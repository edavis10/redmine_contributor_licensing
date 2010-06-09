ActionController::Routing::Routes.draw do |map|
  map.resource :contributor_licenses, :member => {:upload => :get}
end
