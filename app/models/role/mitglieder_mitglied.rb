# frozen_string_literal: true

#  Copyright (c) 2018-2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  person_id  :integer          not null
#  group_id   :integer          not null
#  type       :string(255)      not null
#  label      :string(255)
#  created_at :datetime
#  updated_at :datetime
#  deleted_at :datetime
#

class Role::MitgliederMitglied < Role
  include I18nEnums

  # Order follows woodwind → saxophone → brass → percussion → other
  INSTRUMENTS = %w[
    piccolo
    querfloete
    oboe
    englischhorn
    fagott
    es_klarinette
    klarinette
    bassklarinette
    saxophon_sopran
    saxophon_alt
    saxophon_tenor
    saxophon_bariton
    saxophon_bass
    trompete
    cornet_es
    cornet_b
    fluegelhorn
    waldhorn
    althorn
    tenorhorn
    bariton
    euphonium
    posaune
    bassposaune
    tuba_es
    tuba_b
    schlagzeug
    kleine_trommel
    pauken
    stabspiele
    perkussion
    kontrabass
    e_bass
    klavier
  ].freeze

  I18N_PREFIX = "activerecord.attributes.role.instruments"

  self.permissions = [:layer_read]
  self.used_attributes += [:instrument]

  # PaperTrail compares skipped attrs as strings against changeset keys.
  self.paper_trail_options = paper_trail_options.deep_dup
  paper_trail_options[:skip] =
    Array(paper_trail_options[:skip]).map(&:to_s) | %w[label updated_at]

  i18n_enum :instrument, INSTRUMENTS,
    key: :instruments,
    i18n_prefix: I18N_PREFIX

  attr_accessor :historic_membership

  after_destroy :update_active_years_on_person
  after_save :update_active_years_on_person

  validates_date :start_on,
    allow_nil: true

  validates_date :end_on,
    if: :historic_membership,
    allow_nil: false,
    on_or_before: -> { Time.zone.today },
    on_or_before_message: :cannot_be_later_than_today

  def self.instruments
    INSTRUMENTS
  end

  private

  def update_active_years_on_person
    person.cache_active_years
    person.save(validate: false)
  end
end
