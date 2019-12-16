include_set Abstract::MetricChild, generation: 3
include_set Abstract::DesignerPermissions

def history?
  !metric_card&.relationship?
end

def typed_value?
  true
end

# if metric is a relationship, the Relationship Answer takes the value type from
# the metric, but the Metric answer value is always a number (a count)
def type_code_from_metric
  return unless metric_card
  metric_card.relationship? ? :number_value : metric_card.value_cardtype_code
end

def new_value? value
  content.casecmp(value).positive?
end

def relationship_count_value?
  metric_card.relationship?
end