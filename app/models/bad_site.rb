class BadSite < ApplicationRecord
  scope :active, -> { where(is_active: true) }


  # Only parses twice if url doesn't start with a scheme
  def self.get_host_without_www(url)
    uri = URI.parse(url.to_s.strip)
    uri = URI.parse("http://#{url}") if uri.scheme.nil?
    host = uri.host.downcase
    host.start_with?('www.') ? host[4..-1] : host
  end

  def self.listed(site)

    domain = self.get_host_without_www(site)
    bads = BadSite.active.pluck(:url)
    bads.each do |burl|
      burl_domain = self.get_host_without_www(burl)
      return true if burl_domain === domain
      #return true if the site domain is included in the bad domain
    end

    return false
  end

  def self.get_id(site)
    domain = self.get_host_without_www(site)
    bads = BadSite.active.all
    bads.each do |bad|
      burl_domain = self.get_host_without_www(bad.url)
      return bad.id if burl_domain === domain
      #return true if the site domain is included in the bad domain
    end

    raise "Could not find id of domain after processing for it"

  end

  def self.update_list(domain_array)

    #set all domains to is_active = false
    # for each domain array, if not in list then add, else set is_active to true
    BadSite.active.update_all(is_active: false)

    domain_array.each do |dommi|
      next if dommi.to_s.strip.blank?
      domain = self.get_host_without_www(dommi)
      b =  BadSite.find_by_url(domain)
      if b.blank?
        b = BadSite.new
        b.url = domain
        b.is_active= true
        b.save!
      else
        b.is_active= true
        b.save!
      end
    end
  end
end
