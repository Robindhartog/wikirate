# Company Group specifications are stored in the following format:
#
# [[metric1_name]],year1,value_json1
# [[metric2_name]],year2,value_json2
#
# Each row represents a "constraint". No newlines. Any commas must be escaped.
#
# The "value json" is a one-line JSON string representing a valid AnswerQuery
# value for the answer's "value" field. See #value_query.
#
# Specification content is generated directly in JavaScript
# and is used in CompanyGroup+Company searches.

# we reuse metric and value interface from this set in the constraint editor:
include_set Card::Set::TypePlusRight::Metric::MetricAnswer

attr_accessor :metric_card

# store explicit list in `<Company Group>+company`
def explicit?
  content == "explicit"
end

def implicit?
  !explicit?
end

def constraints
  raw_constraints.map do |raw_constraint|
    Constraint.new_from_raw raw_constraint
  end
end

# Each constraint is a CSV row
def raw_constraints
  explicit? ? [] : content.split(/\n+/).map(&:strip)
end

# converts each "row" of a specification into a Constraint object
class Constraint
  attr_accessor :metric, :year, :value, :group

  def self.new_from_raw raw_constraint
    new(*CSV.parse_line(raw_constraint))
  end

  def initialize metric, year, value=nil, group=nil
    @metric = Card.cardish metric
    @year = year.to_s
    @value = interpret_value value
    @group = Card.cardish(group) if group.present?
  end

  def interpret_value value
    if value.is_a? String
      parsed = JSON.parse value
      parsed.is_a?(Hash) ? parsed.symbolize_keys : parsed
    else
      value
    end
  end

  def to_s row_sep=nil
    ["[[#{metric.name}]]", year, value.to_json, group].to_csv(row_sep: row_sep)
  end

  def validate!
    raise "invalid metric" unless valid_metric?
    raise "invalid year" unless valid_year?
  end

  def valid_metric?
    metric&.type_id == Card::MetricID
  end

  def valid_year?
    year.match(/^\d{4}$/) || year.in?(%w[any latest])
  end

  def query_hash
    h = { metric_id: metric.id, value: value, related_company_group: group }
    h[:year] = year unless year == "any"
    h
  end

  def conditions
    AnswerQuery.new(query_hash).lookup_conditions
  end
end

format do
  # OVERRIDES of MetricCompanyFilter
  # ignore filter params
  def filter_hash
    {}
  end

  def default_filter_hash
    {}
  end
end

format :json do
  def molecule
    super.merge constraints: constraints
  end

  def constraints
    card.constraints.map do |c|
      {
        metric: c.metric.name,
        year: c.year,
        value: c.value,
        group: c.group
      }
    end
  end

  view(:items) { [] }
end
