card_accessor :value, type: :phrase

include_set Abstract::MetricChild, generation: 2

event :set_metric_value_name,
      before: :set_autoname, when: proc { |c| c.cardname.parts.size < 4 } do
  return if valid_value_name?
  self.name = %w(metric company year).map do |part|
    name_part = remove_subfield(part)
    unless name_part
      errors.add :name, "missing #{part} part"
      next
    end
    name_part.content.gsub("[[", "").gsub("]]", "")
  end.join "+"
end

event :rename_metric_value,
      before: :set_autoname, when: proc { |c| c.cardname.parts.size < 4 } do
  return if valid_value_name?
  self.name = %w(metric company year).map do |part|
    name_part = remove_subfield(part)
    unless name_part
      errors.add :name, "missing #{part} part"
      next
    end
    name_part.content.gsub("[[", "").gsub("]]", "")
  end.join "+"
end

def valid_value_name?
  cardname.parts.size >= 3 && valid_metric? && valid_company? && valid_year?
end

def valid_metric?
  metric_card && metric_card.type_id == MetricID
end

def valid_company?
  company_card && company_card.type_id == WikirateCompanyID
end

def valid_year?
  year_card && year_card.type_id == YearID
end
