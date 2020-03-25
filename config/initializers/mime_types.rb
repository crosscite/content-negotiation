# unregister all Mime types, keep only :text
Mime::EXTENSION_LOOKUP.map { |i| i.first.to_sym }.each do |f|
  Mime::Type.unregister(f)
end

# re-register some default Mime types
Mime::Type.register "text/html", :html, %w(application/xhtml+xml), %w(xhtml)
Mime::Type.register "text/plain", :text, [], %w(txt)
Mime::Type.register "application/json", :json, %w(text/x-json application/jsonrequest)

# Mime types supported by bolognese gem https://github.com/datacite/bolognese
Mime::Type.register "application/vnd.crossref.unixref+xml", :crossref
Mime::Type.register "application/vnd.crosscite.crosscite+json", :crosscite
Mime::Type.register "application/vnd.datacite.datacite+xml", :datacite, %w(application/x-datacite+xml)
Mime::Type.register "application/vnd.datacite.datacite+json", :datacite_json
Mime::Type.register "application/vnd.schemaorg.ld+json", :schema_org, %w(application/ld-json)
Mime::Type.register "application/vnd.jats+xml", :jats
Mime::Type.register "application/vnd.citationstyles.csl+json", :citeproc, %w(application/citeproc+json)
Mime::Type.register "application/vnd.codemeta.ld+json", :codemeta
Mime::Type.register "application/x-bibtex", :bibtex
Mime::Type.register "application/x-research-info-systems", :ris
Mime::Type.register "text/x-bibliography", :citation
Mime::Type.register "application/rdf+xml", :rdf_xml
Mime::Type.register "application/x-turtle", :turtle

# register renderers for these Mime types
# :citation and :datacite is handled differently
ActionController::Renderers.add :datacite do |obj, options|
  obj.datacite
end

ActionController::Renderers.add :citation do |obj, options|
  begin
    obj.style = options[:style] || "apa"
    obj.locale = options[:locale] || "en-US"
    obj.citation
  rescue CSL::ParseError # unknown style and/or location
    obj.style = "apa"
    obj.locale = "en-US"
    obj.citation
  end
end

%w(datacite_json crossref schema_org crosscite citeproc codemeta jats bibtex ris rdf_xml turtle).each do |f|
  ActionController::Renderers.add f.to_sym do |obj, options|
    obj.send(f)
  end
end
