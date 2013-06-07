module Spree
  module Admin
    class Spree::Admin::VendorOverviewController < Spree::BaseController
      
      # TODO - get this shit to work! won't worry about it until I need 
      # vendor functionality.
      # ssl_required

      # helper :search
      # helper 'admin/navigation'
      # layout 'admin'

      before_filter :vendor

      def vendor 
        if !spree_current_user.has_spree_role?("vendor")
          unauthorized
        end
      end
      def index 
        
      end
    end
  end
end