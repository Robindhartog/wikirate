include_set Type::SearchType
include_set Abstract::CompanyFilter
include_set Abstract::TaskFilter

format :html do
  def default_sort_option
    "answer"
  end

  def default_item_view
    :box
  end
end
