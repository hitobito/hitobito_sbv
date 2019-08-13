class AddPlaceholdersToSelectedCustomContents < ActiveRecord::Migration
  def up
    each_applicable_custom_content do |content|
      placeholders = content.placeholders_optional + ", dachverband"
      content.update(placeholders_optional: placeholders)
    end
  end

  def down
    each_applicable_custom_content do |content|
      placeholders = content.placeholders_optional.gsub(', dachverband', '')
      content.update(placeholders_optional: placeholders)
    end
  end

  def each_applicable_custom_content
    [SongCensusMailer::SONG_CENSUS_REMINDER, Person::LoginMailer::CONTENT_LOGIN ].each do |key|
      custom_content = CustomContent.find_by(key: key)
      yield custom_content if custom_content
    end
  end
end
