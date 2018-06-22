# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class SongsController < SimpleCrudController

  self.search_columns = [:title, :composed_by, :arranged_by, :published_by]
  self.permitted_attrs = [:title, :composed_by, :arranged_by, :published_by]

  respond_to :json

  def index
    respond_to do |format|
      format.html
      format.json { render json: for_typeahead(entries) }
    end
  end

  private

  def for_typeahead(entries)
    entries.collect do |entry|
      entry.attributes.merge(label: entry.to_s)
    end
  end

end
