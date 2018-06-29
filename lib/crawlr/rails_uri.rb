module Crawlr
  class RailsUri
    attr_reader :url

    def initialize(url)
      @url = url.to_s
    end

    def to_hierarchy_params
      params = Hash.new { |h,k| h[k] = Set.new }
      hierarchy = extract_path(url).split('/').reject(&:blank?)

      while base = hierarchy.shift
        has_many = if maybe_id?(hierarchy.first)
                     hierarchy.shift
                     true
                   else
                     false
                   end

        value = hierarchy.first
        params[base.tableize].add(value.tableize) if value && !maybe_id?(value) && !maybe_crud?(value)
      end

      params
    end

    def maybe_id?(value)
      return false unless value
      value =~ /^\d+$/ || value =~ /[A-Z]/
    end

    def maybe_crud?(value)
      return false unless value
      %w[new edit].include?(value)
    end

    private

    def extract_path(url)
      URI.parse(url)&.path
    rescue
      ''
    end
  end
end
