require 'spec_helper'
require 'csv'

describe Export::SubgroupsExportJob do
  let(:subject) { described_class.new(people(:admin), groups(:hauptgruppe_1), {}) }

  it 'only exports Verband and Verein group types' do
    names = subject.send(:entries).collect { |e| e.class.sti_name }.uniq
    expect(names).to eq ["Group::Mitgliederverband", "Group::Regionalverband", "Group::Verein"]
  end

  it ' exports address and special columns7' do
    csv = CSV.parse(subject.data, col_sep: ';', headers: true)
    expect(csv.headers).to eq ["Name", "Gruppentyp", "Mitgliederverband", "Kontaktperson", 
                               "Adresse", "PLZ", "Ort", "Land", "Gemeldete Mitglieder", 
                               "Besetzung", "Klasse", "Unterhaltungsmusik"]
  end

end
