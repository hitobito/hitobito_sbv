module Export::Tabular::Groups
  class AddressList < List
    def attributes
      %w(name type mitgliederverband contact address zip_code town country reported_members besetzung klasse unterhaltungsmusik)
    end
  end
end
