include_set Abstract::BrowseFilterForm
include_set Abstract::BookmarkFiltering

class CompanyGroupFilterQuery < Card::FilterQuery
  include WikirateFilterQuery
end

def filter_keys
  %i[name bookmark]
end

def default_filter_hash
  { name: "" }
end

def target_type_id
  Card::CompanyGroupID
end

def filter_class
  CompanyGroupQuery
end

def default_sort_option
  "bookmarkers"
end

format :html do
  def sort_options
    { "Most #{rate_subjects}": :company }.merge super
  end
end
