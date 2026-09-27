module Editorial
  # Strong-parameter whitelist shared by the structured content forms.
  module FormFields
    SCALARS = %i[
      word meaning_mizo english_gloss example_mizo emoji category difficulty remove_image
      prompt_mizo answer explanation_mizo
      game_id title subtitle instructions prompt hint correct_feedback retry_feedback
      text_mizo english_support
    ].freeze

    def self.permit(params)
      params.fetch(:fields, {}).permit(*SCALARS, game_modes: [], options: []).to_h
    end
  end
end
