module Katello
  class ManagedContentMediumProvider < ::MediumProviders::Provider
    def validate
      errors = []

      errors << N_("Kickstart repository was not set for host '%{host}'") % { :host => entity } if kickstart_repo.nil?
      errors << N_("Content source was not set for host '%{host}'") % { :host => entity } if entity.content_source.nil?
      errors
    end

    def medium_uri(path = "")
      url = kickstart_repo.full_path(entity.content_source)
      url += '/' + path unless path.empty?
      URI.parse(url)
    end

    def unique_id
      @unique_id ||= begin
        "#{kickstart_repo.name.parameterize}-#{kickstart_repo.id}"
      end
    end

    private

    def kickstart_repo
      @kickstart_repo ||= entity.try(:content_facet).try(:kickstart_repository) || entity.try(:kickstart_repository)
    end
  end
end
