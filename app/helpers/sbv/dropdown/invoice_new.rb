module Sbv
  module Dropdown
    module InvoiceNew
      extend ActiveSupport::Concern

      def additional_sub_links
        super - [:membership_fee]
      end
    end
  end
end
