module Export::Tabular::Groups
  class AddressList < List
    def attributes
      %w(name type address zip_code town country reported_members)
    end
  end
end
