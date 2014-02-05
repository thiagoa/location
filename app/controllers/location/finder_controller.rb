module Location
  class FinderController < ActionController::Base
    respond_to :js

    def show
      Finder.find params[:postal_code] do |f|
        @address = f.address.to_json
      end
    end
  end
end
