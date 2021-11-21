# -*- encoding : utf-8 -*-

class AddCheckFlagToAnswerTable < Cardio::Migration::DeckStructure
  def up
    add_column :answers, :checkers, :string
    add_column :answers, :check_requester, :string
  end
end
