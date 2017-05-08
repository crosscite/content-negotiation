class Metadata < Bolognese::Metadata
  # fetching and parsing is an expensive step, so we cache using the crosscite format
  def initialize(input: nil)
    return super(input: input) if %w(development test).include?(Rails.env)

    cached_input = Rails.cache.read(id)
    if cached_input
      super(input: cached_input, from: "crosscite")
    else
      m = super(input: input)
      Rails.cache.write(input, m.crosscite, raw: true)
      m
    end
  end
end
