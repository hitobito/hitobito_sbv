class AddActiveYearsToPeople < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :active_years, :integer
    add_column :people, :active_role, :boolean, default: false, null: false
    Person.reset_column_information
    reversible do |dir|
      dir.up do
        say_with_time("Calculating active years") do
          end_date = Time.zone.now

          Person.find_each do |person|
            active_years = person.roles.with_inactive.where("type LIKE '%Mitglied'").map do |role|
              VeteranYears.new((role.start_on || role.created_at).year, (role.end_on || end_date).year)
            end.sort.sum.years.to_i
            active_roles = person.roles.where("type LIKE '%Mitglied'").any?

            person.active_years = active_years
            person.active_role  = active_roles
            person.save(validate: false)
          end
        end
      end
    end
  end
end
