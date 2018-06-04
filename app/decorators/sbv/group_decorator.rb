module Sbv::GroupDecorator
  extend ActiveSupport::Concern

  I18NKEY = "#{activerecord.attributes.group}".freeze
  BESETZUNGEN = %w(brass_band harmonie fanfare_benelux fanfare_mixte).freeze
  KLASSEN = %w(1 2 3 4 5).freeze
  UNTERHALTUNGSMUSIK = %w(oberstufe mittelstufe unterstufe)

  # Klassen
  def available_klassen
    KLASSEN.map { |k| [k, I18n.translate("#{I18NKEY}.klassen.#{k}")]}
  end

  def klasse_value
    klasse ? I18n.translate("#{I18NKEY}.klassen.#{klasse}") : ''
  end

  def klasse_label
    I18n.translate('activerecord.models.group.klasse')
  end

  # Besetzungen
  def available_besetzungen
    BESETZUNGEN.map { |b| [b, I18n.translate("#{I18NKEY}.besetzungen.#{b}")]}
  end

  def besetzung_value
    besetzung ? I18n.translate("#{I18NKEY}.besetzungen.#{besetzung}") : ''
  end

  def besetzung_label
    I18n.translate('activerecord.models.group.besetzung')
  end

  # Unterhaltungsmusik
  def available_unterhaltungsmusik
    UNTERHALTUNGSMUSIK.map  do |u| 
      [u, I18n.translate("#{I18NKEY}.unterhaltungsmusik_stufen.#{u}")]
    end
  end

  def unterhaltungsmusik_value
    if unterhaltungsmusik
      I18n.translate("#{I18NKEY}.unterhaltungsmusik_stufen.#{unterhaltungsmusik}")
    else
      ''
    end
  end

  def unterhaltungsmusik_label
    I18n.translate('activerecord.models.group.unterhaltungsmusik')
  end

end
