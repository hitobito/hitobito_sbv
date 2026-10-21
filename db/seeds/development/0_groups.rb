#  Copyright (c) 2012-2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require Rails.root.join('db', 'seeds', 'support', 'group_seeder')

Group::Generalverband.seed_once(:name, name: 'hitobito', parent_id: nil)

superstructure = Group::Generalverband.first

Group::Root.seed_once(:parent_id, name: 'SBV', parent_id: superstructure.id)

class SbvGroupSeeder < GroupSeeder
  def seed_mitgliederverband(parent, verband)
    mv = Group::Mitgliederverband.seed(:name, :parent_id,
      group_attributes.merge(name: verband[:name], parent_id: parent.id,
                             language: verband[:language])).first

    verband[:regionalverbaende].each { |region| seed_regionalverband(mv, region) }
    seed_vereine(mv, verband[:language], verband[:vereine])

    mv.default_children.each do |child_class|
      child_class.find_by(parent_id: mv.id)&.update(group_attributes)
    end
  end

  def seed_regionalverband(parent, region)
    rv = Group::Regionalverband.seed(:name, :parent_id,
      group_attributes.merge(name: region[:name], parent_id: parent.id,
                             language: region[:language])).first

    seed_vereine(rv, region[:language], region[:vereine])
    Group::Kreis.seed_once(:name, :parent_id,
      group_attributes.merge(name: region[:kreis], parent_id: rv.id))
  end

  def seed_vereine(parent, language, vereine)
    Group::Verein.seed_once(:name, :parent_id, vereine.map do |name, besetzung|
      group_attributes.merge(name:, parent_id: parent.id,
                             language:, besetzung:)
    end)
  end
end

seeder = SbvGroupSeeder.new
root = Group::Root.order(:id).first
srand(42)

MITGLIEDERVERBAENDE = [
  {
    name: 'Bernischer Kantonal-Musikverband', language: 'de',
    vereine: { 'Regional Brass Band Bern' => 'brass_band' },
    regionalverbaende: [
      { name: 'Oberaargau', language: 'de', kreis: 'Kreis Langenthal',
        vereine: { 'Musikgesellschaft Aarwangen' => 'harmonie',
                   'Musikgesellschaft Bannwil' => 'fanfare_benelux',
                   'Tambourenverein Langenthal' => 'tambour_percussion' } },
      { name: 'Mittleres Seeland', language: 'de', kreis: 'Kreis Lyss',
        vereine: { 'Musikgesellschaft Aarberg' => 'harmonie',
                   'Musikgesellschaft Bargen' => 'brass_band' } }
    ]
  },
  {
    name: 'Société cantonale des musiques fribourgeoises / Freiburger Kantonal-Musikverband',
    language: 'fr',
    vereine: { 'Ensemble de cuivres Euphonia Bulle' => 'brass_band' },
    regionalverbaende: [
      { name: 'Gruyère', language: 'fr', kreis: 'Cercle de Bulle',
        vereine: { 'Corps de Musique de la Ville de Bulle' => 'harmonie',
                   "Société de musique l'Edelweiss de Charmey" => 'brass_band' } },
      { name: 'Sense', language: 'de', kreis: 'Kreis Düdingen',
        vereine: { 'Musikgesellschaft Alterswil' => 'harmonie',
                   'Musikgesellschaft Schmitten' => 'harmonie' } }
    ]
  },
  {
    name: 'Federazione Bandistica Ticinese', language: 'it',
    vereine: { 'Società Filarmonica Stabio' => 'harmonie' },
    regionalverbaende: [
      { name: 'Mendrisiotto', language: 'it', kreis: 'Circolo di Mendrisio',
        vereine: { 'Civica Filarmonica Mendrisio' => 'harmonie',
                   'Musica Cittadina Chiasso' => 'harmonie' } },
      { name: 'Luganese', language: 'it', kreis: 'Circolo di Lugano',
        vereine: { 'Civica Filarmonica di Lugano' => 'harmonie',
                   'Società Filarmonica Agno' => 'harmonie' } }
    ]
  }
].freeze

MITGLIEDERVERBAENDE.each { |verband| seeder.seed_mitgliederverband(root, verband) }

seeder.seed_vereine(root, 'de', 'Sinfonisches Blasorchester SIBO Bern' => 'harmonie')
