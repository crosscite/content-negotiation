class Metadata < Bolognese::Metadata
  # fetching and parsing is an expensive step, so we cache using the crosscite format, or raw xml
  def initialize(input: nil, from: nil, format: nil, **options)
    # don't cache if passing thru metadata or when in Test mode
    return super(input: input, from: from, sandbox: options[:sandbox]) if %w(test).include?(Rails.env)

    # passthru of DataCite or Crossref xml
    if from == format.to_s
      cached_input = Rails.cache.read("#{from}/#{input}")

      if cached_input
        super(input: cached_input, from: from)
      else
        super(input: input)
        Rails.cache.write("#{from}/#{input}", self.raw, raw: true)
      end
    else
      cached_input = Rails.cache.read("crosscite/#{input}")

      if cached_input
        super(input: cached_input, from: "crosscite")
      else
        super(input: input)
        Rails.cache.write("crosscite/#{input}", self.crosscite, raw: true)
      end
    end
  end
end
