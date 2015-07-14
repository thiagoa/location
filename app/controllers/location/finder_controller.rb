module Location
  class FinderController < ActionController::Base
    def show
      Finder.find params[:postal_code] do |f|
        address = f.address.to_hash(only: params[:only]).to_json
        render json: address
      end
    end
  end
end
