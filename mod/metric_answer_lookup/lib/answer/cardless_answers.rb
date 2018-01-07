class Answer
  module CardlessAnswers
    def self.included host_class
      host_class.extend ClassMethods
    end

    def virtual_answer_card name=nil, val=nil
      name ||= [record_name, year.to_s]
      val ||= value
      Card.new(name: name, type_id: Card::MetricValueID).tap do |card|
        card.define_singleton_method(:value) { val }
        #card.define_singleton_method(:updated_at) { updated_at }
        card.define_singleton_method(:value_card) do
          Card.new name: [name, :value], content: val
        end
      end
    end

    # true if there is no card for this answer
    def virtual?
      card&.new_card?
    end

    def calculated_answer metric_card, company, year, value
      ensure_record metric_card, company
      @card = virtual_answer_card metric_card.metric_value_name(company, year), value
      define_singleton_method(:fetch_creator_id) { Card::Auth.current_id }
      refresh
      update_cached_counts
      self
    end

    def update_cached_counts
      [[metric_id, :value], [metric_id, :wikirate_company],
       [company_id, :metric], [company_id, :wikirate_topic]].each do |mark|
        Card.fetch(mark).update_cached_count
      end
      Card::Set::TypePlusRight::WikirateTopic::WikirateCompany
        .topic_company_type_plus_right_cards_for_metric(Card[metric_id]).each do |card|
        card.update_cached_count
      end
    end

    def update_value value
      update_attributes! value: value,
                         numeric_value: to_numeric_value(value),
                         updated_at: Time.now
      # FIXME: editor_id column not in test db
      # editor_id: Card::Auth.current_id
    end

    module ClassMethods
      def create_calculated_answer metric_card, company, year, value
        Answer.new.calculated_answer metric_card, company, year, value
      end

      # @param ids [Array<Integer>] ids of answers in the answer table (NOT card ids)
      def update_by_ids ids, *fields
        Array(ids).each do |id|
          next unless (answer = Answer.find_by_id(id))
          answer.refresh(*fields)
        end
      end
    end
  end
end
