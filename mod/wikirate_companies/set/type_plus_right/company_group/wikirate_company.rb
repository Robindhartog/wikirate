# cache # of companies in this group
include_set Abstract::ListCachedCount
include_set Abstract::IdPointer

delegate :specification_card, to: :left
delegate :explicit?, :implicit?, to: :specification_card

def history?
  explicit?
end

def constraints
  specification_card.constraints
end

def relation
  exist_clauses = constraint_clauses.map { |cc| "exists (#{cc})" }
  Card.where exist_clauses.join(" and ")
end

def constraint_clauses
  constraints.map do |constraint|
    "SELECT company_id FROM answers " \
    "WHERE #{constraint.conditions} AND answers.company_id = cards.id"
  end
end

def item_names_from_spec
  relation.pluck :name
end

def update_content_from_spec
  self.content = item_names_from_spec.to_pointer_content if implicit?
end

def bookmark_type
  :wikirate_company
end

format :html do
  view :filtered_content, cache: :never do
    if card.explicit?
      wrap { [%{<div class="py-3">#{render_menu}</div>}, nest_search_card] }
    else
      nest_search_card
    end
  end

  def nest_search_card
    field_nest :company_search, view: :filtered_content, items: { view: :bar }
  end

  def input_type
    card.count > 500 ? :list : :filtered_list
  end

  def default_item_view
    :thumbnail_no_link
  end

  def filter_card
    :wikirate_company.card
  end
end

class << self
  def company_groups_for_metric metric_id
    Card.search type: :company_group,
                right_plus: [:specification, { refer_to: metric_id }]
  end
end
