# unregister all Mime types, keep only :text
Mime::EXTENSION_LOOKUP.map { |i| i.first.to_sym }.each do |f|
  Mime::Type.unregister(f)
end

# re-register some default Mime types
Mime::Type.register "text/html", :html, %w( application/xhtml+xml ), %w( xhtml )
Mime::Type.register "text/plain", :text, [], %w(txt)
Mime::Type.register "application/json", :json, %w( text/x-json application/jsonrequest )

# Mime types supported by bolognese gem https://github.com/datacite/bolognese
Mime::Type.register "application/vnd.crossref.unixref+xml", :crossref
Mime::Type.register "application/vnd.datacite.datacite+xml", :datacite, %w( application/x-datacite+xml )
Mime::Type.register "application/vnd.datacite.datacite+json", :datacite_json
Mime::Type.register "application/vnd.schemaorg.ld+json", :schema_org
Mime::Type.register "application/rdf+xml", :rdf_xml
Mime::Type.register "text/turtle", :turtle
Mime::Type.register "application/vnd.citationstyles.csl+json", :citeproc, %w( application/citeproc+json )
Mime::Type.register "application/vnd.codemeta.ld+json", :codemeta
Mime::Type.register "application/x-bibtex", :bibtex
Mime::Type.register "application/x-research-info-systems", :ris
Mime::Type.register "text/x-bibliography", :citation

# register renderers for these Mime types
# :citation is handled differently
%w(datacite_json schema_org turtle citeproc codemeta).each do |f|
  ActionController::Renderers.add f.to_sym do |obj, options|
    self.content_type ||= Mime[f.to_sym]
    Librato.timing 'metadata.write' do
      self.response_body = obj.send(f)
    end
  end
end

# these Mime types send a file for download. We give proper filename and extension
%w(crossref datacite rdf_xml).each do |f|
  ActionController::Renderers.add f.to_sym do |obj, options|
    filename = obj.doi.gsub(/[^0-9A-Za-z.\-]/, '_')
    Librato.timing 'metadata.write' do
      send_data obj.send(f.to_s), type: Mime[f.to_sym],
        disposition: "attachment; filename=#{filename}.xml"
    end
  end
end

ActionController::Renderers.add :bibtex do |obj, options|
  filename = obj.doi.gsub(/[^0-9A-Za-z.\-]/, '_')
  Librato.timing 'metadata.write' do
    send_data obj.send("bibtex"), type: Mime[:bibtex],
      disposition: "attachment; filename=#{filename}.bib"
  end
end

ActionController::Renderers.add :ris do |obj, options|
  filename = obj.doi.gsub(/[^0-9A-Za-z.\-]/, '_')
  Librato.timing 'metadata.write' do
    send_data obj.send("ris"), type: Mime[:ris],
      disposition: "attachment; filename=#{filename}.ris"
  end
end
