class Metadata < Bolognese::Metadata
  # fetching and parsing is an expensive step, so we cache using the crosscite format
  def initialize(input: nil, from: nil, format: nil, **options)
    # don't cache if passing thru metadata or when in Test mode
    return super(input: input, from: from, sandbox: options[:sandbox]) if from == format.to_s || %w(test).include?(Rails.env)

    cached_input = Rails.cache.read(input)

    if cached_input
      super(input: cached_input, from: "crosscite")
    else
      super(input: input)
      Rails.cache.write(input, self.crosscite, raw: true)
    end
  end
end
